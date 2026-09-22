import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/bookmarks/presentation/widgets/bookmark_button.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/features/news/presentation/widgets/home_skeleton.dart';

import '../../../support/fake_news_remote_data_source.dart';
import '../../../support/pump_app.dart';
import '../../../support/test_database.dart';

void main() {
  late Map<String, String> fixtures;

  setUpAll(() async {
    fixtures = await loadFixtureStrings();
  });

  /// Overrides the repository with one backed by [remote] plus a fresh
  /// in-memory database, so a test can choose the feed outcome.
  List<Override> repositoryWith(FakeNewsRemoteDataSource remote) {
    final AppDatabase db = newTestDatabase();
    return <Override>[
      newsRepositoryProvider.overrideWithValue(
        NewsRepositoryImpl(
          remote: remote,
          local: NewsLocalDataSource(db),
          pageSize: 5,
        ),
      ),
    ];
  }

  testWidgets('shows the skeleton on the first frame', (
    WidgetTester tester,
  ) async {
    // pumpApp already produced the first frame; the feed request is still in
    // flight at this point.
    await pumpApp(tester, fixtures: fixtures);

    expect(find.byType(HomeSkeleton), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('shows an error state with a retry action', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      fixtures: fixtures,
      extraOverrides: repositoryWith(
        FakeNewsRemoteDataSource(throwOnCall: const SocketException('offline')),
      ),
    );
    await pumpUntil(tester, find.byType(StatusView));

    expect(find.text('Anda sedang offline'), findsOneWidget);
    expect(find.text('Coba lagi'), findsWidgets);

    await disposeApp(tester);
  });

  testWidgets('shows an empty state when the feed has no stories', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      fixtures: fixtures,
      extraOverrides: repositoryWith(
        FakeNewsRemoteDataSource(totalResults: 0, articlesPerPage: 0),
      ),
    );
    await pumpUntil(tester, find.byType(StatusView));

    expect(find.text('Belum ada cerita di sini'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('offers a load-more control while further pages exist', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      fixtures: fixtures,
      extraOverrides: repositoryWith(
        FakeNewsRemoteDataSource(
          totalResults: 40,
          articlesPerPage: 5,
          uniquePerPage: true,
        ),
      ),
    );
    await pumpUntil(tester, find.byType(ArticleRow));

    // Drag the vertical feed, not the horizontal trending rail.
    final Finder feed = find.byType(CustomScrollView);
    for (int i = 0; i < 12; i++) {
      await tester.drag(feed, const Offset(0, -400));
      await tester.pump();
      if (find.text('Muat berita lainnya').evaluate().isNotEmpty) break;
    }

    expect(find.text('Muat berita lainnya'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('bookmarking a story updates every save control for it', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, fixtures: fixtures);
    await pumpUntil(tester, find.byType(ArticleRow));

    final Finder firstRowBookmark = find
        .descendant(
          of: find.byType(ArticleRow).first,
          matching: find.byType(BookmarkButton),
        )
        .first;

    expect(
      tester.widget<IconButton>(
        find.descendant(
          of: firstRowBookmark,
          matching: find.byType(IconButton),
        ),
      ),
      isA<IconButton>().having(
        (IconButton b) => b.isSelected,
        'isSelected',
        isFalse,
      ),
    );

    await tester.tap(firstRowBookmark);
    await pumpUntil(tester, find.byIcon(Icons.bookmark));

    expect(find.byIcon(Icons.bookmark), findsWidgets);

    await disposeApp(tester);
  });
}
