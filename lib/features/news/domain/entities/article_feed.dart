import 'package:news_app/features/news/domain/entities/article.dart';

/// Where a feed's articles came from.
///
/// Presentation uses this to tell the user they are looking at stored data.
/// Part 3 always reports [network]; the cache-backed values become reachable
/// once local persistence lands.
enum DataOrigin {
  /// Fetched from the remote source during this request.
  network,

  /// Served from local storage while still within its TTL.
  cache,

  /// Served from local storage after its TTL expired, because the network was
  /// unavailable. The user is looking at old data.
  staleCache,
}

/// One page of articles plus the metadata presentation needs to decide what to
/// render. Repository callers never see API response shapes.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
class ArticleFeed {
  const ArticleFeed({
    required this.articles,
    required this.page,
    required this.hasMore,
    required this.totalResults,
    required this.origin,
    this.fetchedAt,
  });

  const ArticleFeed.empty()
    : articles = const <Article>[],
      page = 1,
      hasMore = false,
      totalResults = 0,
      origin = DataOrigin.network,
      fetchedAt = null;

  final List<Article> articles;

  /// 1-based page index this result represents.
  final int page;

  /// Whether a further page is expected to exist.
  final bool hasMore;

  /// Total matches reported by the source, across all pages.
  final int totalResults;

  final DataOrigin origin;

  /// When the data was originally retrieved from the remote source. Populated
  /// once caching lands; used to show a "last updated" marker.
  final DateTime? fetchedAt;

  bool get isStale => origin == DataOrigin.staleCache;
}
