import 'package:news_app/models/news_article.dart';
import 'package:news_app/models/news_response.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

/// In-memory news source used for development, demos, and tests.
///
/// Consumes no NewsAPI quota and requires no key. Behaviour is deterministic:
/// the same arguments always produce the same result, and nothing here awaits a
/// timer or a socket.
///
/// This is a deliberately small placeholder. Part 4 replaces it with
/// `MockNewsDataSource` backed by committed JSON fixtures that also cover
/// malformed, duplicate, and `"[Removed]"` records.
class MockNewsService implements NewsService {
  const MockNewsService();

  static const String _publishedAt = '2026-09-20T08:30:00Z';

  @override
  Future<NewsResponse> getTopHeadlines({
    String country = Constants.defaultCountry,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final String effectiveCategory = (category == null || category.isEmpty)
        ? 'general'
        : category;

    final List<NewsArticle> articles = List<NewsArticle>.generate(
      5,
      (int index) => _article(
        index: index,
        label: effectiveCategory,
        slug: '$effectiveCategory-$country',
      ),
    );

    return _paginate(articles, page: page, pageSize: pageSize);
  }

  @override
  Future<NewsResponse> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
  }) async {
    final List<NewsArticle> articles = List<NewsArticle>.generate(
      3,
      (int index) =>
          _article(index: index, label: 'search "$query"', slug: 'search'),
    );

    return _paginate(articles, page: page, pageSize: pageSize);
  }

  NewsArticle _article({
    required int index,
    required String label,
    required String slug,
  }) {
    return NewsArticle(
      title: 'Mock $label headline ${index + 1}',
      description: 'Sample description for $label item ${index + 1}.',
      url: 'https://example.com/$slug/${index + 1}',
      // Intentionally null on some items so the UI's no-image path stays
      // exercised during development.
      urlToImage: index.isEven
          ? 'https://example.com/$slug/${index + 1}.jpg'
          : null,
      publishedAt: _publishedAt,
      content: 'Mock content for $label item ${index + 1}.',
      source: const Source(id: 'mock-source', name: 'Mock Source'),
    );
  }

  NewsResponse _paginate(
    List<NewsArticle> all, {
    required int page,
    required int pageSize,
  }) {
    final int safePage = page < 1 ? 1 : page;
    final int safePageSize = pageSize < 1 ? 1 : pageSize;
    final int start = (safePage - 1) * safePageSize;

    if (start >= all.length) {
      return NewsResponse(
        status: 'ok',
        totalResults: all.length,
        articles: const <NewsArticle>[],
      );
    }

    final int end = (start + safePageSize).clamp(0, all.length);

    return NewsResponse(
      status: 'ok',
      totalResults: all.length,
      articles: all.sublist(start, end),
    );
  }
}
