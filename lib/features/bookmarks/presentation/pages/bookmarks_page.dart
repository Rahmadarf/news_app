import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/core/widgets/confirm_dialog.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/bookmarks/domain/entities/saved_article.dart';
import 'package:news_app/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:news_app/features/bookmarks/presentation/controllers/bookmark_providers.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Saved articles, filterable by collection.
class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> collections =
        ref.watch(collectionsProvider).value ?? const <String>[];
    final String? selected = ref.watch(selectedCollectionProvider);
    final AsyncValue<List<SavedArticle>> saved = ref.watch(
      savedArticlesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookmarkTab),
        actions: <Widget>[
          IconButton(
            onPressed: () => _createCollection(context, ref),
            tooltip: l10n.newCollection,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: <Widget>[
            _CollectionChips(
              collections: collections,
              selected: selected,
              onSelected: ref.read(selectedCollectionProvider.notifier).select,
              onDelete: (String name) => _deleteCollection(context, ref, name),
            ),
            const SizedBox(height: Spacing.sm),
            Expanded(
              child: switch (saved) {
                AsyncError<List<SavedArticle>>() => StatusView(
                  icon: Icons.error_outline,
                  title: l10n.errorCacheTitle,
                  message: l10n.errorCacheBody,
                ),
                AsyncData<List<SavedArticle>>(
                  value: final List<SavedArticle> items,
                )
                    when items.isEmpty =>
                  StatusView(
                    icon: Icons.bookmark_border,
                    title: selected == null
                        ? l10n.bookmarksEmptyTitle
                        : l10n.collectionEmptyTitle,
                    message: selected == null
                        ? l10n.bookmarksEmptyBody
                        : l10n.collectionEmptyBody,
                    actionLabel: selected == null
                        ? l10n.exploreAction
                        : l10n.showAllSaved,
                    onAction: selected == null
                        ? () => context.go(AppRoutes.feedPath)
                        : () => ref
                              .read(selectedCollectionProvider.notifier)
                              .select(null),
                  ),
                AsyncData<List<SavedArticle>>(
                  value: final List<SavedArticle> items,
                ) =>
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.gutter,
                    ),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final SavedArticle item = items[index];
                      return ArticleRow(
                        article: item.article,
                        eyebrow: item.collectionName,
                        showDivider: index != items.length - 1,
                        onTap: () => context.push(
                          AppRoutes.article(item.article.url),
                          extra: item.article,
                        ),
                      );
                    },
                  ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCollection(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final String? name = await promptForName(
      context,
      title: l10n.newCollection,
      hint: l10n.collectionNameHint,
      confirmLabel: l10n.createAction,
    );
    if (name == null) return;

    final bool created = await ref
        .read(bookmarkRepositoryProvider)
        .createCollection(name);

    if (!created) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.collectionExists)));
    }
  }

  Future<void> _deleteCollection(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool confirmed = await confirmAction(
      context,
      title: l10n.deleteCollectionTitle,
      message: l10n.deleteCollectionBody(name),
      confirmLabel: l10n.deleteAction,
    );
    if (!confirmed) return;

    final BookmarkRepository repository = ref.read(bookmarkRepositoryProvider);
    await repository.deleteCollection(name);

    if (ref.read(selectedCollectionProvider) == name) {
      ref.read(selectedCollectionProvider.notifier).select(null);
    }
  }
}

/// "All" plus one pill per collection. Long-pressing a collection offers to
/// delete it.
class _CollectionChips extends StatelessWidget {
  const _CollectionChips({
    required this.collections,
    required this.selected,
    required this.onSelected,
    required this.onDelete,
  });

  final List<String> collections;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String?> entries = <String?>[null, ...collections];

    return SizedBox(
      height: Dimens.minTapTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
        itemCount: entries.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: Spacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final String? name = entries[index];
          return Center(
            child: _Pill(
              label: name ?? l10n.categoryAll,
              isSelected: name == selected,
              onTap: () => onSelected(name),
              onLongPress: name == null ? null : () => onDelete(name),
            ),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final NewslineTokens tokens = NewslineTokens.of(context);

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? tokens.filledControl : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? tokens.filledControl : tokens.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? tokens.onFilledControl
                    : tokens.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
