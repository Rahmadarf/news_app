import 'package:flutter/foundation.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';

/// What the feed is currently doing on top of whatever it already shows.
///
/// An enum rather than a set of booleans, so "refreshing" and "loading more"
/// cannot both be true; see docs/AUDIT.md M-5.
enum FeedActivity { idle, refreshing, loadingMore }

/// Immutable state of one category feed.
///
/// The union covers every condition the screen must express, without any
/// conflicting flags:
///
/// | Condition   | Representation                                     |
/// |-------------|----------------------------------------------------|
/// | loading     | [NewsFeedLoading]                                  |
/// | error       | [NewsFeedError]                                    |
/// | data        | [NewsFeedReady] with a non-empty `articles`        |
/// | empty       | [NewsFeedReady] with an empty `articles`           |
/// | refreshing  | [NewsFeedReady] with `activity == refreshing`      |
/// | paginating  | [NewsFeedReady] with `activity == loadingMore`     |
/// | offline     | [NewsFeedReady] with `origin == staleCache`        |
/// | page failed | [NewsFeedReady] with a non-null `pageFailure`      |
@immutable
sealed class NewsFeedState {
  const NewsFeedState();
}

/// First load in flight; nothing to show yet.
final class NewsFeedLoading extends NewsFeedState {
  const NewsFeedLoading();
}

/// First load failed; there is nothing to show.
final class NewsFeedError extends NewsFeedState {
  const NewsFeedError(this.failure);

  final Failure failure;
}

/// Articles are available. May be empty, refreshing, paginating, or stale.
final class NewsFeedReady extends NewsFeedState {
  const NewsFeedReady({
    required this.articles,
    required this.loadedPages,
    required this.hasMore,
    required this.origin,
    this.activity = FeedActivity.idle,
    this.pageFailure,
    this.fetchedAt,
  });

  final List<Article> articles;

  /// How many pages have been merged into [articles]. The next page to request
  /// is `loadedPages + 1`.
  final int loadedPages;

  final bool hasMore;
  final DataOrigin origin;
  final FeedActivity activity;

  /// A failure that happened while loading a further page or refreshing, while
  /// existing articles stay on screen. Distinct from [NewsFeedError], which
  /// means there is nothing to show at all.
  final Failure? pageFailure;

  final DateTime? fetchedAt;

  bool get isEmpty => articles.isEmpty;
  bool get isStale => origin == DataOrigin.staleCache;
  bool get isRefreshing => activity == FeedActivity.refreshing;
  bool get isLoadingMore => activity == FeedActivity.loadingMore;

  NewsFeedReady copyWith({
    List<Article>? articles,
    int? loadedPages,
    bool? hasMore,
    DataOrigin? origin,
    FeedActivity? activity,
    DateTime? fetchedAt,
    bool clearPageFailure = false,
    Failure? pageFailure,
  }) {
    return NewsFeedReady(
      articles: articles ?? this.articles,
      loadedPages: loadedPages ?? this.loadedPages,
      hasMore: hasMore ?? this.hasMore,
      origin: origin ?? this.origin,
      activity: activity ?? this.activity,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      pageFailure: clearPageFailure ? null : (pageFailure ?? this.pageFailure),
    );
  }
}
