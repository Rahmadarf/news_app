import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';

/// Technical failure raised for a non-2xx NewsAPI response.
///
/// Stays inside the data layer. The repository maps it onto a typed `Failure`.
class NewsApiException implements Exception {
  const NewsApiException({required this.statusCode, this.code, this.message});

  final int statusCode;

  /// NewsAPI error code, when the body carried one.
  final String? code;

  /// Developer-facing text. Never rendered as UI.
  final String? message;

  @override
  String toString() => 'NewsApiException($statusCode, code: $code)';
}

/// Talks to the real NewsAPI over HTTPS.
///
/// Live behaviour this class is responsible for:
///
/// * the key travels in a header, never in the URL or a log line;
/// * a bounded retry with backoff for the failures that are worth retrying,
///   honouring `Retry-After` when the service sends one;
/// * one explicit deadline per attempt.
class NewsApiDataSource implements NewsRemoteDataSource {
  NewsApiDataSource({
    required String apiKey,
    required http.Client client,
    Duration timeout = defaultTimeout,
    RetryPolicy retryPolicy = const RetryPolicy(),
    Future<void> Function(Duration)? sleep,
  }) : _apiKey = apiKey,
       _client = client,
       _timeout = timeout,
       _retryPolicy = retryPolicy,
       _sleep = sleep ?? Future<void>.delayed;

  static const String baseUrl = 'https://newsapi.org/v2';
  static const String topHeadlinesPath = '/top-headlines';
  static const String everythingPath = '/everything';

  /// Deadline for a single attempt, not for the whole retry sequence.
  static const Duration defaultTimeout = Duration(seconds: 15);

  final String _apiKey;
  final http.Client _client;
  final Duration _timeout;
  final RetryPolicy _retryPolicy;

  /// Injected so tests can advance the backoff without waiting.
  final Future<void> Function(Duration) _sleep;

  @override
  Future<NewsResponseDto> fetchTopHeadlines({
    required String country,
    required String category,
    required int page,
    required int pageSize,
  }) {
    return _get(topHeadlinesPath, <String, String>{
      'country': country,
      'category': category,
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  @override
  Future<NewsResponseDto> searchEverything({
    required String query,
    required int page,
    required int pageSize,
    String? sortBy,
  }) {
    return _get(everythingPath, <String, String>{
      'q': query,
      'page': '$page',
      'pageSize': '$pageSize',
      'sortBy': ?sortBy,
    });
  }

  Future<NewsResponseDto> _get(
    String path,
    Map<String, String> queryParameters,
  ) async {
    // Uri.replace percent-encodes the parameters, so a query containing spaces
    // or '&' cannot corrupt the request.
    final Uri uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParameters);

    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await _attempt(uri, attempt);
      } on NewsApiException catch (error) {
        final Duration? wait = _retryPolicy.delayFor(
          attempt: attempt,
          statusCode: error.statusCode,
          retryAfter: _lastRetryAfter,
        );
        if (wait == null) rethrow;
        _log(uri, 'retrying after ${wait.inMilliseconds}ms');
        await _sleep(wait);
      } on TimeoutException {
        final Duration? wait = _retryPolicy.delayFor(attempt: attempt);
        if (wait == null) rethrow;
        await _sleep(wait);
      } on SocketException {
        final Duration? wait = _retryPolicy.delayFor(attempt: attempt);
        if (wait == null) rethrow;
        await _sleep(wait);
      } on http.ClientException {
        final Duration? wait = _retryPolicy.delayFor(attempt: attempt);
        if (wait == null) rethrow;
        await _sleep(wait);
      }
    }
  }

  /// `Retry-After` from the most recent response, when it sent one.
  Duration? _lastRetryAfter;

