import 'package:flutter/foundation.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';
import 'package:news_app/features/search/domain/entities/search_sort.dart';

/// Immutable state of the Discover screen.
///
/// [query] and [sort] are the inputs; [results] is what they produced. Keeping
/// the inputs on the state means the field, the sort control, and the list can
/// never disagree about what is being shown.
@immutable
class DiscoverState {
  const DiscoverState({
    this.query = '',
    this.sort = SearchSort.fallback,
    this.results = const DiscoverIdle(),
  });

  /// The submitted or debounced term currently driving [results].
  final String query;
  final SearchSort sort;
  final DiscoverResults results;

  bool get hasQuery => query.trim().isNotEmpty;

  DiscoverState copyWith({
    String? query,
    SearchSort? sort,
    DiscoverResults? results,
  }) {
    return DiscoverState(
      query: query ?? this.query,
      sort: sort ?? this.sort,
      results: results ?? this.results,
    );
  }
}

/// What the results area is showing.
@immutable
sealed class DiscoverResults {
  const DiscoverResults();
}

/// No query yet: the screen shows recent searches and publisher shortcuts.
final class DiscoverIdle extends DiscoverResults {
  const DiscoverIdle();
}

/// A first page is in flight.
final class DiscoverLoading extends DiscoverResults {
  const DiscoverLoading();
}

/// The query failed with nothing to show.
final class DiscoverError extends DiscoverResults {
  const DiscoverError(this.failure);

  final Failure failure;
}

/// Results are available. May be empty, or paginating.
final class DiscoverReady extends DiscoverResults {
  const DiscoverReady({
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

  DiscoverReady copyWith({
    List<Article>? articles,
    int? loadedPages,
    bool? hasMore,
    int? totalResults,
    FeedActivity? activity,
    bool clearPageFailure = false,
    Failure? pageFailure,
  }) {
    return DiscoverReady(
      articles: articles ?? this.articles,
      loadedPages: loadedPages ?? this.loadedPages,
      hasMore: hasMore ?? this.hasMore,
      totalResults: totalResults ?? this.totalResults,
      activity: activity ?? this.activity,
      pageFailure: clearPageFailure ? null : (pageFailure ?? this.pageFailure),
    );
  }
}
