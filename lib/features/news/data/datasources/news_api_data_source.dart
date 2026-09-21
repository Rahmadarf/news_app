import 'dart:convert';

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
class NewsApiDataSource implements NewsRemoteDataSource {
  NewsApiDataSource({
    required String apiKey,
    required http.Client client,
    Duration timeout = defaultTimeout,
  }) : _apiKey = apiKey,
       _client = client,
       _timeout = timeout;

  static const String baseUrl = 'https://newsapi.org/v2';
  static const String topHeadlinesPath = '/top-headlines';
  static const String everythingPath = '/everything';
  static const Duration defaultTimeout = Duration(seconds: 15);

  final String _apiKey;
  final http.Client _client;
  final Duration _timeout;

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
  }) {
    return _get(everythingPath, <String, String>{
      'q': query,
      'page': '$page',
      'pageSize': '$pageSize',
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

    // The key travels in a header, never in the URL, so it cannot leak into
    // proxy access logs or crash reports that capture request URLs. Nothing in
    // this class logs the key or a secret-bearing URL.
    final http.Response response = await _client
        .get(uri, headers: <String, String>{'X-Api-Key': _apiKey})
        .timeout(_timeout);

    final NewsResponseDto? body = _decode(response.body);

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
