import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/history/domain/repositories/reading_history_repository.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';

/// Drift-backed reading history over the table created in the data foundation.
class ReadingHistoryRepositoryImpl implements ReadingHistoryRepository {
  ReadingHistoryRepositoryImpl({
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
  Stream<List<Article>> watchRecent() {
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.readingHistoryEntries).join(<Join>[
            innerJoin(
              _db.cachedArticles,
              _db.cachedArticles.url.equalsExp(
                _db.readingHistoryEntries.articleUrl,
              ),
            ),
          ])
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(_db.readingHistoryEntries.viewedAt),
          ])
          ..limit(ReadingHistoryRepository.maxEntries);

    return query.watch().map(
      (List<TypedResult> rows) => rows
          .map(
            (TypedResult row) => _toArticle(row.readTable(_db.cachedArticles)),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> record(Article article) async {
    // The entry references cached_articles, so store the article first. This
    // also means history survives a feed-cache eviction.
    await _local.upsertArticle(article);

    // The URL is the primary key, so re-opening an article moves it to the top
    // rather than adding a duplicate.
    await _db
        .into(_db.readingHistoryEntries)
        .insertOnConflictUpdate(
          ReadingHistoryEntriesCompanion.insert(
            articleUrl: article.url,
            viewedAt: _clock.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> clear() => _db.delete(_db.readingHistoryEntries).go();

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
