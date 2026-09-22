import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/features/bookmarks/presentation/widgets/bookmark_button.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/widgets/article_meta.dart';
import 'package:news_app/features/news/presentation/widgets/article_photo.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Compact image-right row used by "Recent stories", search results, and
/// related stories.
///
/// The 92×82 thumbnail and the 1px rule below the row come from the design
/// specification. The eyebrow above the title carries the source's own
/// category when the feed provides one.
class ArticleRow extends StatelessWidget {
  const ArticleRow({
    super.key,
    required this.article,
    required this.onTap,
    this.eyebrow,
    this.showDivider = true,
  });

  final Article article;
  final VoidCallback onTap;
  final String? eyebrow;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.listRow),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: l10n.readArticleLabel(article.title),
                      excludeSemantics: true,
                      child: InkWell(
                        onTap: onTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (eyebrow != null) ...<Widget>[
                              Text(
                                eyebrow!,
                                style: theme.textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Spacing.xs),
                            ],
                            Text(
                              article.title,
                              style: theme.textTheme.titleMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: <Widget>[
                        Expanded(child: ArticleMeta(article: article)),
                        BookmarkButton(article: article, iconSize: 18),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),
              Semantics(
                button: true,
                label: l10n.readArticleLabel(article.title),
                excludeSemantics: true,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(Radii.thumbnail),
                  child: Padding(
                    padding: const EdgeInsets.only(top: Spacing.xs),
                    child: ArticlePhoto(
                      url: article.imageUrl,
                      height: Dimens.rowThumbHeight,
                      width: Dimens.rowThumbWidth,
                      radius: Radii.thumbnail,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: tokens.hairline),
      ],
    );
  }
}
