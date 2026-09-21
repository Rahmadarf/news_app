import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news_app/models/news_response.dart';
import 'package:news_app/utils/constants.dart';

/// Technical failure raised by [NewsApiService] for a non-200 response.
///
/// Deliberately distinct from [http.ClientException], which means the transport
/// itself failed. Part 4 maps both onto typed application failures.
class NewsApiException implements Exception {
  const NewsApiException({required this.statusCode});

  final int statusCode;

  @override
  String toString() => 'NewsApiException(statusCode: $statusCode)';
}

/// Contract shared by every news data source.
///
/// Part 4 replaces this with a repository + data-source pair returning domain
/// entities. It exists now only so that mock and live sources are selectable at
/// startup and so [NewsController] can be constructed without a network.
abstract interface class NewsService {
  Future<NewsResponse> getTopHeadlines({
    String country,
    String? category,
    int page,
    int pageSize,
  });

  Future<NewsResponse> searchNews({
    required String query,
    int page,
    int pageSize,
    String? sortBy,
  });
}

/// Talks to the real NewsAPI.
class NewsApiService implements NewsService {
  NewsApiService(this._apiKey, {http.Client? client})
    : _client = client ?? http.Client();

  static const String _baseUrl = Constants.baseUrl;

  final String _apiKey;
  final http.Client _client;

  @override
  Future<NewsResponse> getTopHeadlines({
    String country = Constants.defaultCountry,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, String> queryParams = {
      'country': country,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    return _get(Constants.topHeadlines, queryParams);
  }

  @override
  Future<NewsResponse> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
  }) async {
    final Map<String, String> queryParams = {
      'q': query,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }

    return _get(Constants.everything, queryParams);
  }

  Future<NewsResponse> _get(
    String path,
    Map<String, String> queryParams,
  ) async {
    // The key travels in a header, never in the URL, so it cannot leak through
    // proxy access logs or crash reports that capture request URLs.
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: {'X-Api-Key': _apiKey});

    if (response.statusCode != 200) {
      // Part 4 replaces this with a typed failure hierarchy. Until then the
      // status code is at least preserved instead of being wrapped twice.
      throw NewsApiException(statusCode: response.statusCode);
    }

    return NewsResponse.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }
}
