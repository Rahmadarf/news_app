import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/features/article_detail/presentation/pages/article_detail_page.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/pages/news_feed_page.dart';
import 'package:news_app/features/search/presentation/pages/search_results_page.dart';

/// Builds the application router.
///
/// Every argument is read defensively. `GoRouterState.extra` is `Object?` and
/// is empty after a deep link, a hot restart, or a browser reload, so no
/// builder casts it; the article screen falls back to its URL parameter
/// instead of throwing. See docs/AUDIT.md H-10.
GoRouter createRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? AppRoutes.feedPath,
    routes: <RouteBase>[
      GoRoute(
        name: AppRoutes.feedName,
        path: AppRoutes.feedPath,
        builder: (BuildContext context, GoRouterState state) =>
            const NewsFeedPage(),
      ),
      GoRoute(
        name: AppRoutes.searchName,
        path: AppRoutes.searchPath,
        builder: (BuildContext context, GoRouterState state) {
          final String query =
              state.uri.queryParameters[AppRoutes.queryParam]?.trim() ?? '';
          return SearchResultsPage(query: query);
        },
      ),
      GoRoute(
        name: AppRoutes.articleName,
        path: AppRoutes.articlePath,
        builder: (BuildContext context, GoRouterState state) {
          // Checked, never cast: extra is a fast path, the URL is the contract.
          final Object? extra = state.extra;
          final Article? article = extra is Article ? extra : null;
          final String? articleUrl =
              article?.url ?? state.uri.queryParameters[AppRoutes.urlParam];

          return ArticleDetailPage(article: article, articleUrl: articleUrl);
        },
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        _RouteNotFoundPage(location: state.uri.toString()),
  );
}

class _RouteNotFoundPage extends StatelessWidget {
  const _RouteNotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No screen matches $location',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
