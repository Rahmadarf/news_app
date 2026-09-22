import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/features/news/presentation/widgets/home_skeleton.dart';
import 'package:news_app/features/news/presentation/widgets/section_header.dart';
import 'package:news_app/features/search/presentation/controllers/discover_controller.dart';
import 'package:news_app/features/search/presentation/state/discover_state.dart';
import 'package:news_app/features/search/presentation/widgets/search_field.dart';
import 'package:news_app/features/search/presentation/widgets/sort_selector.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Discover: search field, recent searches, topic shortcuts, and results.
///
/// Typing is debounced and every request is generation-tagged, so a slow
/// answer to an older query can never replace a newer one. Only submitted
/// terms are remembered.
class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  /// Topic shortcuts. These run a real search rather than implying a follow
  /// relationship; there is no account service behind Discover.
  static const List<String> topicShortcuts = <String>[
    'teknologi',
    'ekonomi',
    'energi',
    'kesehatan',
    'transportasi',
    'olahraga',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DiscoverState state = ref.watch(discoverControllerProvider);
    final DiscoverController controller = ref.read(
      discoverControllerProvider.notifier,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.md,
                Spacing.gutter,
                Spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.discoverTab,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  SearchField(
                    value: state.query,
                    onChanged: controller.queryChanged,
                    onSubmitted: controller.submit,
                    onCleared: controller.clear,
                  ),
                ],
              ),
            ),
            if (state.hasQuery) ...<Widget>[
              SortSelector(
                selected: state.sort,
                onSelected: controller.sortChanged,
              ),
              const SizedBox(height: Spacing.sm),
            ],
            Expanded(
              child: switch (state.results) {
                DiscoverIdle() => _IdleView(onSearch: controller.submit),
                DiscoverLoading() => const HomeSkeleton(),
                DiscoverError(:final failure) => StatusView.failure(
                  l10n: l10n,
                  failure: failure,
                  onRetry: controller.refresh,
                ),
                DiscoverReady(isEmpty: true) => StatusView(
                  icon: Icons.search_off,
                  title: l10n.searchEmptyTitle,
                  message: l10n.searchEmptyBody,
                  actionLabel: l10n.clearSearchAction,
                  onAction: controller.clear,
                ),
                final DiscoverReady ready => _ResultsView(
                  ready: ready,
                  controller: controller,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent searches and topic shortcuts, shown before anything is typed.
class _IdleView extends ConsumerWidget {
  const _IdleView({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);
    final List<String> recent =
        ref.watch(recentSearchesProvider).value ?? const <String>[];

    return ListView(
      children: <Widget>[
        if (recent.isNotEmpty) ...<Widget>[
          SectionHeader(
            title: l10n.recentSearchesTitle,
            trailing: TextButton(
              onPressed: () => ref.read(recentSearchRepositoryProvider).clear(),
              child: Text(l10n.clearAction),
            ),
          ),
          for (final String term in recent)
            Semantics(
              button: true,
              child: InkWell(
                onTap: () => onSearch(term),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: Dimens.minTapTarget,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.gutter,
                    vertical: Spacing.md,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.history,
                        size: 18,
                        color: tokens.textSecondary,
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          term,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref
                            .read(recentSearchRepositoryProvider)
                            .remove(term),
                        tooltip: l10n.removeRecentSearch,
                        iconSize: 18,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        SectionHeader(title: l10n.exploreTopicsTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
          child: Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: <Widget>[
              for (final String topic in DiscoverPage.topicShortcuts)
                Semantics(
                  button: true,
                  child: Material(
                    color: tokens.tintedSurface,
                    shape: const StadiumBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onSearch(topic),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: Dimens.minTapTarget,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                        ),
                        child: Text(
                          topic,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: tokens.accent,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.ready, required this.controller});

  final DiscoverReady ready;
  final DiscoverController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          final ScrollMetrics m = notification.metrics;
          if (m.axis != Axis.vertical) return false;
          if (m.maxScrollExtent - m.pixels < 400) controller.loadMore();
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
          itemCount: ready.articles.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: Text(
                  l10n.searchResultCount(ready.totalResults),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            }

            final int articleIndex = index - 1;
            if (articleIndex < ready.articles.length) {
              final Article article = ready.articles[articleIndex];
              return ArticleRow(
                article: article,
                showDivider: articleIndex != ready.articles.length - 1,
                onTap: () => context.push(
                  AppRoutes.article(article.url),
                  extra: article,
                ),
              );
            }

            return _ResultsFooter(ready: ready, controller: controller);
          },
        ),
      ),
    );
  }
}

class _ResultsFooter extends StatelessWidget {
  const _ResultsFooter({required this.ready, required this.controller});

  final DiscoverReady ready;
  final DiscoverController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (ready.pageFailure != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
        child: Column(
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
        ),
      );
    }

    if (ready.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.xl),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return const SizedBox(height: Spacing.xxl);
  }
}
