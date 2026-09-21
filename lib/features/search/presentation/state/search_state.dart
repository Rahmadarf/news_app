import 'package:flutter/foundation.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';

/// Immutable state of one search query.
///
/// Structurally separate from `NewsFeedState`: a category refresh cannot reach
/// this state and a search cannot overwrite a category feed. See
/// docs/AUDIT.md H-6.
@immutable
sealed class SearchState {
  const SearchState();
}

/// Query in flight; nothing to show yet.
final class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Query failed with nothing to show.
final class SearchError extends SearchState {
  const SearchError(this.failure);

  final Failure failure;
}

/// Results are available. May be empty ("no matches") or paginating.
final class SearchReady extends SearchState {
  const SearchReady({
    required this.articles,
    required this.loadedPages,
    required this.hasMore,
    required this.totalResults,
    this.activity = FeedActivity.idle,
    this.pageFailure,
  });

  final List<Article> articles;
  final int loadedPages;
  final bool hasMore;
  final int totalResults;
  final FeedActivity activity;

  /// Failure while loading a further page, with results still on screen.
  final Failure? pageFailure;

  bool get isEmpty => articles.isEmpty;
  bool get isLoadingMore => activity == FeedActivity.loadingMore;

  SearchReady copyWith({
    List<Article>? articles,
    int? loadedPages,
    bool? hasMore,
    int? totalResults,
    FeedActivity? activity,
    bool clearPageFailure = false,
    Failure? pageFailure,
  }) {
    return SearchReady(
      articles: articles ?? this.articles,
      loadedPages: loadedPages ?? this.loadedPages,
      hasMore: hasMore ?? this.hasMore,
      totalResults: totalResults ?? this.totalResults,
      activity: activity ?? this.activity,
      pageFailure: clearPageFailure ? null : (pageFailure ?? this.pageFailure),
    );
  }
}
