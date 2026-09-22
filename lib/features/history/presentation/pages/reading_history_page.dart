import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/core/widgets/confirm_dialog.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Articles the reader has opened, most recent first.
final readingHistoryProvider = StreamProvider<List<Article>>((Ref ref) {
  return ref.watch(readingHistoryRepositoryProvider).watchRecent();
});

/// Reading history, reached from Settings.
class ReadingHistoryPage extends ConsumerWidget {
  const ReadingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Article>> history = ref.watch(readingHistoryProvider);
    final List<Article> articles = history.value ?? const <Article>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readingHistoryTitle),
        actions: <Widget>[
          if (articles.isNotEmpty)
            TextButton(
              onPressed: () => _clear(context, ref),
              child: Text(l10n.clearAction),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: switch (history) {
          AsyncError<List<Article>>() => StatusView(
            icon: Icons.error_outline,
            title: l10n.errorCacheTitle,
            message: l10n.errorCacheBody,
          ),
          AsyncData<List<Article>>(value: final List<Article> items)
              when items.isEmpty =>
            StatusView(
              icon: Icons.history,
              title: l10n.historyEmptyTitle,
              message: l10n.historyEmptyBody,
              actionLabel: l10n.exploreAction,
              onAction: () => context.go(AppRoutes.feedPath),
            ),
          AsyncData<List<Article>>(value: final List<Article> items) =>
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) => ArticleRow(
                article: items[index],
                showDivider: index != items.length - 1,
                onTap: () => context.push(
                  AppRoutes.article(items[index].url),
                  extra: items[index],
                ),
              ),
            ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool confirmed = await confirmAction(
      context,
      title: l10n.clearHistoryTitle,
      // States plainly that bookmarks are unaffected, because a reader cannot
      // be expected to know which store this clears.
      message: l10n.clearHistoryBody,
      confirmLabel: l10n.clearAction,
    );
    if (!confirmed) return;

    await ref.read(readingHistoryRepositoryProvider).clear();
  }
}
