import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/features/bookmarks/presentation/controllers/bookmark_providers.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Save control shown on every article surface.
///
/// Reads one shared stream, so the icon reflects the same saved state whether
/// it appears on a featured card, a list row, or the article screen. The
/// visual icon stays compact while the tap target meets the 48dp minimum.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({super.key, required this.article, this.iconSize = 20});

  final Article article;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);

    final bool isSaved =
        ref.watch(savedArticleUrlsProvider).value?.contains(article.url) ??
        false;

    return IconButton(
      onPressed: () => _toggle(context, ref),
      iconSize: iconSize,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: Dimens.minTapTarget,
        minHeight: Dimens.minTapTarget,
      ),
      padding: EdgeInsets.zero,
      color: isSaved ? tokens.accent : tokens.textSecondary,
      // Announced as a toggle so a screen reader reports the current state.
      isSelected: isSaved,
      tooltip: isSaved ? l10n.removeFromSaved : l10n.saveArticle,
      icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool nowSaved = await toggleBookmark(ref, article);
    if (!context.mounted) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(nowSaved ? l10n.articleSaved : l10n.articleUnsaved),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
