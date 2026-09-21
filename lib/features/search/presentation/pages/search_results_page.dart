import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/widgets/article_list_shimmer.dart';
import 'package:news_app/features/news/presentation/widgets/article_list_view.dart';
import 'package:news_app/features/search/presentation/controllers/search_controller.dart';
import 'package:news_app/features/search/presentation/state/search_state.dart';

/// Results for one query.
///
/// Its own route and its own state, so refreshing here re-runs the search
/// instead of silently falling back to a category feed. See docs/AUDIT.md H-6.
class SearchResultsPage extends ConsumerWidget {
  const SearchResultsPage({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Search')),
        body: const EmptyView(
          icon: Icons.search_off,
          title: 'No search term',
          message: 'Go back and enter something to search for.',
        ),
      );
    }

    final SearchState state = ref.watch(searchControllerProvider(query));
    final SearchResultsController controller = ref.read(
      searchControllerProvider(query).notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text('“$query”')),
      body: switch (state) {
        SearchLoading() => const ArticleListShimmer(),
        SearchError(:final failure) => FailureView(
          failure: failure,
          onRetry: controller.refresh,
        ),
        SearchReady(isEmpty: true) => const EmptyView(
          icon: Icons.search_off,
          title: 'No matches',
          message: 'Try a different search term.',
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
    );
  }
}