  Future<NewsResponseDto> _attempt(Uri uri, int attempt) async {
    _lastRetryAfter = null;

    // The key travels in a header, never in the URL, so it cannot leak into
    // proxy access logs or crash reports that capture request URLs. Nothing in
    // this class logs the key or a secret-bearing URL.
    final http.Response response = await _client
        .get(uri, headers: <String, String>{'X-Api-Key': _apiKey})
        .timeout(_timeout);

    _lastRetryAfter = _parseRetryAfter(response.headers['retry-after']);

    final NewsResponseDto? body = _decode(response.body);

    // The result count is the single most useful thing when a live feed comes
    // back empty: it separates "the service returned nothing" from "we dropped
    // everything during mapping".
    _log(
      uri,
      'HTTP ${response.statusCode} · '
      '${body == null ? 'unreadable body' : '${body.totalResults} results, '
                '${body.articles.length} on this page'}'
      '${body?.code == null ? '' : ' · code=${body!.code}'} '
      '(attempt $attempt)',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NewsApiException(
        statusCode: response.statusCode,
        code: body?.code,
        message: body?.message,
      );
    }

    if (body == null) {
      throw const FormatException('NewsAPI returned an unreadable body');
    }

    if (body.isError) {
      throw NewsApiException(
        statusCode: response.statusCode,
        code: body.code,
        message: body.message,
      );
    }

    return body;
  }

  /// Debug-only trace of the request path and outcome.
  ///
  /// Deliberately logs the path and query keys but never the query values or
  /// any header, so an API key cannot reach a log line. Silent in release.
  void _log(Uri uri, String outcome) {
    if (!kDebugMode) return;
    final String keys = uri.queryParameters.keys.join(',');
    debugPrint('[NewsAPI] ${uri.path} [$keys] $outcome');
  }

  /// Accepts the delay-seconds form of `Retry-After`. The HTTP-date form is
  /// ignored rather than guessed at, and the backoff schedule takes over.
  static Duration? _parseRetryAfter(String? header) {
    if (header == null) return null;
    final int? seconds = int.tryParse(header.trim());
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }

  NewsResponseDto? _decode(String rawBody) {
    if (rawBody.isEmpty) return null;
    try {
      final Object? decoded = json.decode(rawBody);
      if (decoded is! Map<String, dynamic>) return null;
      return NewsResponseDto.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }
}

/// When a failed NewsAPI request is worth trying again, and how long to wait.
///
/// Only failures that a retry can plausibly fix are retried: a lost
/// connection, a timeout, a rate limit, or a server fault. A rejected key, a
/// plan limit, or a malformed request are permanent — retrying them would burn
/// quota and delay the error the reader needs to see.
@immutable
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(seconds: 8),
  });

  /// Never retry. Used by tests that assert single-shot behaviour.
  static const RetryPolicy none = RetryPolicy(maxAttempts: 1);

  final int maxAttempts;
  final Duration baseDelay;

  /// Ceiling for a single wait, so a large `Retry-After` cannot strand the UI.
  final Duration maxDelay;

  /// Status codes worth another attempt.
  static const Set<int> retryableStatusCodes = <int>{429, 500, 502, 503, 504};

  /// How long to wait before attempt `attempt + 1`, or `null` to give up.
  ///
  /// [statusCode] is `null` for a transport failure, which is always
  /// retryable. [retryAfter] wins over the computed backoff when the service
  /// asked for a specific delay.
  Duration? delayFor({
    required int attempt,
    int? statusCode,
    Duration? retryAfter,
  }) {
    if (attempt >= maxAttempts) return null;
    if (statusCode != null && !retryableStatusCodes.contains(statusCode)) {
      return null;
    }

    if (retryAfter != null) {
      return retryAfter > maxDelay ? maxDelay : retryAfter;
    }

    // Exponential backoff, capped.
    final int millis = baseDelay.inMilliseconds * pow(2, attempt - 1).toInt();
    final Duration delay = Duration(milliseconds: millis);
    return delay > maxDelay ? maxDelay : delay;
  }
}
