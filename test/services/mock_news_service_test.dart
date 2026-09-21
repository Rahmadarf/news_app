import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/news_response.dart';
import 'package:news_app/services/mock_news_service.dart';

void main() {
  const MockNewsService service = MockNewsService();

  group('MockNewsService.getTopHeadlines', () {
    test('is deterministic for identical arguments', () async {
      final NewsResponse first = await service.getTopHeadlines(
        category: 'technology',
      );
      final NewsResponse second = await service.getTopHeadlines(
        category: 'technology',
      );

      expect(
        first.articles.map((a) => a.url),
        second.articles.map((a) => a.url),
      );
    });

    test('pages through the fixture without overlap', () async {
      final NewsResponse page1 = await service.getTopHeadlines(
        page: 1,
        pageSize: 2,
      );
      final NewsResponse page2 = await service.getTopHeadlines(
        page: 2,
        pageSize: 2,
      );

      expect(page1.articles, hasLength(2));
      expect(page2.articles, hasLength(2));
      expect(page1.totalResults, 5);
      expect(
        page1.articles
            .map((a) => a.url)
            .toSet()
            .intersection(page2.articles.map((a) => a.url).toSet()),
        isEmpty,
      );
    });

    test('returns an empty page past the end', () async {
      final NewsResponse page = await service.getTopHeadlines(
        page: 99,
        pageSize: 2,
      );

      expect(page.articles, isEmpty);
      expect(page.totalResults, 5);
    });
  });

  group('MockNewsService.searchNews', () {
    test('echoes the query into its results', () async {
      final NewsResponse response = await service.searchNews(query: 'flutter');

      expect(response.articles, isNotEmpty);
      expect(response.articles.first.title, contains('flutter'));
    });
  });
}
