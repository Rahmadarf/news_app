import 'package:drift/drift.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';

/// One cached page, with the metadata needed to judge its freshness.
class CachedFeedPage {
  const CachedFeedPage({
    required this.articles,
    required this.fetchedAt,
    required this.totalResults,
    required this.hasMore,
  });

  final List<Article> articles;
  final DateTime fetchedAt;
  final int totalResults;
  final bool hasMore;
}

/// Local persistence for headline feeds.
///
/// Every method may throw a Drift exception; the repository is responsible for
/// deciding whether that is fatal. Nothing here knows about HTTP, DTOs, or
/// presentation.
class NewsLocalDataSource {
  NewsLocalDataSource(this._db);

  final AppDatabase _db;

  /// Builds the cache key for a headline feed. Documented as the cache
  /// identity: country plus category, one entry per page.
  static String feedKey({required String country, required String category}) =>
      'headlines:$country:$category';

  /// Returns the stored page, or `null` when it was never cached.
  Future<CachedFeedPage?> readPage({
    required String key,
    required int page,
  }) async {
    final FeedPageMetadataData? meta =
        await (_db.select(_db.feedPageMetadata)..where(
              (FeedPageMetadata t) =>
                  t.feedKey.equals(key) & t.page.equals(page),
            ))
            .getSingleOrNull();

    if (meta == null) return null;

    final List<TypedResult> rows =
        await (_db.select(_db.feedEntries).join(<Join>[
                innerJoin(
                  _db.cachedArticles,
                  _db.cachedArticles.url.equalsExp(_db.feedEntries.articleUrl),
                ),
              ])
              ..where(
                _db.feedEntries.feedKey.equals(key) &
                    _db.feedEntries.page.equals(page),
              )
              ..orderBy(<OrderingTerm>[
                OrderingTerm.asc(_db.feedEntries.position),
              ]))
            .get();

    return CachedFeedPage(
      articles: List<Article>.unmodifiable(
        rows.map(
          (TypedResult row) => _toArticle(row.readTable(_db.cachedArticles)),
        ),
      ),
      // Drift stores timestamps as unix seconds and hands them back in local
      // time; the domain always works in UTC.
      fetchedAt: meta.fetchedAt.toUtc(),
      totalResults: meta.totalResults,
      hasMore: meta.hasMore,
    );
  }

  /// Canonical URLs already stored for pages below [beforePage] of [key].
  ///
  /// Used to keep an article that the API repeats across pages from appearing
  /// twice in the merged list.
  Future<Set<String>> urlsBeforePage({
    required String key,
    required int beforePage,
  }) async {
    if (beforePage <= 1) return const <String>{};

    final List<FeedEntry> rows =
        await (_db.select(_db.feedEntries)..where(
              (FeedEntries t) =>
                  t.feedKey.equals(key) & t.page.isSmallerThanValue(beforePage),
            ))
            .get();

    return rows.map((FeedEntry e) => e.articleUrl).toSet();
  }

  /// Replaces the stored contents of one page atomically.
  Future<void> writePage({
    required String key,
    required int page,
    required List<Article> articles,
    required DateTime fetchedAt,
    required int totalResults,
    required bool hasMore,
  }) {
    return _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.cachedArticles,
          articles.map(_toCompanion).toList(growable: false),
        );
      });

      await (_db.delete(_db.feedEntries)..where(
            (FeedEntries t) => t.feedKey.equals(key) & t.page.equals(page),
          ))
          .go();

      await _db.batch((Batch batch) {
        batch.insertAll(_db.feedEntries, <FeedEntriesCompanion>[
          for (int i = 0; i < articles.length; i++)
            FeedEntriesCompanion.insert(
              feedKey: key,
              page: page,
              position: i,
              articleUrl: articles[i].url,
            ),
        ]);
      });

      await _db
          .into(_db.feedPageMetadata)
          .insertOnConflictUpdate(
            FeedPageMetadataCompanion.insert(
              feedKey: key,
              page: page,
              fetchedAt: fetchedAt,
              totalResults: totalResults,
              hasMore: hasMore,
            ),
          );
    });
  }

  /// Drops every page of one feed. Used when a refresh invalidates the feed.
  Future<void> clearFeed(String key) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.feedEntries,
      )..where((FeedEntries t) => t.feedKey.equals(key))).go();
      await (_db.delete(
        _db.feedPageMetadata,
      )..where((FeedPageMetadata t) => t.feedKey.equals(key))).go();
    });
  }

  /// Drops all cached feeds, keeping any article the reader still has a claim
  /// on.
  ///
  /// An article survives when it is bookmarked or present in reading history.
  /// Clearing a cache must not silently delete something the reader saved, and
  /// it must not erase what they have read: both tables reference
  /// `cached_articles` with ON DELETE CASCADE, so deleting the row would take
  /// the entry with it.
  Future<void> clearAll() {
    return _db.transaction(() async {
      await _db.delete(_db.feedEntries).go();
      await _db.delete(_db.feedPageMetadata).go();
      await (_db.delete(_db.cachedArticles)..where(
            (CachedArticles t) =>
                notExistsQuery(
                  _db.select(_db.bookmarks)
                    ..where((Bookmarks b) => b.articleUrl.equalsExp(t.url)),
                ) &
                notExistsQuery(
                  _db.select(_db.readingHistoryEntries)..where(
                    (ReadingHistoryEntries h) => h.articleUrl.equalsExp(t.url),
                  ),
                ),
          ))
          .go();
    });
  }

  /// Stores or refreshes a single article outside any feed page.
  ///
  /// Used when an article must outlive the feed cache — a bookmark, for
  /// instance — without belonging to a cached page.
  Future<void> upsertArticle(Article article) {
    return _db
        .into(_db.cachedArticles)
        .insertOnConflictUpdate(_toCompanion(article));
  }

  /// Looks one article up by canonical URL. Backs the article screen when it
  /// is reached by deep link and no object was handed over.
  Future<Article?> findByUrl(String url) async {
    final CachedArticle? row = await (_db.select(
      _db.cachedArticles,
    )..where((CachedArticles t) => t.url.equals(url))).getSingleOrNull();

    return row == null ? null : _toArticle(row);
  }

  static Article _toArticle(CachedArticle row) => Article(
    url: row.url,
    title: row.title,
    source: ArticleSource(name: row.sourceName, id: row.sourceId),
    description: row.description,
    imageUrl: row.imageUrl,
    publishedAt: row.publishedAt?.toUtc(),
    content: row.content,
  );

  static CachedArticlesCompanion _toCompanion(Article article) =>
      CachedArticlesCompanion.insert(
        url: article.url,
        title: article.title,
        sourceName: article.source.name,
        sourceId: Value<String?>(article.source.id),
        description: Value<String?>(article.description),
        imageUrl: Value<String?>(article.imageUrl),
        publishedAt: Value<DateTime?>(article.publishedAt),
        content: Value<String?>(article.content),
      );
}
