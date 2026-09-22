import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/data/datasources/news_api_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';
import 'package:news_app/features/news/data/mappers/article_mapper.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/search/domain/entities/search_sort.dart';

/// Default page size for every paginated request.
const int kNewsPageSize = 20;

/// How long a cached headline page is considered fresh.
const Duration kFeedCacheTtl = Duration(minutes: 15);

/// How many results NewsAPI will serve for one query before it refuses.
///
/// On the Developer plan, asking past the hundredth result returns HTTP 426
/// `maximumResultsReached` — `totalResults` still reports the full match count,
/// so believing it would make the UI offer a page that is guaranteed to fail.
/// A paid plan raises this; it is a constructor parameter for that reason.
const int kNewsMaxResultWindow = 100;

/// Repository over one explicitly supplied remote source plus the local cache.
///
/// The active remote source — live NewsAPI or local fixtures — is chosen once
/// during bootstrap and injected here; this class never decides for itself.
///
/// Caching policy:
///
/// - **Headlines are cached** per `country:category` and page. A page younger
///   than [ttl] is served from storage and no request is made.
/// - **Refresh** ([NewsRepository.getTopHeadlines] with `forceRefresh`) ignores
///   the TTL, re-requests page 1, and drops every previously cached page of
///   that feed, so an accumulated list cannot mix old and new pagination.
/// - **Offline** falls back to the stored page and reports
///   [DataOrigin.staleCache]. With nothing stored, the connectivity failure is
///   rethrown.
/// - **Searches are not cached.** A search cache grows without bound across
///   distinct queries, and stale results are more misleading than stale
///   headlines because the user just expressed a fresh intent.
class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl({
    required NewsRemoteDataSource remote,
    required NewsLocalDataSource local,
    String country = defaultCountry,
    int pageSize = kNewsPageSize,
    Duration ttl = kFeedCacheTtl,
    int maxResultWindow = kNewsMaxResultWindow,
    Clock? clock,
  }) : _remote = remote,
       _local = local,
       _country = country,
       _pageSize = pageSize,
       _ttl = ttl,
       _maxResultWindow = maxResultWindow,
       _clock = clock ?? const Clock();

  static const String defaultCountry = 'us';

  final NewsRemoteDataSource _remote;
  final NewsLocalDataSource _local;
  final String _country;
  final int _pageSize;
  final Duration _ttl;
  final int _maxResultWindow;
  final Clock _clock;

  @override
  Future<ArticleFeed> getTopHeadlines({
    required NewsCategory category,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final String key = NewsLocalDataSource.feedKey(
      country: _country,
      category: category.apiValue,
    );

    if (forceRefresh) {
      // Page 1 is the only meaningful refresh target; keeping pages 2..n would
      // leave the merged list straddling two different server orderings.
      await _tryClearFeed(key);
    } else {
      final CachedFeedPage? cached = await _tryReadPage(key: key, page: page);
      if (cached != null && _isFresh(cached.fetchedAt)) {
        return _feedFromCache(cached, page: page, origin: DataOrigin.cache);
      }
    }

    try {
      final NewsResponseDto dto = await _remote.fetchTopHeadlines(
        country: _country,
        category: category.apiValue,
        page: page,
        pageSize: _pageSize,
      );

      final DateTime fetchedAt = _clock.now().toUtc();

      // Drop anything already stored for an earlier page of this feed, so a
      // record the API repeats across pages appears only once.
      final Set<String> seen = await _tryUrlsBeforePage(key: key, page: page);
      final List<Article> articles = List<Article>.unmodifiable(
        ArticleMapper.toEntities(
          dto.articles,
        ).where((Article a) => !seen.contains(a.url)),
      );

      // Derived from the raw total, not the filtered list, so discarding
      // invalid records cannot make pagination stop early — and capped at the
      // plan's result window, so it cannot offer a page the API will refuse.
      final bool hasMore = _hasMore(page: page, total: dto.totalResults);

      await _tryWritePage(
        key: key,
        page: page,
        articles: articles,
        fetchedAt: fetchedAt,
        totalResults: dto.totalResults,
        hasMore: hasMore,
      );

      return ArticleFeed(
        articles: articles,
        page: page,
        hasMore: hasMore,
        totalResults: dto.totalResults,
        origin: DataOrigin.network,
        fetchedAt: fetchedAt,
      );
    } on Object catch (error) {
      final Failure failure = _toFailure(error);

      // Only connectivity problems justify showing old data. A rejected key or
      // a malformed body must surface, not hide behind a stale list.
      if (failure is NoConnectionFailure || failure is TimeoutFailure) {
        final CachedFeedPage? stale = await _tryReadPage(key: key, page: page);
        if (stale != null) {
          return _feedFromCache(
            stale,
            page: page,
            origin: DataOrigin.staleCache,
          );
        }
      }

      throw failure;
    }
  }

  @override
  Future<ArticleFeed> searchArticles({
    required String query,
    int page = 1,
    SearchSort sort = SearchSort.fallback,
  }) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return ArticleFeed(
        articles: const <Article>[],
        page: page,
        hasMore: false,
        totalResults: 0,
        origin: DataOrigin.network,
      );
    }

    try {
      final NewsResponseDto dto = await _remote.searchEverything(
        query: trimmed,
        page: page,
        pageSize: _pageSize,
        sortBy: sort.apiValue,
      );

      return ArticleFeed(
        articles: ArticleMapper.toEntities(dto.articles),
        page: page,
        hasMore: _hasMore(page: page, total: dto.totalResults),
        totalResults: dto.totalResults,
        origin: DataOrigin.network,
        fetchedAt: _clock.now().toUtc(),
      );
    } on Object catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<Article?> findCachedArticle(String url) async {
    final String? canonical = ArticleMapper.canonicalizeUrl(url);
    if (canonical == null) return null;
    try {
      return await _local.findByUrl(canonical);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _local.clearAll();
    } on Object catch (error) {
      throw CacheFailure(debugMessage: error.toString());
    }
  }

  /// Whether a further page exists *and* is allowed by the plan.
  bool _hasMore({required int page, required int total}) {
    final int reachable = total < _maxResultWindow ? total : _maxResultWindow;
    return page * _pageSize < reachable;
  }

  bool _isFresh(DateTime fetchedAt) =>
      _clock.now().toUtc().difference(fetchedAt.toUtc()) < _ttl;

  ArticleFeed _feedFromCache(
    CachedFeedPage cached, {
    required int page,
    required DataOrigin origin,
  }) {
    return ArticleFeed(
      articles: cached.articles,
      page: page,
      hasMore: cached.hasMore,
      totalResults: cached.totalResults,
      origin: origin,
      fetchedAt: cached.fetchedAt,
    );
  }

  // Storage problems must never turn a working network request into an error,
  // so reads degrade to "no cache" and writes are best-effort. The only
  // storage error surfaced to callers comes from clearCache.

  Future<CachedFeedPage?> _tryReadPage({
    required String key,
    required int page,
  }) async {
    try {
      return await _local.readPage(key: key, page: page);
    } on Object {
      return null;
    }
  }

  Future<Set<String>> _tryUrlsBeforePage({
    required String key,
    required int page,
  }) async {
    try {
      return await _local.urlsBeforePage(key: key, beforePage: page);
    } on Object {
      return const <String>{};
    }
  }

  Future<void> _tryWritePage({
    required String key,
    required int page,
    required List<Article> articles,
    required DateTime fetchedAt,
    required int totalResults,
    required bool hasMore,
  }) async {
    try {
      await _local.writePage(
        key: key,
        page: page,
        articles: articles,
        fetchedAt: fetchedAt,
        totalResults: totalResults,
        hasMore: hasMore,
      );
    } on Object {
      // Best effort: the caller already has a valid result.
    }
  }

  Future<void> _tryClearFeed(String key) async {
    try {
      await _local.clearFeed(key);
    } on Object {
      // Best effort.
    }
  }

  /// Converts every technical outcome into a typed [Failure].
  static Failure _toFailure(Object error) {
    return switch (error) {
      Failure() => error,
      NewsApiException() => mapApiException(error),
      TimeoutException() => TimeoutFailure(debugMessage: error.toString()),
      SocketException() => NoConnectionFailure(debugMessage: error.message),
      http.ClientException() => NoConnectionFailure(
        debugMessage: error.message,
      ),
      FormatException() => MalformedResponseFailure(
        debugMessage: error.message,
      ),
      TypeError() => MalformedResponseFailure(debugMessage: error.toString()),
      _ => UnknownFailure(debugMessage: error.toString()),
    };
  }

  /// Maps a NewsAPI status/code pair onto a typed [Failure].
  ///
  /// Exposed for tests. The status code takes priority; the body's `code`
  /// disambiguates responses that arrive with an unexpected status.
  static Failure mapApiException(NewsApiException error) {
    return switch (error.statusCode) {
      400 => MalformedResponseFailure(debugMessage: error.message),
      401 || 403 => UnauthorizedFailure(debugMessage: error.message),
      426 => UpgradeRequiredFailure(debugMessage: error.message),
      429 => RateLimitedFailure(debugMessage: error.message),
      >= 500 => ServerFailure(
        statusCode: error.statusCode,
        debugMessage: error.message,
      ),
      _ => switch (error.code) {
        'apiKeyInvalid' ||
        'apiKeyMissing' ||
        'apiKeyDisabled' => UnauthorizedFailure(debugMessage: error.message),
        'rateLimited' ||
        'apiKeyExhausted' => RateLimitedFailure(debugMessage: error.message),
        'maximumResultsReached' => UpgradeRequiredFailure(
          debugMessage: error.message,
        ),
        _ => ServerFailure(
          statusCode: error.statusCode,
          debugMessage: error.message,
        ),
      },
    };
  }
}
