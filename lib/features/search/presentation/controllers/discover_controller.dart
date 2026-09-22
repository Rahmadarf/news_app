import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';
import 'package:news_app/features/search/domain/entities/search_sort.dart';
import 'package:news_app/features/search/domain/repositories/recent_search_repository.dart';
import 'package:news_app/features/search/presentation/state/discover_state.dart';

final discoverControllerProvider =
    NotifierProvider.autoDispose<DiscoverController, DiscoverState>(
      DiscoverController.new,
    );

/// Drives the Discover screen.
///
/// Two protections matter here:
///
/// * **Debounce** — keystrokes do not each become a request. Only the last
///   one within [debounce] is sent.
/// * **Stale-result rejection** — every request carries a generation number.
///   A response whose generation is no longer current is discarded, so a slow
///   answer to an old query can never overwrite a newer one.
class DiscoverController extends Notifier<DiscoverState> {
  /// Quiet period before a typed query is sent.
  static const Duration debounce = Duration(milliseconds: 350);

  /// Queries shorter than this are ignored; a single letter matches
  /// everything and wastes quota.
  static const int minimumQueryLength = 2;

  Timer? _debounceTimer;

  /// Incremented for every new query or sort. Responses tagged with an older
  /// value are dropped.
  int _generation = 0;

  NewsRepository get _repository => ref.read(newsRepositoryProvider);
  RecentSearchRepository get _recent =>
      ref.read(recentSearchRepositoryProvider);

  @override
  DiscoverState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const DiscoverState();
  }

  /// Called on every keystroke.
  void queryChanged(String value) {
    _debounceTimer?.cancel();

    final String trimmed = value.trim();
    state = state.copyWith(query: value);

    if (trimmed.length < minimumQueryLength) {
      // Back to the idle screen; cancel anything in flight by bumping the
      // generation so a late response cannot land.
      _generation++;
      state = state.copyWith(results: const DiscoverIdle());
      return;
    }

    _debounceTimer = Timer(debounce, () => _run(trimmed));
  }

  /// Called when the field is submitted, or a recent term or publisher is
  /// tapped. Bypasses the debounce and records the term.
  Future<void> submit(String value) async {
    _debounceTimer?.cancel();

    final String trimmed = value.trim();
    state = state.copyWith(query: value);

    if (trimmed.length < minimumQueryLength) {
      _generation++;
      state = state.copyWith(results: const DiscoverIdle());
      return;
    }

    // Only submitted terms are remembered; keystrokes are not.
    unawaited(_recent.record(trimmed));
    await _run(trimmed);
  }

  void sortChanged(SearchSort sort) {
    if (state.sort == sort) return;
    state = state.copyWith(sort: sort);

    final String trimmed = state.query.trim();
    if (trimmed.length < minimumQueryLength) return;
    unawaited(_run(trimmed));
  }

  void clear() {
    _debounceTimer?.cancel();
    _generation++;
    state = const DiscoverState();
  }

  Future<void> refresh() async {
    final String trimmed = state.query.trim();
    if (trimmed.length < minimumQueryLength) return;
    await _run(trimmed);
  }

  Future<void> _run(String query) async {
    final int generation = ++_generation;
    state = state.copyWith(results: const DiscoverLoading());

    try {
      final ArticleFeed feed = await _repository.searchArticles(
        query: query,
        sort: state.sort,
      );
      if (!ref.mounted || generation != _generation) return;

      state = state.copyWith(
        results: DiscoverReady(
          articles: feed.articles,
          loadedPages: feed.page,
          hasMore: feed.hasMore,
          totalResults: feed.totalResults,
        ),
      );
    } on Failure catch (failure) {
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(results: DiscoverError(failure));
    }
  }

  Future<void> loadMore() async {
    final DiscoverResults current = state.results;
    if (current is! DiscoverReady) return;
    if (!current.hasMore || current.activity != FeedActivity.idle) return;

    final int generation = _generation;
    final int nextPage = current.loadedPages + 1;

    state = state.copyWith(
      results: current.copyWith(
        activity: FeedActivity.loadingMore,
        clearPageFailure: true,
      ),
    );

    try {
      final ArticleFeed feed = await _repository.searchArticles(
        query: state.query.trim(),
        page: nextPage,
        sort: state.sort,
      );
      if (!ref.mounted || generation != _generation) return;

      final Set<String> seen = current.articles
          .map((Article a) => a.url)
          .toSet();
      final List<Article> merged = List<Article>.of(current.articles);
      for (final Article article in feed.articles) {
        if (seen.add(article.url)) merged.add(article);
      }

      state = state.copyWith(
        results: current.copyWith(
          articles: List<Article>.unmodifiable(merged),
          loadedPages: nextPage,
          hasMore: feed.hasMore,
          activity: FeedActivity.idle,
        ),
      );
    } on Failure catch (failure) {
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(
        results: current.copyWith(
          activity: FeedActivity.idle,
          pageFailure: failure,
        ),
      );
    }
  }
}

/// Recent search terms, most recent first.
final recentSearchesProvider = StreamProvider<List<String>>((Ref ref) {
  return ref.watch(recentSearchRepositoryProvider).watchRecent();
});
