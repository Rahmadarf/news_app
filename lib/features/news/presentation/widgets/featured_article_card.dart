import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/features/bookmarks/presentation/widgets/bookmark_button.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/widgets/article_meta.dart';
import 'package:news_app/features/news/presentation/widgets/article_photo.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Card used by the horizontally scrolling "Trending today" rail.
///
/// Fixed 276dp width with a 177dp hero, per the design specification. The
/// title is serif and allowed to wrap; at large text scales the card grows
/// vertically rather than clipping.
class FeaturedArticleCard extends StatelessWidget {
  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: Dimens.featuredCardWidth,
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
              borderRadius: BorderRadius.circular(Radii.hero),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ArticlePhoto(
                    url: article.imageUrl,
                    height: Dimens.featuredPhotoHeight,
                    radius: Radii.hero,
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: <Widget>[
              Expanded(child: ArticleMeta(article: article)),
              BookmarkButton(article: article, iconSize: 18),
            ],
          ),
        ],
      ),
    );
  }
}
