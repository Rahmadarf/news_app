import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/presentation/controllers/news_feed_controller.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';
import 'package:news_app/features/search/presentation/controllers/search_controller.dart';
import 'package:news_app/features/search/presentation/state/search_state.dart';

import '../../../support/fake_news_remote_data_source.dart';
import '../../../support/test_database.dart';

void main() {
  ProviderContainer containerWith(FakeNewsRemoteDataSource remote) {
    return ProviderContainer.test(
      overrides: <Override>[
        newsRepositoryProvider.overrideWithValue(
          NewsRepositoryImpl(
            remote: remote,
            local: NewsLocalDataSource(newTestDatabase()),
            pageSize: 5,
          ),
        ),
      ],
    );
  }

  test('starts in the loading state and settles into ready', () async {
    final ProviderContainer container = containerWith(
      FakeNewsRemoteDataSource(totalResults: 12, articlesPerPage: 5),
    );

    final provider = newsFeedControllerProvider(NewsCategory.general);
    expect(container.read(provider), isA<NewsFeedLoading>());

    await container.read(provider.notifier).retry();

    final NewsFeedReady ready = container.read(provider) as NewsFeedReady;
    expect(ready.articles, hasLength(5));
    expect(ready.loadedPages, 1);
    expect(ready.hasMore, isTrue);
    expect(ready.activity, FeedActivity.idle);
    expect(ready.isEmpty, isFalse);
  });

  test('loadMore requests the next page and deduplicates by URL', () async {
    final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
      totalResults: 12,
      articlesPerPage: 5,
    );
    final ProviderContainer container = containerWith(remote);
    final provider = newsFeedControllerProvider(NewsCategory.general);

    await container.read(provider.notifier).retry();
    await container.read(provider.notifier).loadMore();

    final NewsFeedReady ready = container.read(provider) as NewsFeedReady;
    // The fake returns the same URLs on every page, so nothing is appended.
    expect(ready.articles, hasLength(5));
    expect(ready.loadedPages, 2);
    expect(remote.lastPage, 2);
  });

  test('loadMore is a no-op once the end is reached', () async {
    final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
      totalResults: 5,
      articlesPerPage: 5,
    );
    final ProviderContainer container = containerWith(remote);
    final provider = newsFeedControllerProvider(NewsCategory.general);

    await container.read(provider.notifier).retry();
    final int callsBefore = remote.headlineCallCount;

    await container.read(provider.notifier).loadMore();

    expect((container.read(provider) as NewsFeedReady).hasMore, isFalse);
    expect(remote.headlineCallCount, callsBefore);
  });

  test('a first-load failure produces NewsFeedError', () async {
    final ProviderContainer container = containerWith(
      FakeNewsRemoteDataSource(
        throwOnCall: const UnknownFailure(debugMessage: 'boom'),
      ),
    );
    final provider = newsFeedControllerProvider(NewsCategory.general);

    await container.read(provider.notifier).retry();

    expect(container.read(provider), isA<NewsFeedError>());
  });

  test('a refresh failure keeps existing articles on screen', () async {
    final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
      totalResults: 12,
      articlesPerPage: 5,
    );
    final ProviderContainer container = containerWith(remote);
    final provider = newsFeedControllerProvider(NewsCategory.general);

    await container.read(provider.notifier).retry();
    expect((container.read(provider) as NewsFeedReady).articles, hasLength(5));

    remote.throwOnCall = const UnknownFailure(debugMessage: 'boom');
    await container.read(provider.notifier).refresh();

    final NewsFeedReady ready = container.read(provider) as NewsFeedReady;
    expect(ready.articles, hasLength(5));
    expect(ready.pageFailure, isA<UnknownFailure>());
    expect(ready.activity, FeedActivity.idle);
  });

  test('different categories own independent state', () async {
    final ProviderContainer container = containerWith(
      FakeNewsRemoteDataSource(totalResults: 12, articlesPerPage: 5),
    );

    final general = newsFeedControllerProvider(NewsCategory.general);
    final sports = newsFeedControllerProvider(NewsCategory.sports);

    await container.read(general.notifier).retry();

    expect(container.read(general), isA<NewsFeedReady>());
    expect(container.read(sports), isA<NewsFeedLoading>());
  });

  test('refreshing the feed never replaces search results', () async {
    final ProviderContainer container = containerWith(
      FakeNewsRemoteDataSource(totalResults: 12, articlesPerPage: 5),
    );

    final feed = newsFeedControllerProvider(NewsCategory.general);
    final search = searchControllerProvider('flutter');

    await container.read(feed.notifier).retry();
    await container.read(search.notifier).refresh();

    final SearchReady before = container.read(search) as SearchReady;

    await container.read(feed.notifier).refresh();

    final SearchReady after = container.read(search) as SearchReady;
    expect(after.articles, before.articles);
    expect(container.read(feed), isA<NewsFeedReady>());
  });
}
