import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/widgets/article_list_view.dart';
import 'package:news_app/features/news/presentation/widgets/home_skeleton.dart';
import 'package:news_app/features/search/presentation/controllers/search_controller.dart';
import 'package:news_app/features/search/presentation/state/search_state.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Results for one query.
///
/// Its own route and its own state, so refreshing here re-runs the search
/// instead of silently falling back to a category feed. See docs/AUDIT.md H-6.
///
/// The Discover experience from the approved design — search field, recent
/// searches, publishers, debounce, and sort — is a later stage; this screen is
/// the functional list carried over from the architecture work.
class SearchResultsPage extends ConsumerWidget {
  const SearchResultsPage({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (query.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.searchLabel)),
        body: SafeArea(
          child: StatusView(
            icon: Icons.search_off,
            title: l10n.emptyFeedTitle,
            message: l10n.emptyFeedBody,
          ),
        ),
      );
    }

    final SearchState state = ref.watch(searchControllerProvider(query));
    final SearchResultsController controller = ref.read(
      searchControllerProvider(query).notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text('“$query”')),
      body: SafeArea(
        child: switch (state) {
          SearchLoading() => const HomeSkeleton(),
          SearchError(:final failure) => StatusView.failure(
            l10n: l10n,
            failure: failure,
            onRetry: controller.refresh,
          ),
          SearchReady(isEmpty: true) => StatusView(
            icon: Icons.search_off,
            title: l10n.emptyFeedTitle,
            message: l10n.emptyFeedBody,
            actionLabel: l10n.retryAction,
            onAction: controller.refresh,
          ),
          final SearchReady ready => RefreshIndicator(
            onRefresh: controller.refresh,
            child: ArticleListView(
              articles: ready.articles,
              hasMore: ready.hasMore,
              isLoadingMore: ready.isLoadingMore,
              pageFailure: ready.pageFailure,
              onLoadMore: controller.loadMore,
              onArticleTap: (Article article) =>
                  context.push(AppRoutes.article(article.url), extra: article),
            ),
          ),
        },
      ),
    );
  }
}
