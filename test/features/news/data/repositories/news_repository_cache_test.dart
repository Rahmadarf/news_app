import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';

import '../../../../support/fake_news_remote_data_source.dart';
import '../../../../support/test_database.dart';

void main() {
  const Duration ttl = Duration(minutes: 15);
  final DateTime t0 = DateTime.utc(2026, 9, 21, 10);

  ({NewsRepositoryImpl repository, MutableClock clock}) buildRepository(
    FakeNewsRemoteDataSource remote, {
    AppDatabase? database,
  }) {
    final AppDatabase db = database ?? newTestDatabase();
    final MutableClock clock = MutableClock(t0);
    return (
      repository: NewsRepositoryImpl(
        remote: remote,
        local: NewsLocalDataSource(db),
        pageSize: 5,
        ttl: ttl,
        clock: clock.clock,
      ),
      clock: clock,
    );
  }

  group('cache freshness', () {
    test('a fresh cache hit serves storage and makes no request', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 12,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);
      expect(remote.headlineCallCount, 1);

      sut.clock.advance(const Duration(minutes: 14));

      final ArticleFeed second = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
      );

      expect(remote.headlineCallCount, 1, reason: 'no second request');
      expect(second.origin, DataOrigin.cache);
      expect(second.articles, hasLength(5));
      expect(second.fetchedAt, t0);
    });

    test('an expired cache triggers a fresh request', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 12,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);
      sut.clock.advance(const Duration(minutes: 16));

      final ArticleFeed second = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
      );

      expect(remote.headlineCallCount, 2);
      expect(second.origin, DataOrigin.network);
      expect(second.fetchedAt, t0.add(const Duration(minutes: 16)));
    });

    test('forceRefresh ignores a still-fresh cache', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 12,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);
      final ArticleFeed refreshed = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
        forceRefresh: true,
      );

      expect(remote.headlineCallCount, 2);
      expect(refreshed.origin, DataOrigin.network);
    });

    test('caches are keyed per category', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 12,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);
      await sut.repository.getTopHeadlines(category: NewsCategory.sports);

      expect(remote.headlineCallCount, 2, reason: 'different cache keys');
    });
  });

  group('offline behaviour', () {
    test('falls back to stale cache and reports it as stale', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 12,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);

      sut.clock.advance(const Duration(hours: 5));
      remote.throwOnCall = const SocketException('network is unreachable');

      final ArticleFeed offline = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
      );

      expect(offline.origin, DataOrigin.staleCache);
      expect(offline.isStale, isTrue);
      expect(offline.articles, hasLength(5));
      expect(offline.fetchedAt, t0, reason: 'reports the original fetch time');
    });

    test('a timeout also falls back to stale cache', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 12,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);
      sut.clock.advance(const Duration(hours: 5));
      remote.throwOnCall = TimeoutException('deadline exceeded');

      final ArticleFeed offline = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
      );

      expect(offline.origin, DataOrigin.staleCache);
    });

    test('an empty cache plus no connection surfaces the failure', () {
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(
            FakeNewsRemoteDataSource(
              throwOnCall: const SocketException('network is unreachable'),
            ),
          );

      expect(
        () => sut.repository.getTopHeadlines(category: NewsCategory.general),
        throwsA(isA<NoConnectionFailure>()),
      );
    });

    test('a rejected API key never hides behind stale cache', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 12,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);
      sut.clock.advance(const Duration(hours: 5));
      remote.throwOnCall = const UnauthorizedFailure();

      await expectLater(
        sut.repository.getTopHeadlines(category: NewsCategory.general),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  group('pagination', () {
    test('page 2 drops articles already stored for page 1', () async {
      // The fake repeats the same URLs on every page.
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 20,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      final ArticleFeed page1 = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
      );
      final ArticleFeed page2 = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
        page: 2,
      );

      expect(page1.articles, hasLength(5));
      expect(page2.articles, isEmpty, reason: 'every URL was already seen');
      expect(page2.hasMore, isTrue, reason: 'derived from totalResults');
    });

    test('distinct pages accumulate distinct articles', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 20,
        articlesPerPage: 5,
        uniquePerPage: true,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      final ArticleFeed page1 = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
      );
      final ArticleFeed page2 = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
        page: 2,
      );

      expect(page1.articles, hasLength(5));
      expect(page2.articles, hasLength(5));
      expect(
        page1.articles
            .map((Article a) => a.url)
            .toSet()
            .intersection(page2.articles.map((Article a) => a.url).toSet()),
        isEmpty,
      );
    });

    test('forceRefresh discards cached pages of the same feed', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 20,
        articlesPerPage: 5,
        uniquePerPage: true,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);
      await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
        page: 2,
      );

      // After the refresh clears the feed, page 1 is no longer suppressed by
      // the previously stored page-1 URLs.
      final ArticleFeed refreshed = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
        forceRefresh: true,
      );

      expect(refreshed.articles, hasLength(5));
      expect(refreshed.origin, DataOrigin.network);
    });
  });

  group('cache maintenance', () {
    test(
      'findCachedArticle returns a stored article by canonical URL',
      () async {
        final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
            buildRepository(
              FakeNewsRemoteDataSource(totalResults: 5, articlesPerPage: 5),
            );

        final ArticleFeed feed = await sut.repository.getTopHeadlines(
          category: NewsCategory.general,
        );
        final String url = feed.articles.first.url;

        // Looked up with tracking noise that canonicalization must strip.
        final Article? found = await sut.repository.findCachedArticle(
          '$url?utm_source=newsletter#top',
        );

        expect(found, isNotNull);
        expect(found!.url, url);
      },
    );

    test('findCachedArticle returns null for an unknown URL', () async {
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(FakeNewsRemoteDataSource());

      expect(
        await sut.repository.findCachedArticle('https://example.com/nope'),
        isNull,
      );
    });

    test('clearCache empties the feed cache', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 12,
        articlesPerPage: 5,
      );
      final ({NewsRepositoryImpl repository, MutableClock clock}) sut =
          buildRepository(remote);

      await sut.repository.getTopHeadlines(category: NewsCategory.general);
      await sut.repository.clearCache();

      final ArticleFeed afterClear = await sut.repository.getTopHeadlines(
        category: NewsCategory.general,
      );

      expect(remote.headlineCallCount, 2, reason: 'cache no longer available');
      expect(afterClear.origin, DataOrigin.network);
    });
  });

  group('plan result window', () {
    test('stops offering pages past the plan limit', () async {
      // NewsAPI reports thousands of matches but refuses to serve past the
      // hundredth result; believing totalResults would offer a page that is
      // guaranteed to fail with HTTP 426.
      final AppDatabase db = newTestDatabase();
      final MutableClock clock = MutableClock(t0);
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: FakeNewsRemoteDataSource(
          totalResults: 5000,
          articlesPerPage: 20,
          uniquePerPage: true,
        ),
        local: NewsLocalDataSource(db),
        pageSize: 20,
        maxResultWindow: 100,
        clock: clock.clock,
      );

      final ArticleFeed page4 = await repository.getTopHeadlines(
        category: NewsCategory.general,
        page: 4,
      );
      final ArticleFeed page5 = await repository.getTopHeadlines(
        category: NewsCategory.general,
        page: 5,
      );

      expect(page4.hasMore, isTrue, reason: '80 of 100 consumed');
      expect(page5.hasMore, isFalse, reason: '100 of 100 consumed');
      expect(page5.totalResults, 5000, reason: 'the real match count is kept');
    });

    test('a smaller total still ends pagination before the window', () async {
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: FakeNewsRemoteDataSource(
          totalResults: 30,
          articlesPerPage: 20,
          uniquePerPage: true,
        ),
        local: NewsLocalDataSource(newTestDatabase()),
        pageSize: 20,
        maxResultWindow: 100,
      );

      final ArticleFeed page2 = await repository.getTopHeadlines(
        category: NewsCategory.general,
        page: 2,
      );

      expect(page2.hasMore, isFalse);
    });

    test('the window also caps search pagination', () async {
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: FakeNewsRemoteDataSource(
          totalResults: 5000,
          articlesPerPage: 20,
          uniquePerPage: true,
        ),
        local: NewsLocalDataSource(newTestDatabase()),
        pageSize: 20,
        maxResultWindow: 100,
      );

      final ArticleFeed page5 = await repository.searchArticles(
        query: 'kota',
        page: 5,
      );

      expect(page5.hasMore, isFalse);
    });
  });
}
