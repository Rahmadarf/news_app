import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/widgets/source_badge.dart';
import 'package:news_app/core/utils/relative_time.dart';

/// Source badge, source name, and relative publication time.
///
/// Metadata never drops below 12sp, per the design specification, and the row
/// is read out as a single semantic string instead of three fragments.
class ArticleMeta extends StatelessWidget {
  const ArticleMeta({super.key, required this.article, this.badgeSize});

  final Article article;
  final double? badgeSize;

  @override
  Widget build(BuildContext context) {
    final NewslineTokens tokens = NewslineTokens.of(context);
    final TextStyle style =
        Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: tokens.textSecondary) ??
        TextStyle(color: tokens.textSecondary);

    final String locale = Localizations.localeOf(context).languageCode;
    final DateTime? publishedAt = article.publishedAt;
    final String? relative = publishedAt == null
        ? null
        : formatRelativeTime(publishedAt, locale);

    final String label = relative == null
        ? article.source.name
        : '${article.source.name} · $relative';

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        children: <Widget>[
          SourceBadge(
            source: article.source,
            size: badgeSize ?? Dimens.sourceDot,
          ),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Text(
              label,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
