import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/dto/article_dto.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';

/// Loads a fixture by asset key. Injectable so tests can read the same files
/// from disk without a Flutter asset bundle.
typedef FixtureLoader = Future<String> Function(String assetKey);

/// News source backed by JSON fixtures committed to the repository.
///
/// Consumes no NewsAPI quota, needs no key, and opens no socket. Behaviour is
/// deterministic: the same arguments always produce the same result.
///
/// The headline fixture deliberately contains records the mapper must reject —
/// a `"[Removed]"` tombstone, a record with no title, a record with no URL, a
/// syndicated duplicate carrying tracking parameters, and an unparsable
/// timestamp — so the filtering path is exercised during ordinary development,
/// not only in tests. Paging happens at the wire level, exactly as a real API
/// would, so a page can yield fewer articles than its page size.
class MockNewsDataSource implements NewsRemoteDataSource {
  MockNewsDataSource({FixtureLoader? loadFixture})
    : _loadFixture = loadFixture ?? rootBundle.loadString;

  static const String headlinesFixture = 'assets/fixtures/top_headlines.json';
  static const String searchFixture = 'assets/fixtures/search.json';

  final FixtureLoader _loadFixture;

  /// Fixtures are immutable, so parse each one only once per instance.
  final Map<String, List<ArticleDto>> _cache = <String, List<ArticleDto>>{};

  @override
  Future<NewsResponseDto> fetchTopHeadlines({
    required String country,
    required String category,
    required int page,
    required int pageSize,
  }) async {
    final List<ArticleDto> all = await _read(headlinesFixture);
    return _page(all, page: page, pageSize: pageSize);
  }

  @override
  Future<NewsResponseDto> searchEverything({
    required String query,
    required int page,
    required int pageSize,
    String? sortBy,
  }) async {
    final List<ArticleDto> all = await _read(searchFixture);

    // Case-insensitive substring match over title and description, so a query
    // that matches nothing produces a genuine empty result.
    final String needle = query.trim().toLowerCase();
    final List<ArticleDto> matches = needle.isEmpty
        ? all
        : all
              .where(
                (ArticleDto dto) =>
                    (dto.title ?? '').toLowerCase().contains(needle) ||
                    (dto.description ?? '').toLowerCase().contains(needle),
              )
              .toList(growable: false);

    // With no substring match, fall back to the whole fixture so an arbitrary
    // development query still shows something to lay out.
    final List<ArticleDto> results = matches.isEmpty ? all : matches;
    return _page(results, page: page, pageSize: pageSize);
  }

  Future<List<ArticleDto>> _read(String assetKey) async {
    final List<ArticleDto>? cached = _cache[assetKey];
    if (cached != null) return cached;

    final Object? decoded = json.decode(await _loadFixture(assetKey));
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Fixture $assetKey is not a JSON object');
    }

    final List<ArticleDto> parsed = NewsResponseDto.fromJson(decoded).articles;
    _cache[assetKey] = parsed;
    return parsed;
  }

  NewsResponseDto _page(
    List<ArticleDto> all, {
    required int page,
    required int pageSize,
  }) {
    final int safePage = page < 1 ? 1 : page;
    final int safePageSize = pageSize < 1 ? 1 : pageSize;
    final int start = (safePage - 1) * safePageSize;

    if (start >= all.length) {
      return NewsResponseDto(
        status: 'ok',
        totalResults: all.length,
        articles: const <ArticleDto>[],
      );
    }

    return NewsResponseDto(
      status: 'ok',
      totalResults: all.length,
      articles: all.sublist(start, (start + safePageSize).clamp(0, all.length)),
    );
  }
}
