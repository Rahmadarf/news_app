import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/presentation/controllers/news_feed_controller.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/features/news/presentation/widgets/category_chips.dart';
import 'package:news_app/features/news/presentation/widgets/featured_article_card.dart';
import 'package:news_app/features/news/presentation/widgets/home_greeting_header.dart';
import 'package:news_app/features/news/presentation/widgets/home_skeleton.dart';
import 'package:news_app/features/news/presentation/widgets/section_header.dart';
import 'package:news_app/l10n/app_localizations.dart';
import 'package:news_app/core/utils/relative_time.dart';

/// Home feed.
///
/// Two sections drawn from the approved repository:
///
/// * **Trending today** always reads the `general` feed, so the rail stays
///   stable while the chips filter the list below it.
/// * **Recent stories** reads the feed for the selected category.
///
/// When the selected category *is* `general` both sections read the same
/// provider instance, so nothing is fetched twice.
class NewsFeedPage extends ConsumerWidget {
  const NewsFeedPage({super.key});

  /// How many articles the trending rail shows.
  static const int trendingCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewsCategory category = ref.watch(selectedCategoryProvider);
    final NewsFeedState state = ref.watch(newsFeedControllerProvider(category));
    final NewsFeedController controller = ref.read(
      newsFeedControllerProvider(category).notifier,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: switch (state) {
            NewsFeedLoading() => ListView(
              children: <Widget>[
                HomeGreetingHeader(
                  onNotificationsTap: () => _showComingSoon(context),
                ),
                const SizedBox(height: Spacing.lg),
                const HomeSkeleton(),
              ],
            ),
            NewsFeedError(:final failure) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                HomeGreetingHeader(
                  onNotificationsTap: () => _showComingSoon(context),
                ),
                StatusView.failure(
                  l10n: l10n,
                  failure: failure,
                  onRetry: controller.retry,
                ),
              ],
            ),
            final NewsFeedReady ready => _Feed(
              category: category,
              ready: ready,
              controller: controller,
            ),
          },
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoonBody)));
  }
}

class _Feed extends ConsumerWidget {
  const _Feed({
    required this.category,
    required this.ready,
    required this.controller,
  });

  final NewsCategory category;
  final NewsFeedReady ready;
  final NewsFeedController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);

    // The trending rail is always the general feed; when that is also the
    // selected category this resolves to the very same provider instance.
    final NewsFeedState trendingState = category == NewsCategory.general
        ? ready
        : ref.watch(newsFeedControllerProvider(NewsCategory.general));
    final List<Article> trending = trendingState is NewsFeedReady
        ? trendingState.articles.take(NewsFeedPage.trendingCount).toList()
        : const <Article>[];

    final List<Article> recent = ready.articles;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: HomeGreetingHeader(
            onNotificationsTap: () => NewsFeedPage._showComingSoon(context),
          ),
        ),
        if (ready.isStale)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
            sliver: SliverToBoxAdapter(
              child: OfflineBanner(
                updatedLabel: _updatedLabel(context, l10n, ready.fetchedAt),
              ),
            ),
          ),
        if (trending.isNotEmpty) ...<Widget>[
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.trendingTodayTitle,
              trailing: TextButton(
                onPressed: () => context.go(AppRoutes.discoverPath),
                child: Text('${l10n.seeAllAction} ↗'),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _TrendingRail(articles: trending)),
        ],
        SliverToBoxAdapter(
          child: SectionHeader(
            title: l10n.recentStoriesTitle,
            trailing: IconButton(
              onPressed: () => context.go(AppRoutes.discoverPath),
              tooltip: l10n.searchLabel,
              icon: const Icon(Icons.search),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryChips(
            selected: category,
            onSelected: ref.read(selectedCategoryProvider.notifier).select,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: Spacing.sm)),
        if (recent.isEmpty)
          SliverToBoxAdapter(
            child: StatusView(
              icon: Icons.newspaper_outlined,
              title: l10n.emptyFeedTitle,
              // Names what produced the empty result. An edition with no
              // NewsAPI coverage is the usual cause, and "try again" would be
              // useless advice for it.
              message: l10n.emptyFeedBodyEdition(
                ref.watch(selectedCountryProvider).label,
                categoryLabel(l10n, category),
              ),
              actionLabel: l10n.changeEditionAction,
              onAction: () => context.go(AppRoutes.settingsPath),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
            sliver: SliverList.builder(
              itemCount: recent.length,
              itemBuilder: (BuildContext context, int index) {
                final Article article = recent[index];
                return ArticleRow(
                  article: article,
                  eyebrow: categoryLabel(l10n, category),
                  showDivider: index != recent.length - 1,
                  onTap: () => _openArticle(context, article),
                );
              },
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.lg,
              Spacing.gutter,
              0,
            ),
            child: _FeedFooter(ready: ready, controller: controller),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
            child: Text(
              l10n.homeFooterTagline,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: tokens.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  void _openArticle(BuildContext context, Article article) {
    context.push(
      AppRoutes.article(article.url, category: category),
      extra: article,
    );
  }

  static String? _updatedLabel(
    BuildContext context,
    AppLocalizations l10n,
    DateTime? fetchedAt,
  ) {
    if (fetchedAt == null) return null;
    final String locale = Localizations.localeOf(context).languageCode;
    return l10n.lastUpdatedLabel(formatRelativeTime(fetchedAt, locale));
  }
}

class _TrendingRail extends StatelessWidget {
  const _TrendingRail({required this.articles});

  final List<Article> articles;

  @override
  Widget build(BuildContext context) {
    // Height is intrinsic so the rail grows with the text scale instead of
    // clipping the serif titles.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final Article article in articles) ...<Widget>[
              FeaturedArticleCard(
                article: article,
                onTap: () => context.push(
                  AppRoutes.article(article.url),
                  extra: article,
                ),
              ),
              if (article != articles.last)
                const SizedBox(width: Spacing.featuredGap),
            ],
          ],
        ),
      ),
    );
  }
}

/// Load-more control, page-failure notice, or end-of-feed spacing.
class _FeedFooter extends StatelessWidget {
  const _FeedFooter({required this.ready, required this.controller});

  final NewsFeedReady ready;
  final NewsFeedController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (ready.pageFailure != null) {
      return Column(
        children: <Widget>[
          Text(
            describeFailure(l10n, ready.pageFailure!).title,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          OutlinedButton(
            onPressed: controller.loadMore,
            child: Text(l10n.retryAction),
          ),
        ],
      );
    }

    if (ready.isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(Spacing.md),
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!ready.hasMore) return const SizedBox.shrink();

    return OutlinedButton(
      onPressed: controller.loadMore,
      child: Text(l10n.loadMoreAction),
    );
  }
}
