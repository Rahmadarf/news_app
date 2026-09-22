import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:news_app/features/bookmarks/domain/entities/saved_article.dart';
import 'package:news_app/features/history/data/repositories/reading_history_repository_impl.dart';
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
  late BookmarkRepositoryImpl repository;

  setUp(() {
    db = newTestDatabase();
    clock = MutableClock(DateTime.utc(2026, 9, 22, 9));
    local = NewsLocalDataSource(db);
    repository = BookmarkRepositoryImpl(
      database: db,
      local: local,
      clock: clock.clock,
    );
  });

  Future<List<String>> savedTitles({String? collection}) async {
    final List<SavedArticle> items = await repository
        .watchSaved(collectionName: collection)
        .first;
    return items.map((SavedArticle s) => s.article.title).toList();
  }

  group('saving', () {
    test('saves an article and exposes its URL', () async {
      await repository.save(articleAt(1));

      expect(await repository.watchSavedUrls().first, <String>{
        'https://example.com/1',
      });
      expect(await savedTitles(), <String>['Headline 1']);
    });

    test(
      'stores a copy, so a saved article survives a cleared cache',
      () async {
        await repository.save(articleAt(1));
        await local.clearAll();

        expect(await savedTitles(), <String>['Headline 1']);
      },
    );

    test('orders most recently saved first', () async {
      await repository.save(articleAt(1));
      clock.advance(const Duration(minutes: 1));
      await repository.save(articleAt(2));

      expect(await savedTitles(), <String>['Headline 2', 'Headline 1']);
    });

    test('removing leaves the cached article in place', () async {
      await repository.save(articleAt(1));
      await repository.remove('https://example.com/1');

      expect(await repository.watchSavedUrls().first, isEmpty);
      expect(await local.findByUrl('https://example.com/1'), isNotNull);
    });
  });

  group('collections', () {
    test('creates a collection', () async {
      expect(await repository.createCollection('Reading list'), isTrue);
      expect(await repository.watchCollections().first, <String>[
        'Reading list',
      ]);
    });

    test('rejects a blank name', () async {
      expect(await repository.createCollection('   '), isFalse);
      expect(await repository.watchCollections().first, isEmpty);
    });

    test('rejects a duplicate name', () async {
      await repository.createCollection('Reading list');

      expect(await repository.createCollection('Reading list'), isFalse);
      expect(await repository.watchCollections().first, hasLength(1));
    });

    test('trims the stored name', () async {
      await repository.createCollection('  Referensi  ');

      expect(await repository.watchCollections().first, <String>['Referensi']);
    });

    test('keeps creation order so the chips do not reshuffle', () async {
      await repository.createCollection('Reading list');
      clock.advance(const Duration(minutes: 1));
      await repository.createCollection('Referensi');

      expect(await repository.watchCollections().first, <String>[
        'Reading list',
        'Referensi',
      ]);
    });

    test('files an article and filters by collection', () async {
      await repository.createCollection('Reading list');
      await repository.save(articleAt(1));
      await repository.save(articleAt(2));
      await repository.assignToCollection(
        'https://example.com/1',
        'Reading list',
      );

      expect(await savedTitles(collection: 'Reading list'), <String>[
        'Headline 1',
      ]);
      expect(await savedTitles(), hasLength(2));
    });

    test('unfiles an article when assigned null', () async {
      await repository.createCollection('Reading list');
      await repository.save(articleAt(1));
      await repository.assignToCollection(
        'https://example.com/1',
        'Reading list',
      );

      await repository.assignToCollection('https://example.com/1', null);

      expect(await savedTitles(collection: 'Reading list'), isEmpty);
      expect(await savedTitles(), <String>['Headline 1']);
    });

    test('re-saving does not silently unfile an article', () async {
      await repository.createCollection('Reading list');
      await repository.save(articleAt(1));
      await repository.assignToCollection(
        'https://example.com/1',
        'Reading list',
      );

      await repository.save(articleAt(1));

      expect(await savedTitles(collection: 'Reading list'), <String>[
        'Headline 1',
      ]);
    });

    test('re-saving keeps the original save time', () async {
      await repository.save(articleAt(1));
      clock.advance(const Duration(hours: 5));
      await repository.save(articleAt(1));

      final List<SavedArticle> items = await repository.watchSaved().first;
      expect(items.single.savedAt, DateTime.utc(2026, 9, 22, 9));
    });

    test('deleting a collection keeps its articles saved', () async {
      await repository.createCollection('Reading list');
      await repository.save(articleAt(1));
      await repository.assignToCollection(
        'https://example.com/1',
        'Reading list',
      );

      await repository.deleteCollection('Reading list');

      expect(await repository.watchCollections().first, isEmpty);
      expect(await savedTitles(), <String>['Headline 1']);
      expect(
        (await repository.watchSaved().first).single.collectionName,
        isNull,
        reason: 'the article becomes unfiled rather than being deleted',
      );
    });
  });

  group('interaction with the cache and history', () {
    test('clearing the cache keeps bookmarks and history', () async {
      final ReadingHistoryRepositoryImpl history = ReadingHistoryRepositoryImpl(
        database: db,
        local: local,
        clock: clock.clock,
      );

      await repository.save(articleAt(1));
      await history.record(articleAt(2));

      await local.clearAll();

      expect(await savedTitles(), <String>['Headline 1']);
      expect(
        (await history.watchRecent().first).map((Article a) => a.title),
        <String>['Headline 2'],
      );
    });
  });
}
