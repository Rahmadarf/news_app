import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/bookmarks/domain/entities/saved_article.dart';
import 'package:news_app/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';

/// Drift-backed bookmarks and collections.
class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl({
    required AppDatabase database,
    required NewsLocalDataSource local,
    Clock? clock,
  }) : _db = database,
       _local = local,
       _clock = clock ?? const Clock();

  final AppDatabase _db;
  final NewsLocalDataSource _local;
  final Clock _clock;

  @override
  Stream<Set<String>> watchSavedUrls() {
    return _db
        .select(_db.bookmarks)
        .watch()
        .map(
          (List<Bookmark> rows) =>
              rows.map((Bookmark row) => row.articleUrl).toSet(),
        );
  }

  @override
  Stream<List<SavedArticle>> watchSaved({String? collectionName}) {
    final JoinedSelectStatement<HasResultSet, dynamic> query = _db
        .select(_db.bookmarks)
        .join(<Join>[
          innerJoin(
            _db.cachedArticles,
            _db.cachedArticles.url.equalsExp(_db.bookmarks.articleUrl),
          ),
        ]);

    if (collectionName != null) {
      query.where(_db.bookmarks.collectionName.equals(collectionName));
    }
    query.orderBy(<OrderingTerm>[OrderingTerm.desc(_db.bookmarks.createdAt)]);

    return query.watch().map(
      (List<TypedResult> rows) => rows
          .map(
            (TypedResult row) => SavedArticle(
              article: _toArticle(row.readTable(_db.cachedArticles)),
              savedAt: row.readTable(_db.bookmarks).createdAt.toUtc(),
              collectionName: row.readTable(_db.bookmarks).collectionName,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Stream<List<String>> watchCollections() {
    return (_db.select(_db.collections)
          ..orderBy(<OrderingTerm Function(Collections)>[
            (Collections t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch()
        .map(
          (List<Collection> rows) =>
              rows.map((Collection row) => row.name).toList(growable: false),
        );
  }

  @override
  Future<void> save(Article article, {String? collectionName}) async {
    // The bookmark references cached_articles, so make sure the article exists
    // before the foreign key is enforced. This also means a saved article
    // survives a feed-cache eviction.
    await _local.upsertArticle(article);

    final Bookmark? existing =
        await (_db.select(_db.bookmarks)
              ..where((Bookmarks t) => t.articleUrl.equals(article.url)))
            .getSingleOrNull();

    await _db
        .into(_db.bookmarks)
        .insertOnConflictUpdate(
          BookmarksCompanion.insert(
            articleUrl: article.url,
            createdAt: existing?.createdAt ?? _clock.now().toUtc(),
            // Re-saving must not silently unfile an article.
            collectionName: Value<String?>(
              collectionName ?? existing?.collectionName,
            ),
          ),
        );
  }

  @override
  Future<void> remove(String url) async {
    await (_db.delete(
      _db.bookmarks,
    )..where((Bookmarks t) => t.articleUrl.equals(url))).go();
  }

  @override
  Future<void> assignToCollection(String url, String? collectionName) async {
    await (_db.update(
      _db.bookmarks,
    )..where((Bookmarks t) => t.articleUrl.equals(url))).write(
      BookmarksCompanion(collectionName: Value<String?>(collectionName)),
    );
  }

  @override
  Future<bool> createCollection(String name) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    final Collection? existing = await (_db.select(
      _db.collections,
    )..where((Collections t) => t.name.equals(trimmed))).getSingleOrNull();
    if (existing != null) return false;

    await _db
        .into(_db.collections)
        .insert(
          CollectionsCompanion.insert(
            name: trimmed,
            createdAt: _clock.now().toUtc(),
          ),
        );
    return true;
  }

  @override
  Future<void> deleteCollection(String name) async {
    // ON DELETE SET NULL on bookmarks.collectionName means the saved articles
    // stay saved and simply become unfiled.
    await (_db.delete(
      _db.collections,
    )..where((Collections t) => t.name.equals(name))).go();
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
}
