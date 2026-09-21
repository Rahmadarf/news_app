import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/news/data/datasources/mock_news_data_source.dart';
import 'package:news_app/features/news/data/dto/article_dto.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';
import 'package:news_app/features/news/data/mappers/article_mapper.dart';
import 'package:news_app/features/news/domain/entities/article.dart';

import '../../../../support/fixtures.dart';

void main() {
  group('fetchTopHeadlines', () {
    test('is deterministic for identical arguments', () async {
      final MockNewsDataSource source = fixtureBackedMockSource();

      final NewsResponseDto a = await source.fetchTopHeadlines(
        country: 'us',
        category: 'general',
        page: 1,
        pageSize: 20,
      );
      final NewsResponseDto b = await source.fetchTopHeadlines(
        country: 'us',
        category: 'general',
        page: 1,
        pageSize: 20,
      );

      expect(
        a.articles.map((ArticleDto d) => d.url),
        b.articles.map((ArticleDto d) => d.url),
      );
    });

    test('pages the fixture at the wire level without overlap', () async {
      final MockNewsDataSource source = fixtureBackedMockSource();

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
      expect(page2.articles, isNotEmpty);
      expect(page1.totalResults, greaterThan(20));
      expect(
        page1.articles
            .map((ArticleDto d) => d.url)
            .whereType<String>()
            .toSet()
            .intersection(
              page2.articles
                  .map((ArticleDto d) => d.url)
                  .whereType<String>()
                  .toSet(),
            ),
        isEmpty,
      );
    });

    test('returns an empty page past the end', () async {
      final MockNewsDataSource source = fixtureBackedMockSource();

      final NewsResponseDto page = await source.fetchTopHeadlines(
        country: 'us',
        category: 'general',
        page: 99,
        pageSize: 20,
      );

      expect(page.articles, isEmpty);
    });
  });

  group('the headline fixture exercises the filtering path', () {
    late NewsResponseDto all;

    setUpAll(() async {
      all = await fixtureBackedMockSource().fetchTopHeadlines(
        country: 'us',
        category: 'general',
        page: 1,
        pageSize: 1000,
      );
    });

    test('contains records the mapper must reject', () {
      expect(
        all.articles.where(ArticleMapper.isRemoved),
        isNotEmpty,
        reason: 'a "[Removed]" tombstone',
      );
      expect(
        all.articles.where((ArticleDto d) => d.title == null),
        isNotEmpty,
        reason: 'a record with no title',
      );
      expect(
        all.articles.where((ArticleDto d) => d.url == null),
        isNotEmpty,
        reason: 'a record with no URL',
      );
    });

    test('mapping discards them and collapses the duplicate', () {
      final List<Article> mapped = ArticleMapper.toEntities(all.articles);

      expect(mapped.length, lessThan(all.articles.length));
      expect(
        mapped.map((Article a) => a.url).toSet(),
        hasLength(mapped.length),
        reason: 'no duplicate canonical URLs survive',
      );
      expect(
        mapped.where((Article a) => a.title.contains('[Removed]')),
        isEmpty,
      );
    });

    test('an unparsable timestamp becomes a null date, not a crash', () {
      final List<Article> mapped = ArticleMapper.toEntities(all.articles);
      final Article broken = mapped.firstWhere(
        (Article a) => a.url.endsWith('/broken-date'),
      );

      expect(broken.publishedAt, isNull);
    });
  });

  group('searchEverything', () {
    test('matches on title text', () async {
      final NewsResponseDto response = await fixtureBackedMockSource()
          .searchEverything(query: 'headline 2', page: 1, pageSize: 20);

      expect(response.articles, isNotEmpty);
      expect(
        response.articles.every(
          (ArticleDto d) =>
              (d.title ?? '').toLowerCase().contains('headline 2'),
        ),
        isTrue,
      );
    });

    test('pages search results', () async {
      final MockNewsDataSource source = fixtureBackedMockSource();

      final NewsResponseDto page1 = await source.searchEverything(
        query: 'search',
        page: 1,
        pageSize: 3,
      );
      final NewsResponseDto page2 = await source.searchEverything(
        query: 'search',
        page: 2,
        pageSize: 3,
      );

      expect(page1.articles, hasLength(3));
      expect(page2.articles, hasLength(3));
      expect(
        page1.articles
            .map((ArticleDto d) => d.url)
            .toSet()
            .intersection(page2.articles.map((ArticleDto d) => d.url).toSet()),
        isEmpty,
      );
    });
  });
}
