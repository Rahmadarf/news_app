import 'package:news_app/features/news/domain/entities/article_source.dart';

/// A single news article, with the invariants presentation code may rely on.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
///
/// API nullability lives in the DTO layer. Anything that cannot satisfy these
/// invariants is dropped by the mapper rather than surfaced as a half-empty
/// card, so widgets never need to null-check [url], [title], or [source].
class Article {
  const Article({
    required this.url,
    required this.title,
    required this.source,
    this.description,
    this.imageUrl,
    this.publishedAt,
    this.content,
  });

  /// Canonical, absolute article URL. Doubles as the stable identity key used
  /// for deduplication across pages and, later, for cache lookups.
  final String url;

  /// Non-empty headline.
  final String title;

  final ArticleSource source;

  /// Optional: NewsAPI omits it for some records.
  final String? description;

  /// Optional: absent images are normal and must not break layout.
  final String? imageUrl;

  /// Optional: `null` when the API sent no timestamp or an unparsable one.
  /// Never throws at render time.
  final DateTime? publishedAt;

  /// Optional and frequently truncated by NewsAPI.
  final String? content;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Article && other.url == url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'Article($url)';
}
