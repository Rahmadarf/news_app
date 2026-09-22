import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:news_app/features/history/data/repositories/reading_history_repository_impl.dart';
import 'package:news_app/features/history/domain/repositories/reading_history_repository.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';

import '../../support/test_database.dart';

Article articleAt(int index) => Article(
  url: 'https://example.com/$index',
  title: 'Headline $index',
  source: const ArticleSource(name: 'Source'),
);

void main() {
  late AppDatabase db;
  late MutableClock clock;
  late NewsLocalDataSource local;
  late ReadingHistoryRepositoryImpl repository;

  setUp(() {
    db = newTestDatabase();
    clock = MutableClock(DateTime.utc(2026, 9, 22, 9));
    local = NewsLocalDataSource(db);
    repository = ReadingHistoryRepositoryImpl(
      database: db,
      local: local,
      clock: clock.clock,
    );
  });

  Future<List<String>> titles() async {
    final List<Article> articles = await repository.watchRecent().first;
    return articles.map((Article a) => a.title).toList();
  }

  test('records an opened article', () async {
    await repository.record(articleAt(1));

    expect(await titles(), <String>['Headline 1']);
  });

  test('stores a copy, so history survives a cleared feed cache', () async {
    await repository.record(articleAt(1));
    await local.clearAll();

    expect(await titles(), <String>['Headline 1']);
  });

  test('orders most recently opened first', () async {
    await repository.record(articleAt(1));
    clock.advance(const Duration(minutes: 1));
    await repository.record(articleAt(2));

    expect(await titles(), <String>['Headline 2', 'Headline 1']);
  });

  test('re-opening moves an article to the top without duplicating', () async {
    await repository.record(articleAt(1));
    clock.advance(const Duration(minutes: 1));
    await repository.record(articleAt(2));
    clock.advance(const Duration(minutes: 1));
    await repository.record(articleAt(1));

    expect(await titles(), <String>['Headline 1', 'Headline 2']);
  });

  test('caps the retained entries', () async {
    for (int i = 0; i < 3; i++) {
      await repository.record(articleAt(i));
      clock.advance(const Duration(minutes: 1));
    }

    final List<Article> stored = await repository.watchRecent().first;
    expect(
      stored.length,
      lessThanOrEqualTo(ReadingHistoryRepository.maxEntries),
    );
  });

  test('clearing history leaves bookmarks alone', () async {
    final BookmarkRepositoryImpl bookmarks = BookmarkRepositoryImpl(
      database: db,
      local: local,
      clock: clock.clock,
    );

    await bookmarks.save(articleAt(1));
    await repository.record(articleAt(1));

    await repository.clear();

    expect(await titles(), isEmpty);
    expect(await bookmarks.watchSavedUrls().first, <String>{
      'https://example.com/1',
    });
  });
}
