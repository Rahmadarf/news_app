import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:news_app/features/news/data/datasources/news_api_data_source.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';

/// Uses MockClient from package:http/testing.dart, so no socket is ever opened.
void main() {
  NewsApiDataSource sourceReturning(
    http.Response Function(http.Request request) handler, {
    Duration timeout = NewsApiDataSource.defaultTimeout,
  }) {
    return NewsApiDataSource(
      apiKey: 'test-key',
      client: MockClient((http.Request request) async => handler(request)),
      timeout: timeout,
    );
  }

  test('sends the key as a header and never in the URL', () async {
    late Uri capturedUri;
    late Map<String, String> capturedHeaders;

    final NewsApiDataSource source = sourceReturning((http.Request request) {
      capturedUri = request.url;
      capturedHeaders = request.headers;
      return http.Response(
        json.encode(<String, dynamic>{
          'status': 'ok',
          'totalResults': 0,
          'articles': <dynamic>[],
        }),
        200,
      );
    });

    await source.fetchTopHeadlines(
      country: 'us',
      category: 'general',
      page: 1,
      pageSize: 20,
    );

    expect(capturedHeaders['X-Api-Key'], 'test-key');
    expect(capturedUri.toString(), isNot(contains('test-key')));
    expect(capturedUri.queryParameters['category'], 'general');
  });

  test('percent-encodes the search query', () async {
    late Uri capturedUri;

    final NewsApiDataSource source = sourceReturning((http.Request request) {
      capturedUri = request.url;
      return http.Response(
        json.encode(<String, dynamic>{
          'status': 'ok',
          'totalResults': 0,
          'articles': <dynamic>[],
        }),
        200,
      );
    });

    await source.searchEverything(
      query: 'flutter & dart',
      page: 1,
      pageSize: 20,
    );

    expect(capturedUri.queryParameters['q'], 'flutter & dart');
    expect(capturedUri.query, contains('flutter+%26+dart'));
  });

  test('throws NewsApiException carrying the status and error code', () async {
    final NewsApiDataSource source = sourceReturning(
      (http.Request request) => http.Response(
        json.encode(<String, dynamic>{
          'status': 'error',
          'code': 'apiKeyInvalid',
          'message': 'Your API key is invalid.',
        }),
        401,
      ),
    );

    await expectLater(
      source.fetchTopHeadlines(
        country: 'us',
        category: 'general',
        page: 1,
        pageSize: 20,
      ),
      throwsA(
        isA<NewsApiException>()
            .having((NewsApiException e) => e.statusCode, 'statusCode', 401)
            .having((NewsApiException e) => e.code, 'code', 'apiKeyInvalid'),
      ),
    );
  });

  test('throws on a 200 response carrying an error envelope', () async {
    final NewsApiDataSource source = sourceReturning(
      (http.Request request) => http.Response(
        json.encode(<String, dynamic>{
          'status': 'error',
          'code': 'rateLimited',
          'message': 'Too many requests.',
        }),
        200,
      ),
    );

    await expectLater(
      source.searchEverything(query: 'flutter', page: 1, pageSize: 20),
      throwsA(
        isA<NewsApiException>().having(
          (NewsApiException e) => e.code,
          'code',
          'rateLimited',
        ),
      ),
    );
  });

  test('throws FormatException on an unreadable body', () async {
    final NewsApiDataSource source = sourceReturning(
      (http.Request request) => http.Response('<html>nope</html>', 200),
    );

    await expectLater(
      source.searchEverything(query: 'flutter', page: 1, pageSize: 20),
      throwsA(isA<FormatException>()),
    );
  });

  test('times out when the client never responds', () {
    fakeAsync((FakeAsync async) {
      final NewsApiDataSource source = NewsApiDataSource(
        apiKey: 'test-key',
        client: MockClient(
          (http.Request request) => Completer<http.Response>().future,
        ),
        timeout: const Duration(seconds: 5),
      );

      Object? caught;
      unawaited(
        source
            .fetchTopHeadlines(
              country: 'us',
              category: 'general',
              page: 1,
              pageSize: 20,
            )
            .then<void>(
              (NewsResponseDto _) {},
              onError: (Object error) {
                caught = error;
              },
            ),
      );

      // Virtual time: no wall-clock delay is incurred.
      async.elapse(const Duration(seconds: 6));

      expect(caught, isA<TimeoutException>());
    });
  });
}
