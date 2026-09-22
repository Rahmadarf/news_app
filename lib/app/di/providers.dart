/// Application-wide dependency graph.
///
/// Every provider here is application-scoped and long-lived. Feature state is
/// declared next to its feature and is `autoDispose`.
///
/// ```
/// appConfigProvider ──┬─► httpClientProvider ─┐
///                     └─► newsRemoteDataSourceProvider ──┐
/// appDatabaseProvider ───► newsLocalDataSourceProvider ──┴─► newsRepositoryProvider
///                                                                   │
///                         newsFeedControllerProvider ◄──────────────┤
///                         discoverControllerProvider ◄──────────────┘
/// ```
///
/// Nothing constructs its own collaborators; tests override the providers they
/// need and get the whole graph for free.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/core/persistence/settings_store.dart';
import 'package:news_app/features/news/data/datasources/mock_news_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_api_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/domain/entities/news_country.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/history/data/repositories/reading_history_repository_impl.dart';
import 'package:news_app/features/history/domain/repositories/reading_history_repository.dart';
import 'package:news_app/features/search/data/repositories/recent_search_repository_impl.dart';
import 'package:news_app/features/search/domain/repositories/recent_search_repository.dart';

/// Thrown by a provider that bootstrap is required to override.
Never _missingOverride(String name) {
  throw StateError(
    '$name was not overridden. Call bootstrap() before runApp, or override it '
    'in the test ProviderScope.',
  );
}

/// Resolved compile-time configuration.
///
/// The default throws so a missing override is loud, never a silent fallback
/// to live mode.
final appConfigProvider = Provider<AppConfig>(
  (Ref ref) => _missingOverride('appConfigProvider'),
);

/// Open local database. Constructed by bootstrap and closed with the container.
final appDatabaseProvider = Provider<AppDatabase>(
  (Ref ref) => _missingOverride('appDatabaseProvider'),
);

/// Scalar preferences. Constructed by bootstrap.
final settingsStoreProvider = Provider<SettingsStore>(
  (Ref ref) => _missingOverride('settingsStoreProvider'),
);

/// Single shared HTTP client, closed when the container is disposed.
final httpClientProvider = Provider<http.Client>((Ref ref) {
  final http.Client client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// The active news source, selected once from configuration.
final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);

  return switch (config.dataSourceMode) {
    NewsDataSourceMode.mock => MockNewsDataSource(),
    NewsDataSourceMode.live => NewsApiDataSource(
      apiKey: config.newsApiKey,
      client: ref.watch(httpClientProvider),
    ),
  };
});

final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>(
  (Ref ref) => NewsLocalDataSource(ref.watch(appDatabaseProvider)),
);

final recentSearchRepositoryProvider = Provider<RecentSearchRepository>((
  Ref ref,
) {
  return RecentSearchRepositoryImpl(database: ref.watch(appDatabaseProvider));
});

final readingHistoryRepositoryProvider = Provider<ReadingHistoryRepository>((
  Ref ref,
) {
  return ReadingHistoryRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    local: ref.watch(newsLocalDataSourceProvider),
  );
});

final newsRepositoryProvider = Provider<NewsRepository>((Ref ref) {
  return NewsRepositoryImpl(
    remote: ref.watch(newsRemoteDataSourceProvider),
    local: ref.watch(newsLocalDataSourceProvider),
    // Watched, not read: changing the edition rebuilds the repository, and the
    // country is part of the cache key, so each edition keeps its own pages.
    country: ref.watch(selectedCountryProvider).apiValue,
  );
});

/// Category currently selected on the feed screen.
///
/// Seeded from [SettingsStore] and written back on every change, so the choice
/// survives a restart.
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryController, NewsCategory>(
      SelectedCategoryController.new,
    );

class SelectedCategoryController extends Notifier<NewsCategory> {
  @override
  NewsCategory build() {
    // fromApiValue falls back rather than throwing, so a stale or hand-edited
    // stored value cannot break start-up.
    return NewsCategory.fromApiValue(
      ref.read(settingsStoreProvider).readSelectedCategory(),
    );
  }

