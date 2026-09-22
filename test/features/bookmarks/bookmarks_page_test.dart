import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:news_app/features/bookmarks/presentation/pages/bookmarks_page.dart';
import 'package:news_app/features/history/data/repositories/reading_history_repository_impl.dart';
import 'package:news_app/features/history/presentation/pages/reading_history_page.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/features/settings/presentation/pages/settings_page.dart';

import '../../support/pump_app.dart';

Article sample() => const Article(
  url: 'https://example.com/saved',
  title: 'Cerita tersimpan',
  source: ArticleSource(name: 'Mock Source'),
);

/// Scrolls the settings list until [finder] is on screen.
Future<void> scrollSettingsTo(WidgetTester tester, Finder finder) async {
  await tester.dragUntilVisible(
    finder,
    find.descendant(
      of: find.byType(SettingsPage),
      matching: find.byType(Scrollable),
    ),
    const Offset(0, -150),
  );
  await tester.pump();
}

void main() {
  late Map<String, String> fixtures;

  setUpAll(() async {
    fixtures = await loadFixtureStrings();
  });

  testWidgets('the bookmark tab shows an empty state with a way out', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, fixtures: fixtures);
    await pumpUntil(tester, find.byType(NavigationBar));

    await tester.tap(find.text('Bookmark'));
    await pumpUntil(tester, find.byType(BookmarksPage));
    await tester.pump(const Duration(milliseconds: 32));

    expect(find.text('Simpan yang berarti'), findsOneWidget);
    expect(find.text('Jelajahi berita'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('a saved article appears on the bookmark tab', (
    WidgetTester tester,
  ) async {
    final AppDatabase db = await pumpApp(tester, fixtures: fixtures);
    await pumpUntil(tester, find.byType(NavigationBar));

    final NewsLocalDataSource local = NewsLocalDataSource(db);
    await BookmarkRepositoryImpl(database: db, local: local).save(sample());

    await tester.tap(find.text('Bookmark'));
    await pumpUntil(tester, find.text('Cerita tersimpan'));

    expect(find.byType(ArticleRow), findsWidgets);

    await disposeApp(tester);
  });

  testWidgets('the settings tab lists the real preference groups', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, fixtures: fixtures);
    await pumpUntil(tester, find.byType(NavigationBar));

    await tester.tap(find.text('Settings'));
    await pumpUntil(tester, find.byType(SettingsPage));

    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Edisi'), findsOneWidget);
    expect(find.text('Bahasa'), findsOneWidget);
    expect(find.text('Ukuran teks bacaan'), findsOneWidget);

    await scrollSettingsTo(tester, find.text('Lisensi sumber terbuka'));
    expect(find.text('Lisensi sumber terbuka'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('reading history opens from settings and shows what was read', (
    WidgetTester tester,
  ) async {
    final AppDatabase db = await pumpApp(tester, fixtures: fixtures);
    await pumpUntil(tester, find.byType(NavigationBar));

    final NewsLocalDataSource local = NewsLocalDataSource(db);
    await ReadingHistoryRepositoryImpl(
      database: db,
      local: local,
    ).record(sample());

    await tester.tap(find.text('Settings'));
    await pumpUntil(tester, find.byType(SettingsPage));

    await scrollSettingsTo(tester, find.text('Reading history'));
    await tester.tap(find.text('Reading history'));
    await pumpUntil(tester, find.byType(ReadingHistoryPage));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Cerita tersimpan'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('clearing history asks first and says bookmarks are kept', (
    WidgetTester tester,
  ) async {
    final AppDatabase db = await pumpApp(tester, fixtures: fixtures);
    await pumpUntil(tester, find.byType(NavigationBar));

    final NewsLocalDataSource local = NewsLocalDataSource(db);
    await ReadingHistoryRepositoryImpl(
      database: db,
      local: local,
    ).record(sample());

    await tester.tap(find.text('Settings'));
    await pumpUntil(tester, find.byType(SettingsPage));
    await scrollSettingsTo(tester, find.text('Reading history'));
    await tester.tap(find.text('Reading history'));
    await pumpUntil(tester, find.text('Cerita tersimpan'));
    // Let the push transition finish: mid-slide the app bar action sits
    // outside the viewport and cannot be hit tested.
    await tester.pump(const Duration(milliseconds: 500));

    // Scoped to the history route: the settings route is still mounted
    // beneath it.
    await tester.tap(
      find.descendant(
        of: find.byType(ReadingHistoryPage),
        matching: find.widgetWithText(TextButton, 'Hapus'),
      ),
    );
    await pumpUntil(tester, find.text('Hapus riwayat baca?'));

    expect(
      find.textContaining('Artikel tersimpan Anda tidak terpengaruh'),
      findsOneWidget,
    );

    // Cancelling must leave the list alone.
    await tester.tap(find.text('Batal'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Cerita tersimpan'), findsOneWidget);

    await disposeApp(tester);
  });
}
