import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/app/widgets/home_shell.dart';
import 'package:news_app/features/article_detail/presentation/pages/article_detail_page.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/presentation/pages/news_feed_page.dart';
import 'package:news_app/features/search/presentation/pages/discover_page.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Builds the application router.
///
/// The four tabs live in a [StatefulShellRoute] so each keeps its own stack
/// and scroll position. The article screen is pushed on the root navigator,
/// which is what hides the bottom bar while reading.
///
/// Every argument is read defensively. `GoRouterState.extra` is `Object?` and
/// is empty after a deep link, a hot restart, or a browser reload, so no
/// builder casts it; the article screen falls back to its URL parameter and
/// then to the local cache. See docs/AUDIT.md H-10.
GoRouter createRouter({String? initialLocation}) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation ?? AppRoutes.feedPath,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => HomeShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.feedName,
                path: AppRoutes.feedPath,
                builder: (BuildContext context, GoRouterState state) =>
                    const NewsFeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.discoverName,
                path: AppRoutes.discoverPath,
                builder: (BuildContext context, GoRouterState state) =>
                    const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.bookmarksName,
                path: AppRoutes.bookmarksPath,
                builder: (BuildContext context, GoRouterState state) =>
                    ComingSoonPage(
                      title: AppLocalizations.of(context).bookmarkTab,
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.settingsName,
                path: AppRoutes.settingsPath,
                builder: (BuildContext context, GoRouterState state) =>
                    ComingSoonPage(
                      title: AppLocalizations.of(context).settingsTab,
                    ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: AppRoutes.articleName,
        path: AppRoutes.articlePath,
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          // Checked, never cast: extra is a fast path, the URL is the contract.
          final Object? extra = state.extra;
          final Article? article = extra is Article ? extra : null;
          final String? articleUrl =
              article?.url ?? state.uri.queryParameters[AppRoutes.urlParam];

          final String? rawCategory =
              state.uri.queryParameters[AppRoutes.categoryParam];
          final NewsCategory? category = rawCategory == null
              ? null
              : NewsCategory.fromApiValue(rawCategory);

          return ArticleDetailPage(
            article: article,
            articleUrl: articleUrl,
            category: category,
          );
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
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            location,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
