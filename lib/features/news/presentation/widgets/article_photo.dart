import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';

/// Article photograph with the design's radii and a graceful failure state.
///
/// A missing or broken image never collapses the layout: the box keeps its
/// size and shows a muted placeholder, which is required because NewsAPI
/// frequently omits `urlToImage`.
class ArticlePhoto extends StatelessWidget {
  const ArticlePhoto({
    super.key,
    required this.url,
    required this.height,
    required this.radius,
    this.width,
  });

  final String? url;
  final double height;
  final double radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final NewslineTokens tokens = NewslineTokens.of(context);
    final String? imageUrl = url;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: imageUrl == null
            ? _Placeholder(color: tokens.surfaceSecondary)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 160),
                placeholder: (BuildContext context, String url) =>
                    _Placeholder(color: tokens.surfaceSecondary),
                errorWidget: (BuildContext context, String url, Object error) =>
                    _Placeholder(
                      color: tokens.surfaceSecondary,
                      icon: Icons.image_not_supported_outlined,
                      iconColor: tokens.textSecondary,
                    ),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.color, this.icon, this.iconColor});

  final Color color;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: icon == null
          ? const SizedBox.expand()
          : Center(child: Icon(icon, size: 22, color: iconColor)),
    );
  }
}
