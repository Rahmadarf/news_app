/// Application-wide dependency graph.
///
/// Every provider here is application-scoped and long-lived. Feature state is
/// declared next to its feature and is `autoDispose`.
///
/// ```
/// appConfigProvider ──┬─► httpClientProvider ──┐
///                     └─► newsRemoteDataSourceProvider ──► newsRepositoryProvider
///                                                              │
///                            newsFeedControllerProvider ◄──────┤
///                            searchControllerProvider    ◄──────┘
/// ```
///
/// Nothing constructs its own collaborators; tests override the providers they
/// need and get the whole graph for free.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/features/news/data/datasources/mock_news_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_api_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';

/// Resolved compile-time configuration.
///
/// Overridden in `bootstrap()` with the validated instance, and in tests with
/// a fixed one. The default throws so a missing override is loud, never a
/// silent fallback to live mode.
final appConfigProvider = Provider<AppConfig>((Ref ref) {
  throw StateError(
    'appConfigProvider was not overridden. Call bootstrap() before runApp, or '
    'override it in the test ProviderScope.',
  );
});

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
    NewsDataSourceMode.mock => const MockNewsDataSource(),
    NewsDataSourceMode.live => NewsApiDataSource(
      apiKey: config.newsApiKey,
      client: ref.watch(httpClientProvider),
    ),
  };
});

final newsRepositoryProvider = Provider<NewsRepository>((Ref ref) {
  return NewsRepositoryImpl(remote: ref.watch(newsRemoteDataSourceProvider));
});

/// Category currently selected on the feed screen.
///
/// Application-scoped so the choice survives navigating to an article and
/// back; it becomes a persisted setting once the settings feature lands.
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryController, NewsCategory>(
      SelectedCategoryController.new,
    );

class SelectedCategoryController extends Notifier<NewsCategory> {
  @override
  NewsCategory build() => NewsCategory.fallback;

  void select(NewsCategory category) => state = category;
}
