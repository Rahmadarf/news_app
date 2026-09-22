import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/search/domain/repositories/recent_search_repository.dart';

/// Drift-backed recent searches over the table created in the data foundation.
class RecentSearchRepositoryImpl implements RecentSearchRepository {
  RecentSearchRepositoryImpl({required AppDatabase database, Clock? clock})
    : _db = database,
      _clock = clock ?? const Clock();

  final AppDatabase _db;
  final Clock _clock;

  @override
  Stream<List<String>> watchRecent() {
    return (_db.select(_db.recentSearches)
          ..orderBy(<OrderingTerm Function(RecentSearches)>[
            (RecentSearches t) => OrderingTerm.desc(t.searchedAt),
          ])
          ..limit(RecentSearchRepository.maxEntries))
        .watch()
        .map(
          (List<RecentSearchEntry> rows) => rows
              .map((RecentSearchEntry row) => row.query)
              .toList(growable: false),
        );
  }

  @override
  Future<void> record(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // The query is the primary key, so re-searching a term refreshes its
    // timestamp and moves it to the top rather than duplicating it.
    await _db
        .into(_db.recentSearches)
        .insertOnConflictUpdate(
          RecentSearchesCompanion.insert(
            query: trimmed,
            searchedAt: _clock.now().toUtc(),
          ),
        );

    await _trim();
  }

  @override
  Future<void> remove(String query) async {
    await (_db.delete(
      _db.recentSearches,
    )..where((RecentSearches t) => t.query.equals(query))).go();
  }

  @override
  Future<void> clear() => _db.delete(_db.recentSearches).go();

  /// Drops everything past the retention limit, so the table cannot grow
  /// without bound across a long-lived install.
  Future<void> _trim() async {
    final List<RecentSearchEntry> keep =
        await (_db.select(_db.recentSearches)
              ..orderBy(<OrderingTerm Function(RecentSearches)>[
                (RecentSearches t) => OrderingTerm.desc(t.searchedAt),
              ])
              ..limit(RecentSearchRepository.maxEntries))
            .get();

    if (keep.length < RecentSearchRepository.maxEntries) return;

    final DateTime oldestKept = keep.last.searchedAt;
    await (_db.delete(_db.recentSearches)..where(
          (RecentSearches t) => t.searchedAt.isSmallerThanValue(oldestKept),
        ))
        .go();
  }
}
