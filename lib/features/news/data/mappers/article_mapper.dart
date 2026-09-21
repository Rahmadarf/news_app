import 'package:news_app/features/news/data/dto/article_dto.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';

/// Converts wire DTOs into domain entities, dropping anything that cannot meet
/// the entity invariants.
///
/// Part 3 enforces the invariants the entity itself requires: a non-empty URL
/// and title, a source name, and a date that never throws. Part 4 extends this
/// with `"[Removed]"` filtering, URL canonicalization, cross-page
/// deduplication, and the `"… [+N chars]"` content suffix.
abstract final class ArticleMapper {
  /// Fallback used when NewsAPI omits the source name.
  static const String unknownSourceName = 'Unknown source';

  /// Returns `null` when [dto] cannot become a valid [Article].
  static Article? toEntity(ArticleDto dto) {
    final String? url = _nonEmpty(dto.url);
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

  /// Maps a page of DTOs, silently discarding invalid records.
  static List<Article> toEntities(Iterable<ArticleDto> dtos) {
    final List<Article> result = <Article>[];
    for (final ArticleDto dto in dtos) {
      final Article? article = toEntity(dto);
      if (article != null) result.add(article);
    }
    return List<Article>.unmodifiable(result);
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
