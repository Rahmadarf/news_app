import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/search/data/repositories/recent_search_repository_impl.dart';
import 'package:news_app/features/search/domain/repositories/recent_search_repository.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late MutableClock clock;
  late RecentSearchRepositoryImpl repository;

  setUp(() {
    db = newTestDatabase();
    clock = MutableClock(DateTime.utc(2026, 9, 22, 9));
    repository = RecentSearchRepositoryImpl(database: db, clock: clock.clock);
  });

  Future<List<String>> read() => repository.watchRecent().first;

  test('records a term', () async {
    await repository.record('kota');

    expect(await read(), <String>['kota']);
  });

  test('ignores blank input', () async {
    await repository.record('   ');

    expect(await read(), isEmpty);
  });

  test('trims the stored term', () async {
    await repository.record('  energi  ');

    expect(await read(), <String>['energi']);
  });

  test('orders most recent first', () async {
    await repository.record('kota');
    clock.advance(const Duration(minutes: 1));
    await repository.record('energi');

    expect(await read(), <String>['energi', 'kota']);
  });

  test('re-searching a term moves it to the top without duplicating', () async {
    await repository.record('kota');
    clock.advance(const Duration(minutes: 1));
    await repository.record('energi');
    clock.advance(const Duration(minutes: 1));
    await repository.record('kota');

    expect(await read(), <String>['kota', 'energi']);
  });

  test('retains at most the documented number of terms', () async {
    for (int i = 0; i < RecentSearchRepository.maxEntries + 4; i++) {
      await repository.record('term $i');
      clock.advance(const Duration(minutes: 1));
    }

    final List<String> stored = await read();
    expect(stored, hasLength(RecentSearchRepository.maxEntries));
    expect(stored.first, 'term ${RecentSearchRepository.maxEntries + 3}');
  });

  test('removes a single term', () async {
    await repository.record('kota');
    clock.advance(const Duration(minutes: 1));
    await repository.record('energi');

    await repository.remove('kota');

    expect(await read(), <String>['energi']);
  });

  test('clears everything', () async {
    await repository.record('kota');
    await repository.clear();

    expect(await read(), isEmpty);
  });
}
