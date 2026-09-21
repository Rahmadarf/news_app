import 'package:news_app/features/news/data/dto/article_dto.dart';

/// Wire representation of a NewsAPI envelope.
///
/// Covers both shapes NewsAPI returns: the success envelope
/// (`status`, `totalResults`, `articles`) and the error envelope
/// (`status`, `code`, `message`). The previous implementation parsed only the
/// success shape, so API error codes never reached the app; see
/// docs/AUDIT.md H-5.
class NewsResponseDto {
  const NewsResponseDto({
    required this.status,
    required this.totalResults,
    required this.articles,
    this.code,
    this.message,
  });

  factory NewsResponseDto.fromJson(Map<String, dynamic> json) {
    final Object? rawArticles = json['articles'];

    return NewsResponseDto(
      status: json['status'] as String? ?? '',
      totalResults: json['totalResults'] as int? ?? 0,
      articles: rawArticles is List
          ? rawArticles
                .whereType<Map<String, dynamic>>()
                .map(ArticleDto.fromJson)
                .toList(growable: false)
          : const <ArticleDto>[],
      code: json['code'] as String?,
      message: json['message'] as String?,
    );
  }

  final String status;
  final int totalResults;
  final List<ArticleDto> articles;

  /// NewsAPI error code, e.g. `apiKeyInvalid`, `rateLimited`.
  final String? code;

  /// NewsAPI human-readable error text. Developer-facing, never shown as UI.
  final String? message;

  bool get isError => status == 'error';
}
