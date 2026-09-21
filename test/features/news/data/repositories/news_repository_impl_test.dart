import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/data/datasources/news_api_data_source.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';

import '../../../../support/fake_news_remote_data_source.dart';

void main() {
  group('NewsRepositoryImpl', () {
    test('maps a page and derives hasMore from the reported total', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 45,
        articlesPerPage: 20,
      );
      final NewsRepositoryImpl repository = NewsRepositoryImpl(remote: remote);

      final ArticleFeed feed = await repository.getTopHeadlines(
        category: NewsCategory.technology,
      );

      expect(feed.articles, hasLength(20));
      expect(feed.page, 1);
      expect(feed.hasMore, isTrue);
      expect(feed.origin, DataOrigin.network);
      expect(remote.lastCategory, 'technology');
    });

    test('reports hasMore false on the final page', () async {
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: FakeNewsRemoteDataSource(totalResults: 25, articlesPerPage: 5),
      );

      final ArticleFeed feed = await repository.getTopHeadlines(
        category: NewsCategory.general,
        page: 2,
      );

      expect(feed.hasMore, isFalse);
    });

    test('drops invalid records without breaking pagination', () async {
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: FakeNewsRemoteDataSource(
          totalResults: 100,
          articlesPerPage: 3,
          includeInvalidRecord: true,
        ),
      );

      final ArticleFeed feed = await repository.getTopHeadlines(
        category: NewsCategory.general,
      );

      expect(feed.articles, hasLength(3));
      expect(feed.hasMore, isTrue);
    });

    test('short-circuits an empty search without calling the source', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource();
      final NewsRepositoryImpl repository = NewsRepositoryImpl(remote: remote);

      final ArticleFeed feed = await repository.searchArticles(query: '   ');

      expect(feed.articles, isEmpty);
      expect(remote.searchCallCount, 0);
    });

    test('translates a transport failure into NoConnectionFailure', () {
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: FakeNewsRemoteDataSource(
          throwOnCall: http.ClientException('connection closed'),
        ),
      );

      expect(
        () => repository.getTopHeadlines(category: NewsCategory.general),
        throwsA(isA<NoConnectionFailure>()),
      );
    });

    test('translates a timeout into TimeoutFailure', () {
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: FakeNewsRemoteDataSource(
          throwOnCall: TimeoutException('deadline exceeded'),
        ),
      );

      expect(
        () => repository.getTopHeadlines(category: NewsCategory.general),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('translates an API error into the matching typed failure', () {
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: FakeNewsRemoteDataSource(
          throwOnCall: const NewsApiException(
            statusCode: 401,
            code: 'apiKeyInvalid',
          ),
        ),
      );

      expect(
        () => repository.getTopHeadlines(category: NewsCategory.general),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  group('NewsRepositoryImpl.mapApiException', () {
    test('maps status codes onto typed failures', () {
      expect(
        NewsRepositoryImpl.mapApiException(
          const NewsApiException(statusCode: 401),
        ),
        isA<UnauthorizedFailure>(),
      );
      expect(
        NewsRepositoryImpl.mapApiException(
          const NewsApiException(statusCode: 426),
        ),
        isA<UpgradeRequiredFailure>(),
      );
      expect(
        NewsRepositoryImpl.mapApiException(
          const NewsApiException(statusCode: 429),
        ),
        isA<RateLimitedFailure>(),
      );
      expect(
        NewsRepositoryImpl.mapApiException(
          const NewsApiException(statusCode: 503),
        ),
        isA<ServerFailure>(),
      );
    });

    test('falls back to the NewsAPI error code for unmapped statuses', () {
      expect(
        NewsRepositoryImpl.mapApiException(
          const NewsApiException(statusCode: 200, code: 'apiKeyExhausted'),
        ),
        isA<RateLimitedFailure>(),
      );
      expect(
        NewsRepositoryImpl.mapApiException(
          const NewsApiException(statusCode: 200, code: 'apiKeyInvalid'),
        ),
        isA<UnauthorizedFailure>(),
      );
    });
  });
}
