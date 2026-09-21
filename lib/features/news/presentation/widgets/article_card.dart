import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Card for one [Article].
///
/// Reads only guaranteed fields directly; optional ones stay behind null
/// checks. [Article.publishedAt] is already a parsed `DateTime?`, so rendering
/// a malformed timestamp is no longer possible here.
class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = article.imageUrl;
    final DateTime? publishedAt = article.publishedAt;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (BuildContext context, String url) =>
                      const _ImagePlaceholder(),
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          const _ImagePlaceholder(
                            icon: Icons.image_not_supported,
                          ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          article.source.name,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (publishedAt != null) ...<Widget>[
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(publishedAt),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.description != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      article.description!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: AppColors.divider,
      child: Center(
        child: icon == null
            ? const CircularProgressIndicator()
            : Icon(icon, size: 40, color: AppColors.textHint),
      ),
    );
  }
}
