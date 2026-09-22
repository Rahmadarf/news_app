import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/persistence/settings_store.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/domain/entities/news_country.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_news_remote_data_source.dart';
import '../../support/test_database.dart';

void main() {
  Future<ProviderContainer> containerWith({
    Map<String, Object> preferences = const <String, Object>{},
    FakeNewsRemoteDataSource? remote,
  }) async {
    SharedPreferences.setMockInitialValues(preferences);
    final SettingsStore settings = await SettingsStore.open();

    final ProviderContainer container = ProviderContainer.test(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(settings),
        appDatabaseProvider.overrideWithValue(newTestDatabase()),
        if (remote != null)
          newsRemoteDataSourceProvider.overrideWithValue(remote),
      ],
    );
    return container;
  }

  group('theme mode', () {
    test('follows the system until the reader chooses', () async {
      final ProviderContainer container = await containerWith();

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('restores a stored choice', () async {
      final ProviderContainer container = await containerWith(
        preferences: <String, Object>{SettingsStore.themeModeKey: 'dark'},
      );

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test(
      'an unknown stored value falls back to following the system',
      () async {
        final ProviderContainer container = await containerWith(
          preferences: <String, Object>{SettingsStore.themeModeKey: 'sepia'},
        );

        expect(container.read(themeModeProvider), ThemeMode.system);
      },
    );

    test('persists the choice', () async {
      final ProviderContainer container = await containerWith();
      container.listen<ThemeMode>(
        themeModeProvider,
        (ThemeMode? p, ThemeMode n) {},
        fireImmediately: true,
      );

      container.read(themeModeProvider.notifier).set(ThemeMode.light);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(SettingsStore.themeModeKey), 'light');
    });
  });

  group('language', () {
    test('follows the device until the reader chooses', () async {
      final ProviderContainer container = await containerWith();

      expect(container.read(appLocaleProvider), isNull);
    });

    test('restores a supported stored language', () async {
      final ProviderContainer container = await containerWith(
        preferences: <String, Object>{SettingsStore.localeKey: 'en'},
      );

      expect(container.read(appLocaleProvider)?.languageCode, 'en');
    });

    test('an unsupported stored language falls back to the device', () async {
      final ProviderContainer container = await containerWith(
        preferences: <String, Object>{SettingsStore.localeKey: 'fr'},
      );

      expect(container.read(appLocaleProvider), isNull);
    });
  });

  group('edition', () {
    test('defaults to an edition NewsAPI actually serves', () async {
      final ProviderContainer container = await containerWith();

      expect(container.read(selectedCountryProvider), NewsCountry.fallback);
      expect(
        NewsCountry.fallback,
        isNot(NewsCountry.indonesia),
        reason:
            'NewsAPI top-headlines coverage for country=id is thin to empty, '
            'so defaulting to it hands a new reader a blank feed',
      );
    });

    test('an unknown stored code falls back rather than throwing', () async {
      final ProviderContainer container = await containerWith(
        preferences: <String, Object>{SettingsStore.countryKey: 'zz'},
      );

      expect(container.read(selectedCountryProvider), NewsCountry.fallback);
    });

    test('the chosen edition reaches the API as the country', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 5,
        articlesPerPage: 5,
      );
      final ProviderContainer container = await containerWith(
        preferences: <String, Object>{
          SettingsStore.countryKey: NewsCountry.singapore.apiValue,
        },
        remote: remote,
      );

      await container
          .read(newsRepositoryProvider)
          .getTopHeadlines(category: NewsCategory.general);

      expect(remote.lastCountry, 'sg');
    });

    test('each edition caches separately', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 5,
        articlesPerPage: 5,
      );
      final ProviderContainer container = await containerWith(remote: remote);
      container.listen<NewsCountry>(
        selectedCountryProvider,
        (NewsCountry? p, NewsCountry n) {},
        fireImmediately: true,
      );

      final NewsRepository first = container.read(newsRepositoryProvider);
      await first.getTopHeadlines(category: NewsCategory.general);

      container
          .read(selectedCountryProvider.notifier)
          .select(NewsCountry.japan);

      // Changing the edition rebuilds the repository, and the country is part
      // of the cache key, so the new edition fetches rather than reusing the
      // previous edition's cached page.
      final NewsRepository second = container.read(newsRepositoryProvider);
      await second.getTopHeadlines(category: NewsCategory.general);

      expect(remote.headlineCallCount, 2);
      expect(remote.lastCountry, 'jp');
    });
  });

  group('clearing the cache', () {
    test('empties the feed cache so the next read fetches again', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 5,
        articlesPerPage: 5,
      );
      final ProviderContainer container = await containerWith(remote: remote);
      final NewsRepository repository = container.read(newsRepositoryProvider);

      await repository.getTopHeadlines(category: NewsCategory.general);
      await repository.clearCache();
      await repository.getTopHeadlines(category: NewsCategory.general);

      expect(remote.headlineCallCount, 2);
    });

    test('a storage failure surfaces as a typed CacheFailure', () async {
      final ProviderContainer container = await containerWith(
        remote: FakeNewsRemoteDataSource(totalResults: 5, articlesPerPage: 5),
      );
      final NewsRepository repository = container.read(newsRepositoryProvider);

      // Use the database first: closing one that was never opened is a no-op
      // in Drift, and a later query would simply open it again.
      await repository.getTopHeadlines(category: NewsCategory.general);

      // Close the database under the repository to force a storage error.
      await container.read(appDatabaseProvider).close();

      Object? caught;
      try {
        await repository.clearCache();
      } on Object catch (error) {
        caught = error;
      }

      expect(caught, isA<CacheFailure>());
    });
  });
}
