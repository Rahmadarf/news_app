import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Articles seen by the app, keyed by canonical URL.
///
/// One row per article regardless of how many feeds or pages contain it, which
/// is what makes deduplication a storage-level guarantee rather than a
/// convention.
class CachedArticles extends Table {
  TextColumn get url => text()();
  TextColumn get title => text()();
  TextColumn get sourceName => text()();
  TextColumn get sourceId => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get content => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{url};
}

/// Ordered membership of an article in one page of one feed.
///
/// `feedKey` identifies the feed (country + category); `position` preserves the
/// order the source returned.
class FeedEntries extends Table {
  TextColumn get feedKey => text()();
  IntColumn get page => integer()();
  IntColumn get position => integer()();
  TextColumn get articleUrl =>
      text().references(CachedArticles, #url, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    feedKey,
    page,
    position,
  };
}

/// Freshness and paging metadata for one cached page.
class FeedPageMetadata extends Table {
  TextColumn get feedKey => text()();
  IntColumn get page => integer()();

  /// When the page was retrieved from the remote source. Drives the TTL.
  DateTimeColumn get fetchedAt => dateTime()();
  IntColumn get totalResults => integer()();
  BoolColumn get hasMore => boolean()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{feedKey, page};
}

/// Groundwork for the bookmarks feature. No UI reads this yet.
class Bookmarks extends Table {
  TextColumn get articleUrl =>
      text().references(CachedArticles, #url, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{articleUrl};
}

/// Groundwork for reading history. No UI reads this yet.
class ReadingHistoryEntries extends Table {
  TextColumn get articleUrl =>
      text().references(CachedArticles, #url, onDelete: KeyAction.cascade)();
  DateTimeColumn get viewedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{articleUrl};
}

/// Recently submitted search terms, most recent first.
///
/// The explicit data-class name avoids Drift's awkward singularisation of
/// "RecentSearches".
@DataClassName('RecentSearchEntry')
class RecentSearches extends Table {
  TextColumn get query => text()();
  DateTimeColumn get searchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{query};
}

/// Local database.
///
/// Feed caching is the only part exercised today. The bookmark, history, and
/// recent-search tables exist so those features can be added without a schema
/// migration; nothing writes to them yet.
///
/// Search results are deliberately **not** cached. A search cache grows without
/// bound across distinct queries, and stale search results are more misleading
/// than stale headlines because the user just expressed a fresh intent.
@DriftDatabase(
  tables: <Type>[
    CachedArticles,
    FeedEntries,
    FeedPageMetadata,
    Bookmarks,
    ReadingHistoryEntries,
    RecentSearches,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    beforeOpen: (OpeningDetails details) async {
      // Required for the ON DELETE CASCADE relationships above.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
