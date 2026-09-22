import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/search/domain/entities/search_sort.dart';
import 'package:news_app/features/search/domain/repositories/recent_search_repository.dart';
import 'package:news_app/features/search/presentation/controllers/discover_controller.dart';
import 'package:news_app/features/search/presentation/state/discover_state.dart';

import '../../support/fake_news_remote_data_source.dart';
import '../../support/test_database.dart';

/// Repository whose search completions the test releases by hand, so
/// out-of-order responses can be produced deliberately.
class _ControllableRepository implements NewsRepository {
  final List<Completer<ArticleFeed>> pending = <Completer<ArticleFeed>>[];
  final List<String> queries = <String>[];
  final List<SearchSort> sorts = <SearchSort>[];

  @override
  Future<ArticleFeed> searchArticles({
    required String query,
    int page = 1,
    SearchSort sort = SearchSort.fallback,
  }) {
    queries.add(query);
    sorts.add(sort);
    final Completer<ArticleFeed> completer = Completer<ArticleFeed>();
    pending.add(completer);
    return completer.future;
  }

  /// Completes the request at [index] with one article titled [title].
  void complete(int index, String title) {
    pending[index].complete(
      ArticleFeed(
        articles: <Article>[
          Article(
            url: 'https://example.com/${title.hashCode}',
            title: title,
            source: const ArticleSource(name: 'Fake Source'),
          ),
        ],
        page: 1,
        hasMore: false,
        totalResults: 1,
        origin: DataOrigin.network,
      ),
    );
  }

  @override
  Future<ArticleFeed> getTopHeadlines({
    required NewsCategory category,
    int page = 1,
    bool forceRefresh = false,
  }) async => const ArticleFeed.empty();

  @override
  Future<Article?> findCachedArticle(String url) async => null;

  @override
  Future<void> clearCache() async {}
}

/// In-memory recent searches, so these controller tests do not touch Drift.
class _FakeRecentSearchRepository implements RecentSearchRepository {
  final List<String> recorded = <String>[];

  @override
  Stream<List<String>> watchRecent() =>
      Stream<List<String>>.value(List<String>.of(recorded));

  @override
  Future<void> record(String query) async => recorded.insert(0, query);

  @override
  Future<void> remove(String query) async => recorded.remove(query);

  @override
  Future<void> clear() async => recorded.clear();
}

void main() {
  ProviderContainer containerWith(
    NewsRepository repository, {
    RecentSearchRepository? recent,
  }) {
    final ProviderContainer container = ProviderContainer.test(
      overrides: <Override>[
        newsRepositoryProvider.overrideWithValue(repository),
        recentSearchRepositoryProvider.overrideWithValue(
          recent ?? _FakeRecentSearchRepository(),
        ),
      ],
    );

    // The controller is autoDispose, so it needs a listener to stay alive for
    // the duration of the test. Without one it is torn down between calls.
    container.listen<DiscoverState>(
      discoverControllerProvider,
      (DiscoverState? previous, DiscoverState next) {},
      fireImmediately: true,
    );

    return container;
  }

  group('debounce', () {
    test('a burst of keystrokes produces a single request', () {
      fakeAsync((FakeAsync async) {
        final _ControllableRepository repository = _ControllableRepository();
        final ProviderContainer container = containerWith(repository);
        final DiscoverController controller = container.read(
          discoverControllerProvider.notifier,
        );

        for (final String value in <String>['fl', 'flu', 'flut', 'flutter']) {
          controller.queryChanged(value);
          async.elapse(const Duration(milliseconds: 100));
        }
        async.elapse(DiscoverController.debounce);

        expect(repository.queries, <String>['flutter']);
      });
    });

    test('a query shorter than the minimum never reaches the repository', () {
      fakeAsync((FakeAsync async) {
        final _ControllableRepository repository = _ControllableRepository();
        final ProviderContainer container = containerWith(repository);

        container.read(discoverControllerProvider.notifier).queryChanged('f');
        async.elapse(const Duration(seconds: 2));

        expect(repository.queries, isEmpty);
        expect(
          container.read(discoverControllerProvider).results,
          isA<DiscoverIdle>(),
        );
      });
    });
  });

  group('stale results', () {
    test('a late answer to an older query is discarded', () async {
      final _ControllableRepository repository = _ControllableRepository();
      final ProviderContainer container = containerWith(repository);
      final DiscoverController controller = container.read(
        discoverControllerProvider.notifier,
      );

      unawaited(controller.submit('kota'));
      unawaited(controller.submit('energi'));
      expect(repository.queries, <String>['kota', 'energi']);

      // The newer request answers first, then the older one arrives late.
      repository.complete(1, 'Energi');
      await Future<void>.delayed(Duration.zero);
      repository.complete(0, 'Kota');
      await Future<void>.delayed(Duration.zero);

      final DiscoverResults results = container
          .read(discoverControllerProvider)
          .results;
      expect(results, isA<DiscoverReady>());
      expect(
        (results as DiscoverReady).articles.single.title,
        'Energi',
        reason: 'the stale answer must not overwrite the newer one',
      );
    });

    test('clearing discards an in-flight request', () async {
      final _ControllableRepository repository = _ControllableRepository();
      final ProviderContainer container = containerWith(repository);
      final DiscoverController controller = container.read(
        discoverControllerProvider.notifier,
      );

      unawaited(controller.submit('kota'));
      controller.clear();
      repository.complete(0, 'Kota');
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(discoverControllerProvider).results,
        isA<DiscoverIdle>(),
      );
    });
  });

  test('submitting records the term; typing does not', () async {
    final _FakeRecentSearchRepository recent = _FakeRecentSearchRepository();
    final _ControllableRepository repository = _ControllableRepository();
    final ProviderContainer container = containerWith(
      repository,
      recent: recent,
    );
    final DiscoverController controller = container.read(
      discoverControllerProvider.notifier,
    );

    controller.queryChanged('kota');
    expect(recent.recorded, isEmpty);

    unawaited(controller.submit('kota'));
    await Future<void>.delayed(Duration.zero);

    expect(recent.recorded, <String>['kota']);
  });

  group('sort', () {
    test('changing the sort re-runs the query with the new ordering', () async {
      final _ControllableRepository repository = _ControllableRepository();
      final ProviderContainer container = containerWith(repository);
      final DiscoverController controller = container.read(
        discoverControllerProvider.notifier,
      );

      unawaited(controller.submit('kota'));
      controller.sortChanged(SearchSort.newest);

      expect(repository.queries, <String>['kota', 'kota']);
      expect(repository.sorts.last, SearchSort.newest);
    });

    test('the sort reaches the API as sortBy', () async {
      final FakeNewsRemoteDataSource remote = FakeNewsRemoteDataSource(
        totalResults: 5,
        articlesPerPage: 5,
      );
      final NewsRepositoryImpl repository = NewsRepositoryImpl(
        remote: remote,
        local: NewsLocalDataSource(newTestDatabase()),
      );

      await repository.searchArticles(
        query: 'kota',
        sort: SearchSort.popularity,
      );

      expect(remote.lastSortBy, 'popularity');
    });
  });

  group('failures', () {
    test('a failed query produces an error result', () async {
      final _ControllableRepository repository = _ControllableRepository();
      final ProviderContainer container = containerWith(repository);
      final DiscoverController controller = container.read(
        discoverControllerProvider.notifier,
      );

      unawaited(controller.submit('kota'));
      repository.pending.first.completeError(
        const NoConnectionFailure(debugMessage: 'offline'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(discoverControllerProvider).results,
        isA<DiscoverError>(),
      );
    });
  });
}
