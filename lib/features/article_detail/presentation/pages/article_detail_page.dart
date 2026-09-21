import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

/// Article reader.
///
/// [article] is the fast path handed over by the list. It is absent after a
/// deep link, a hot restart, or a browser reload, which is why [articleUrl] is
/// also carried in the route. Nothing here casts a route argument; a missing
/// article renders an explanatory state instead of crashing. See
/// docs/AUDIT.md H-10.
///
/// Part 4 replaces the "unavailable" branch with a cache lookup by URL.
class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key, this.article, this.articleUrl});

  final Article? article;
  final String? articleUrl;

  @override
  Widget build(BuildContext context) {
    final Article? article = this.article;

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: EmptyView(
          icon: Icons.article_outlined,
          title: 'Article not loaded',
          message: articleUrl == null
              ? 'This link does not point at an article.'
              : 'Open it from the feed, or read it on the web.',
        ),
        floatingActionButton: articleUrl == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _openInBrowser(context, articleUrl!),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in browser'),
              ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _DetailAppBar(article: article),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SourceLine(article: article),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (article.description != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      article.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (article.content != null) ...<Widget>[
                    const SizedBox(height: 20),
                    const Text(
                      'Content',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.content!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _openInBrowser(context, article.url),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Read Full Article',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = article.imageUrl;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl == null
            ? const _HeaderPlaceholder(icon: Icons.newspaper)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    const _HeaderPlaceholder(),
                errorWidget: (BuildContext context, String url, Object error) =>
                    const _HeaderPlaceholder(icon: Icons.image_not_supported),
              ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareArticle(article),
        ),
        PopupMenuButton<String>(
          onSelected: (String value) => switch (value) {
            'copy_link' => _copyLink(context, article.url),
            'open_browser' => _openInBrowser(context, article.url),
            _ => null,
          },
          itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'copy_link',
              child: Row(
                children: <Widget>[
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Copy Link'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'open_browser',
              child: Row(
                children: <Widget>[
                  Icon(Icons.open_in_browser),
                  SizedBox(width: 8),
                  Text('Open in Browser'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final DateTime? publishedAt = article.publishedAt;

    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            article.source.name,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (publishedAt != null) ...<Widget>[
          const SizedBox(width: 12),
          Text(
            timeago.format(publishedAt),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderPlaceholder extends StatelessWidget {
  const _HeaderPlaceholder({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.divider,
      child: Center(
        child: icon == null
            ? const CircularProgressIndicator()
            : Icon(icon, size: 50, color: AppColors.textHint),
      ),
    );
  }
}

void _shareArticle(Article article) {
  SharePlus.instance.share(
    ShareParams(
      text: '${article.title}\n\n${article.url}',
      subject: article.title,
    ),
  );
}

void _copyLink(BuildContext context, String url) {
  Clipboard.setData(ClipboardData(text: url));
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
}

Future<void> _openInBrowser(BuildContext context, String rawUrl) async {
  final Uri? uri = Uri.tryParse(rawUrl);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  if (uri == null ||
      !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open the link')),
    );
  }
}
