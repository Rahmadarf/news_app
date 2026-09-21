import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/dto/article_dto.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';

/// In-memory news source for development, demos, and tests.
///
/// Consumes no NewsAPI quota, needs no key, and touches no socket or timer.
/// The same arguments always produce the same result.
///
/// Part 4 replaces the generated records with committed JSON fixtures that also
/// cover `"[Removed]"`, missing-field, and duplicate-URL cases.
class MockNewsDataSource implements NewsRemoteDataSource {
  const MockNewsDataSource({this.headlineCount = 23, this.searchCount = 7});

  static const String _publishedAt = '2026-09-20T08:30:00Z';

  /// Large enough that pagination is exercised at the default page size.
  final int headlineCount;
  final int searchCount;

  @override
  Future<NewsResponseDto> fetchTopHeadlines({
    required String country,
    required String category,
    required int page,
    required int pageSize,
  }) async {
    final List<ArticleDto> all = List<ArticleDto>.generate(
      headlineCount,
      (int index) =>
          _article(index: index, label: category, slug: '$category-$country'),
    );
    return _page(all, page: page, pageSize: pageSize);
  }

  @override
  Future<NewsResponseDto> searchEverything({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    final List<ArticleDto> all = List<ArticleDto>.generate(
      searchCount,
      (int index) =>
          _article(index: index, label: query, slug: 'search/$query'),
    );
    return _page(all, page: page, pageSize: pageSize);
  }

  ArticleDto _article({
    required int index,
    required String label,
    required String slug,
  }) {
    final int number = index + 1;
    return ArticleDto(
      title: 'Mock $label headline $number',
      description: 'Sample description for $label item $number.',
      url: 'https://example.com/$slug/$number',
      // Null on odd items so the no-image layout stays exercised in dev.
      urlToImage: index.isEven ? 'https://example.com/$slug/$number.jpg' : null,
      publishedAt: _publishedAt,
      content: 'Mock content for $label item $number.',
      source: const SourceDto(id: 'mock-source', name: 'Mock Source'),
    );
  }

  NewsResponseDto _page(
    List<ArticleDto> all, {
    required int page,
    required int pageSize,
  }) {
    final int safePage = page < 1 ? 1 : page;
    final int safePageSize = pageSize < 1 ? 1 : pageSize;
    final int start = (safePage - 1) * safePageSize;

    if (start >= all.length) {
      return NewsResponseDto(
        status: 'ok',
        totalResults: all.length,
        articles: const <ArticleDto>[],
      );
    }

    return NewsResponseDto(
      status: 'ok',
      totalResults: all.length,
      articles: all.sublist(start, (start + safePageSize).clamp(0, all.length)),
    );
  }
}
