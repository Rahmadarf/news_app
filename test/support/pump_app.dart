import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/app.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/core/persistence/settings_store.dart';
import 'package:news_app/features/news/data/datasources/mock_news_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';
import 'test_database.dart';

/// Logical size used by widget tests: a typical phone rather than the 800×600
/// default, so a feed row is on screen without scrolling.
const Size kTestPhoneSize = Size(390, 844);

/// Fixture JSON read once per suite, so widget tests never do asset or file
/// I/O of their own. Real I/O inside `testWidgets` never completes under the
/// fake async zone; the loader itself is covered by the data-source tests.
Future<Map<String, String>> loadFixtureStrings() async {
  return <String, String>{
    MockNewsDataSource.headlinesFixture: await loadFixtureFromDisk(
      MockNewsDataSource.headlinesFixture,
    ),
    MockNewsDataSource.searchFixture: await loadFixtureFromDisk(
      MockNewsDataSource.searchFixture,
    ),
  };
}

/// Boots the real application graph in mock mode with an in-memory database.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  required Map<String, String> fixtures,
  Map<String, Object> preferences = const <String, Object>{},
  List<Override> extraOverrides = const <Override>[],
  Size size = kTestPhoneSize,
  double textScale = 1,
  Locale locale = const Locale('id'),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // Indonesian is the product default; pin it so assertions do not depend on
  // the host's locale.
  tester.platformDispatcher.localesTestValue = <Locale>[locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  SharedPreferences.setMockInitialValues(preferences);
  final SettingsStore settings = await SettingsStore.open();
  final AppDatabase database = newTestDatabase();

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: ProviderScope(
        overrides: <Override>[
          appConfigProvider.overrideWithValue(
            AppConfig.from(rawMode: 'mock', rawApiKey: ''),
          ),
          appDatabaseProvider.overrideWithValue(database),
          settingsStoreProvider.overrideWithValue(settings),
          newsRemoteDataSourceProvider.overrideWithValue(
            MockNewsDataSource(
              loadFixture: (String key) async => fixtures[key]!,
            ),
          ),
          ...extraOverrides,
        ],
        child: const NewsApp(),
      ),
    ),
  );

  return database;
}

/// Tears the tree down *inside* the test body.
///
/// Drift's query streams schedule a zero-duration timer when their last
/// listener goes away. `addTearDown` runs after the framework has already
/// checked for pending timers, so the disposal has to happen here instead.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Fake time has to advance for a zero-duration timer to fire.
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}

/// Pumps until [finder] matches.
///
/// `pumpAndSettle` cannot be used: the loading skeleton animates continuously,
/// so the tree never settles.
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
