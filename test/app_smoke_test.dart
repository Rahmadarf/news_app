import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/app.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/persistence/settings_store.dart';
import 'package:news_app/features/news/data/datasources/mock_news_data_source.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/presentation/widgets/article_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';
import 'support/test_database.dart';

/// Boots the real dependency graph in mock mode: the committed fixtures, the
/// real mapper, an in-memory database, and mocked preferences. No network.
///
/// The fixtures are read once, before the widget tests run, and handed to the
/// data source as strings. Doing real asset or file I/O inside `testWidgets`
/// is unreliable — the read does not complete under the second test's fake
/// async zone — and it would add nothing here: the loader itself is covered by
/// the data-source tests.
Future<void> pumpApp(
  WidgetTester tester,
  SettingsStore settings,
  Map<String, String> fixtures,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        appConfigProvider.overrideWithValue(
          AppConfig.from(rawMode: 'mock', rawApiKey: ''),
        ),
        appDatabaseProvider.overrideWithValue(newTestDatabase()),
        settingsStoreProvider.overrideWithValue(settings),
        newsRemoteDataSourceProvider.overrideWithValue(
          MockNewsDataSource(loadFixture: (String key) async => fixtures[key]!),
        ),
      ],
      child: const NewsApp(),
    ),
  );
}

/// Pumps until [finder] matches.
///
/// `pumpAndSettle` cannot be used: the loading shimmer animates forever, so
/// the tree never settles.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 60,
}) async {
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

void main() {
  late Map<String, String> fixtures;

  setUpAll(() async {
    fixtures = <String, String>{
      MockNewsDataSource.headlinesFixture: await loadFixtureFromDisk(
        MockNewsDataSource.headlinesFixture,
      ),
      MockNewsDataSource.searchFixture: await loadFixtureFromDisk(
        MockNewsDataSource.searchFixture,
      ),
    };
  });

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('app boots into the headline feed backed by the fixtures', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, await SettingsStore.open(), fixtures);
    await pumpUntil(tester, find.byType(ArticleCard));

    expect(find.text('News App'), findsOneWidget);
    expect(find.text('Mock general headline 1'), findsOneWidget);

    // The fixture's "[Removed]" tombstone must never reach the UI.
    expect(find.textContaining('[Removed]'), findsNothing);
  });

  testWidgets('a stored category preference is restored at start-up', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SettingsStore.selectedCategoryKey: NewsCategory.sports.apiValue,
    });

    await pumpApp(tester, await SettingsStore.open(), fixtures);
    await pumpUntil(tester, find.byType(ArticleCard));

    final FilterChip selected = tester
        .widgetList<FilterChip>(find.byType(FilterChip))
        .firstWhere((FilterChip chip) => chip.selected);

    expect((selected.label as Text).data, NewsCategory.sports.label);
  });

  testWidgets('an unusable configuration shows the error screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ConfigurationErrorApp(
        error: ConfigurationError(summary: 'missing key', remedy: 'pass one'),
      ),
    );
    await tester.pump();

    expect(find.text('Configuration error'), findsOneWidget);
    expect(find.text('missing key'), findsOneWidget);
    expect(find.text('pass one'), findsOneWidget);
  });
}
