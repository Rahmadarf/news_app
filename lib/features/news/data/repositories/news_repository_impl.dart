import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/features/news/data/datasources/news_api_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';
import 'package:news_app/features/news/data/mappers/article_mapper.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

/// Default page size for every paginated request.
const int kNewsPageSize = 20;

/// Repository over a single, explicitly supplied remote source.
///
/// The active source — live NewsAPI or local mock — is chosen once during
/// bootstrap and injected here; this class never decides for itself.
///
/// Part 4 adds the local cache: fresh-cache hits that skip the request, stale
/// fallback when offline, TTL metadata, and cross-page deduplication. Until
/// then every call goes to [_remote] and reports [DataOrigin.network].
class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl({
    required NewsRemoteDataSource remote,
    String country = defaultCountry,
    int pageSize = kNewsPageSize,
  }) : _remote = remote,
       _country = country,
       _pageSize = pageSize;

  static const String defaultCountry = 'us';

  final NewsRemoteDataSource _remote;
  final String _country;
  final int _pageSize;

  @override
  Future<ArticleFeed> getTopHeadlines({
    required NewsCategory category,
    int page = 1,
    bool forceRefresh = false,
  }) {
    return _guard(
      () => _remote.fetchTopHeadlines(
        country: _country,
        category: category.apiValue,
        page: page,
        pageSize: _pageSize,
      ),
      page: page,
    );
  }

  @override
  Future<ArticleFeed> searchArticles({required String query, int page = 1}) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return Future<ArticleFeed>.value(_emptyPage(page));

    return _guard(
      () => _remote.searchEverything(
        query: trimmed,
        page: page,
        pageSize: _pageSize,
      ),
      page: page,
    );
  }

  ArticleFeed _emptyPage(int page) => ArticleFeed(
    articles: const <Article>[],
    page: page,
    hasMore: false,
    totalResults: 0,
    origin: DataOrigin.network,
  );

  /// Runs [request] and converts every technical outcome into either an
  /// [ArticleFeed] or a typed [Failure]. No transport exception escapes.
  Future<ArticleFeed> _guard(
    Future<NewsResponseDto> Function() request, {
    required int page,
  }) async {
    try {
      final NewsResponseDto dto = await request();
      final List<Article> articles = ArticleMapper.toEntities(dto.articles);

      // hasMore is derived from the raw page rather than the mapped list, so
      // dropping invalid records cannot make pagination stop early.
      final bool hasMore = page * _pageSize < dto.totalResults;

      return ArticleFeed(
        articles: articles,
        page: page,
        hasMore: hasMore,
        totalResults: dto.totalResults,
        origin: DataOrigin.network,
        fetchedAt: DateTime.now().toUtc(),
      );
    } on NewsApiException catch (error) {
      throw mapApiException(error);
    } on TimeoutException catch (error) {
      throw TimeoutFailure(debugMessage: error.toString());
    } on SocketException catch (error) {
      throw NoConnectionFailure(debugMessage: error.message);
    } on http.ClientException catch (error) {
      throw NoConnectionFailure(debugMessage: error.message);
    } on FormatException catch (error) {
      throw MalformedResponseFailure(debugMessage: error.message);
    } on TypeError catch (error) {
      throw MalformedResponseFailure(debugMessage: error.toString());
    }
  }

  /// Maps a NewsAPI status/code pair onto a typed [Failure].
  ///
  /// Exposed for tests; the status code takes priority, with the body's `code`
  /// used to disambiguate the 429 family.
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
        _ => ServerFailure(
          statusCode: error.statusCode,
          debugMessage: error.message,
        ),
      },
    };
  }
}
