import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/presentation/controllers/news_feed_controller.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';
import 'package:news_app/features/news/presentation/widgets/article_list_shimmer.dart';
import 'package:news_app/features/news/presentation/widgets/article_list_view.dart';
import 'package:news_app/features/news/presentation/widgets/category_selector.dart';
import 'package:news_app/features/search/presentation/widgets/search_dialog.dart';

class NewsFeedPage extends ConsumerWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NewsCategory category = ref.watch(selectedCategoryProvider);
    final NewsFeedState state = ref.watch(newsFeedControllerProvider(category));
    final NewsFeedController controller = ref.read(
      newsFeedControllerProvider(category).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          CategorySelector(
            selected: category,
            onSelected: ref.read(selectedCategoryProvider.notifier).select,
          ),
          Expanded(
            child: switch (state) {
              NewsFeedLoading() => const ArticleListShimmer(),
              NewsFeedError(:final failure) => FailureView(
                failure: failure,
                onRetry: controller.retry,
              ),
              NewsFeedReady(isEmpty: true) => RefreshIndicator(
                onRefresh: controller.refresh,
                child: const _ScrollableEmpty(
                  title: 'No news available',
                  message: 'Please try again later.',
                ),
              ),
              final NewsFeedReady ready => RefreshIndicator(
                onRefresh: controller.refresh,
                child: ArticleListView(
                  articles: ready.articles,
                  hasMore: ready.hasMore,
                  isLoadingMore: ready.isLoadingMore,
                  pageFailure: ready.pageFailure,
                  onLoadMore: controller.loadMore,
                  onArticleTap: (Article article) =>
                      _openArticle(context, article),
                  header: ready.isStale ? const _OfflineBanner() : null,
                ),
              ),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final String? query = await showSearchDialog(context);
    if (query == null || !context.mounted) return;
    context.push(AppRoutes.search(query));
  }

  void _openArticle(BuildContext context, Article article) {
    context.push(AppRoutes.article(article.url), extra: article);
  }
}

/// Empty state that still scrolls, so pull-to-refresh keeps working.
class _ScrollableEmpty extends StatelessWidget {
  const _ScrollableEmpty({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: EmptyView(title: title, message: message),
          ),
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.cloud_off, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing saved articles. Pull to refresh when you are back '
              'online.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
