import 'package:clock/clock.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/domain/entities/article.dart';

/// Drift-backed bookmarks over the tables created in the data foundation.
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
  Future<void> save(Article article) async {
    // The bookmark references cached_articles, so make sure the article exists
    // before the foreign key is enforced. This also means a saved article
    // survives a feed-cache eviction.
    await _local.upsertArticle(article);

    await _db
        .into(_db.bookmarks)
        .insertOnConflictUpdate(
          BookmarksCompanion.insert(
            articleUrl: article.url,
            createdAt: _clock.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> remove(String url) async {
    await (_db.delete(
      _db.bookmarks,
    )..where((Bookmarks t) => t.articleUrl.equals(url))).go();
  }
}
