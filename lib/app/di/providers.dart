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
///                         searchControllerProvider   ◄──────────────┘
/// ```
///
/// Nothing constructs its own collaborators; tests override the providers they
/// need and get the whole graph for free.
library;

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
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

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

final newsRepositoryProvider = Provider<NewsRepository>((Ref ref) {
  return NewsRepositoryImpl(
    remote: ref.watch(newsRemoteDataSourceProvider),
    local: ref.watch(newsLocalDataSourceProvider),
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