  void select(NewsCategory category) {
    if (state == category) return;
    state = category;
    // Best effort: failing to persist a preference must not break navigation.
    ref.read(settingsStoreProvider).writeSelectedCategory(category.apiValue);
  }
}

/// Light/dark preference. Defaults to following the system.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => _parse(ref.read(settingsStoreProvider).readThemeMode());

  void set(ThemeMode mode) {
    if (state == mode) return;
    state = mode;
    // Best effort: failing to persist a preference must not break the UI.
    ref.read(settingsStoreProvider).writeThemeMode(mode.name);
  }

  /// Unknown or absent values fall back to [ThemeMode.system] rather than
  /// throwing, so a stale stored value cannot break start-up.
  static ThemeMode _parse(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

/// Reader's own text-size multiplier for article body copy.
///
/// Combined with — never a replacement for — the system text scale. See
/// [ReadingTextScaleController.steps] for the allowed values.
final readingTextScaleProvider =
    NotifierProvider<ReadingTextScaleController, double>(
      ReadingTextScaleController.new,
    );

class ReadingTextScaleController extends Notifier<double> {
  /// Discrete steps rather than free scaling, so body copy cannot be nudged
  /// into a size that breaks the layout.
  static const List<double> steps = <double>[0.9, 1, 1.15, 1.3, 1.5];

  static const double defaultScale = 1;

  @override
  double build() {
    final double? stored = ref
        .read(settingsStoreProvider)
        .readReadingTextScale();
    // An unknown stored value snaps to the nearest allowed step rather than
    // being trusted blindly.
    return stored == null ? defaultScale : nearestStep(stored);
  }

  bool get canIncrease => state < steps.last;
  bool get canDecrease => state > steps.first;

  void increase() => _moveBy(1);
  void decrease() => _moveBy(-1);

  void _moveBy(int delta) {
    final int index = steps.indexOf(state);
    final int next = (index + delta).clamp(0, steps.length - 1);
    if (next == index) return;
    state = steps[next];
    // Best effort: failing to persist a preference must not break reading.
    ref.read(settingsStoreProvider).writeReadingTextScale(state);
  }

  static double nearestStep(double value) {
    double best = steps.first;
    for (final double step in steps) {
      if ((step - value).abs() < (best - value).abs()) best = step;
    }
    return best;
  }
}

/// Headline edition. Part of the feed cache key, so each edition caches
/// separately.
final selectedCountryProvider =
    NotifierProvider<SelectedCountryController, NewsCountry>(
      SelectedCountryController.new,
    );

class SelectedCountryController extends Notifier<NewsCountry> {
  @override
  NewsCountry build() {
    return NewsCountry.fromApiValue(
      ref.read(settingsStoreProvider).readCountry(),
    );
  }

  void select(NewsCountry country) {
    if (state == country) return;
    state = country;
    // Best effort: failing to persist a preference must not break the feed.
    ref.read(settingsStoreProvider).writeCountry(country.apiValue);
  }
}

/// Language override, or `null` to follow the device.
final appLocaleProvider = NotifierProvider<AppLocaleController, Locale?>(
  AppLocaleController.new,
);

class AppLocaleController extends Notifier<Locale?> {
  /// Languages the app ships translations for.
  static const List<Locale> supported = <Locale>[Locale('id'), Locale('en')];

  @override
  Locale? build() {
    final String? stored = ref.read(settingsStoreProvider).readLocale();
    if (stored == null) return null;
    // An unknown stored tag falls back to following the device rather than
    // leaving the app in a language it cannot render.
    return supported.any((Locale l) => l.languageCode == stored)
        ? Locale(stored)
        : null;
  }

  void select(Locale? locale) {
    if (state?.languageCode == locale?.languageCode) return;
    state = locale;
    ref.read(settingsStoreProvider).writeLocale(locale?.languageCode);
  }
}
