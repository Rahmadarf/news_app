import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';
import 'package:news_app/features/search/presentation/state/search_state.dart';

/// One controller per query string, disposed with the results screen.
final searchControllerProvider = NotifierProvider.autoDispose
    .family<SearchResultsController, SearchState, String>(
      SearchResultsController.new,
    );

class SearchResultsController extends Notifier<SearchState> {
  SearchResultsController(this.query);

  final String query;

  NewsRepository get _repository => ref.read(newsRepositoryProvider);

  @override
  SearchState build() {
    Future<void>.microtask(_loadFirstPage);
    return const SearchLoading();
  }

  Future<void> _loadFirstPage() async {
    try {
      final ArticleFeed feed = await _repository.searchArticles(query: query);
      if (!ref.mounted) return;
      state = SearchReady(
        articles: feed.articles,
        loadedPages: feed.page,
        hasMore: feed.hasMore,
        totalResults: feed.totalResults,
      );
    } on Failure catch (failure) {
      if (!ref.mounted) return;
      state = SearchError(failure);
    }
  }

  /// Re-runs the same query. Never falls back to a category feed.
  Future<void> refresh() async {
    state = const SearchLoading();
    await _loadFirstPage();
  }

  Future<void> loadMore() async {
    final SearchState current = state;
    if (current is! SearchReady) return;
    if (!current.hasMore || current.activity != FeedActivity.idle) return;

    state = current.copyWith(
      activity: FeedActivity.loadingMore,
      clearPageFailure: true,
    );

    final int nextPage = current.loadedPages + 1;

    try {
      final ArticleFeed feed = await _repository.searchArticles(
        query: query,
        page: nextPage,
      );
      if (!ref.mounted) return;

      final Set<String> seen = current.articles
          .map((Article a) => a.url)
          .toSet();
      final List<Article> merged = List<Article>.of(current.articles);
      for (final Article article in feed.articles) {
        if (seen.add(article.url)) merged.add(article);
      }

      state = current.copyWith(
        articles: List<Article>.unmodifiable(merged),
        loadedPages: nextPage,
        hasMore: feed.hasMore,
        activity: FeedActivity.idle,
      );
    } on Failure catch (failure) {
      if (!ref.mounted) return;
      state = current.copyWith(
        activity: FeedActivity.idle,
        pageFailure: failure,
      );
    }
  }
}
