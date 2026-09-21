import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';

/// One feed per category, scoped to the screens that watch it.
///
/// `autoDispose` plus `family` replaces the former permanent singleton: each
/// category owns its own state, nothing is retained after the last listener
/// goes away, and a category feed can never be overwritten by search results.
/// See docs/AUDIT.md H-2 and H-6.
final newsFeedControllerProvider = NotifierProvider.autoDispose
    .family<NewsFeedController, NewsFeedState, NewsCategory>(
      NewsFeedController.new,
    );

class NewsFeedController extends Notifier<NewsFeedState> {
  NewsFeedController(this.category);

  final NewsCategory category;

  NewsRepository get _repository => ref.read(newsRepositoryProvider);

  @override
  NewsFeedState build() {
    // Kick the first load off without blocking the initial frame, then report
    // through the same state machine every later transition uses.
    Future<void>.microtask(_loadFirstPage);
    return const NewsFeedLoading();
  }

  Future<void> _loadFirstPage() async {
    try {
      final ArticleFeed feed = await _repository.getTopHeadlines(
        category: category,
      );
      if (!ref.mounted) return;
      state = NewsFeedReady(
        articles: feed.articles,
        loadedPages: feed.page,
        hasMore: feed.hasMore,
        origin: feed.origin,
        fetchedAt: feed.fetchedAt,
      );
    } on Failure catch (failure) {
      if (!ref.mounted) return;
      state = NewsFeedError(failure);
    }
  }

  /// Explicit refresh semantics: discard the accumulated pages and re-request
  /// page 1, bypassing any fresh cache entry. Existing articles stay on screen
  /// while the request is in flight.
  Future<void> refresh() async {
    final NewsFeedState current = state;

    if (current is! NewsFeedReady) {
      state = const NewsFeedLoading();
      await _loadFirstPage();
      return;
    }

    if (current.activity != FeedActivity.idle) return;

    state = current.copyWith(
      activity: FeedActivity.refreshing,
      clearPageFailure: true,
    );

    try {
      final ArticleFeed feed = await _repository.getTopHeadlines(
        category: category,
        forceRefresh: true,
      );
      if (!ref.mounted) return;
      state = NewsFeedReady(
        articles: feed.articles,
        loadedPages: feed.page,
        hasMore: feed.hasMore,
        origin: feed.origin,
        fetchedAt: feed.fetchedAt,
      );
    } on Failure catch (failure) {
      if (!ref.mounted) return;
      // Keep showing what the user already had; report the failure alongside.
      state = current.copyWith(
        activity: FeedActivity.idle,
        pageFailure: failure,
      );
    }
  }

  /// Appends the next page. No-op when already busy or at the end.
  Future<void> loadMore() async {
    final NewsFeedState current = state;
    if (current is! NewsFeedReady) return;
    if (!current.hasMore || current.activity != FeedActivity.idle) return;

    state = current.copyWith(
      activity: FeedActivity.loadingMore,
      clearPageFailure: true,
    );

    final int nextPage = current.loadedPages + 1;

    try {
      final ArticleFeed feed = await _repository.getTopHeadlines(
        category: category,
        page: nextPage,
      );
      if (!ref.mounted) return;

      state = current.copyWith(
        articles: _mergeUnique(current.articles, feed.articles),
        loadedPages: nextPage,
        hasMore: feed.hasMore,
        origin: feed.origin,
        activity: FeedActivity.idle,
        fetchedAt: feed.fetchedAt,
      );
    } on Failure catch (failure) {
      if (!ref.mounted) return;
      state = current.copyWith(
        activity: FeedActivity.idle,
        pageFailure: failure,
      );
    }
  }

  /// Retries after a first-load failure.
  Future<void> retry() async {
    state = const NewsFeedLoading();
    await _loadFirstPage();
  }

  /// Articles are identified by canonical URL, so a record repeated across
  /// pages is appended only once. Part 4 moves this into the repository and
  /// covers it with dedicated tests.
  static List<Article> _mergeUnique(
    List<Article> existing,
    List<Article> incoming,
  ) {
    final Set<String> seen = existing.map((Article a) => a.url).toSet();
    final List<Article> merged = List<Article>.of(existing);
    for (final Article article in incoming) {
      if (seen.add(article.url)) merged.add(article);
    }
    return List<Article>.unmodifiable(merged);
  }
}
