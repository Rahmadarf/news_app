import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/news/data/datasources/mock_news_data_source.dart';
import 'package:news_app/features/news/data/dto/article_dto.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';

void main() {
  const MockNewsDataSource source = MockNewsDataSource();

  group('fetchTopHeadlines', () {
    test('is deterministic for identical arguments', () async {
      final NewsResponseDto a = await source.fetchTopHeadlines(
        country: 'us',
        category: 'technology',
        page: 1,
        pageSize: 20,
      );
      final NewsResponseDto b = await source.fetchTopHeadlines(
        country: 'us',
        category: 'technology',
        page: 1,
        pageSize: 20,
      );

      expect(
        a.articles.map((ArticleDto d) => d.url),
        b.articles.map((ArticleDto d) => d.url),
      );
    });

    test('pages without overlap and reports the total', () async {
      final NewsResponseDto page1 = await source.fetchTopHeadlines(
        country: 'us',
        category: 'general',
        page: 1,
        pageSize: 20,
      );
      final NewsResponseDto page2 = await source.fetchTopHeadlines(
        country: 'us',
        category: 'general',
        page: 2,
        pageSize: 20,
      );

      expect(page1.articles, hasLength(20));
      expect(page2.articles, hasLength(3));
      expect(page1.totalResults, 23);
      expect(
        page1.articles
            .map((ArticleDto d) => d.url)
            .toSet()
            .intersection(page2.articles.map((ArticleDto d) => d.url).toSet()),
        isEmpty,
      );
    });

    test('returns an empty page past the end', () async {
      final NewsResponseDto page = await source.fetchTopHeadlines(
        country: 'us',
        category: 'general',
        page: 99,
        pageSize: 20,
      );

      expect(page.articles, isEmpty);
      expect(page.totalResults, 23);
    });
  });

  group('searchEverything', () {
    test('echoes the query into its results', () async {
      final NewsResponseDto response = await source.searchEverything(
        query: 'flutter',
        page: 1,
        pageSize: 20,
      );

      expect(response.articles, isNotEmpty);
      expect(response.articles.first.title, contains('flutter'));
    });
  });
}
