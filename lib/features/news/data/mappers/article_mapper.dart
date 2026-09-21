import 'package:news_app/features/news/data/dto/article_dto.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';

/// Converts wire DTOs into domain entities, dropping anything that cannot meet
/// the entity invariants.
///
/// Filtering happens here, at the edge of the data layer, so neither the
/// repository nor any widget has to re-check what NewsAPI sent.
abstract final class ArticleMapper {
  /// Fallback used when NewsAPI omits the source name.
  static const String unknownSourceName = 'Unknown source';

  /// NewsAPI's placeholder for an article that was taken down. It appears in
  /// `title`, `description`, `content`, and sometimes `author`.
  static const String removedPlaceholder = '[Removed]';

  /// Host NewsAPI substitutes for a removed article's URL.
  static const String removedHost = 'removed.com';

  /// Query parameters stripped during canonicalization, so the same article
  /// arriving with different campaign tags collapses to one entry.
  static const Set<String> trackingParameters = <String>{
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'utm_term',
    'utm_content',
    'utm_id',
    'fbclid',
    'gclid',
    'mc_cid',
    'mc_eid',
  };

  /// Returns `null` when [dto] cannot become a valid [Article].
  ///
  /// A record is rejected when it has no usable URL, no title, or when it is
  /// one of NewsAPI's `"[Removed]"` tombstones.
  static Article? toEntity(ArticleDto dto) {
    if (isRemoved(dto)) return null;

    final String? rawUrl = _nonEmpty(dto.url);
    if (rawUrl == null) return null;

    final String? url = canonicalizeUrl(rawUrl);
    if (url == null) return null;

    final String? title = _nonEmpty(dto.title);
    if (title == null) return null;

    return Article(
      url: url,
      title: title,
      source: ArticleSource(
        name: _nonEmpty(dto.source?.name) ?? unknownSourceName,
        id: _nonEmpty(dto.source?.id),
      ),
      description: _nonEmpty(dto.description),
      imageUrl: _nonEmpty(dto.urlToImage),
      publishedAt: parseDate(dto.publishedAt),
      content: _nonEmpty(dto.content),
    );
  }

  /// Maps a page of DTOs, discarding invalid records and collapsing duplicates
  /// that share a canonical URL. Order is preserved; the first occurrence wins.
  static List<Article> toEntities(Iterable<ArticleDto> dtos) {
    final Map<String, Article> byUrl = <String, Article>{};
    for (final ArticleDto dto in dtos) {
      final Article? article = toEntity(dto);
      if (article == null) continue;
      byUrl.putIfAbsent(article.url, () => article);
    }
    return List<Article>.unmodifiable(byUrl.values);
  }

  /// True for NewsAPI's removed-article tombstones.
  static bool isRemoved(ArticleDto dto) {
    if (dto.title?.trim() == removedPlaceholder) return true;
    if (dto.content?.trim() == removedPlaceholder) return true;

    final String? url = dto.url;
    if (url != null && Uri.tryParse(url)?.host.endsWith(removedHost) == true) {
      return true;
    }
    return false;
  }

  /// Normalizes a URL into the stable key used for identity, deduplication,
  /// and cache lookups.
  ///
  /// Lowercases the scheme and host, drops the fragment, removes tracking
  /// parameters, and strips a trailing slash from the path. Returns `null` for
  /// anything that is not an absolute http(s) URL.
  static String? canonicalizeUrl(String raw) {
    final Uri? parsed = Uri.tryParse(raw.trim());
    if (parsed == null) return null;
    if (!parsed.hasScheme || !parsed.hasAuthority) return null;

    final String scheme = parsed.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return null;

    final Map<String, String> query = <String, String>{
      for (final MapEntry<String, String> e in parsed.queryParameters.entries)
        if (!trackingParameters.contains(e.key.toLowerCase())) e.key: e.value,
    };

    String path = parsed.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return Uri(
      scheme: scheme,
      host: parsed.host.toLowerCase(),
      port: parsed.hasPort ? parsed.port : null,
      path: path,
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  /// Never throws. A malformed timestamp becomes `null` instead of a
  /// `FormatException` inside `build()`; see docs/AUDIT.md H-9.
  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  static String? _nonEmpty(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
