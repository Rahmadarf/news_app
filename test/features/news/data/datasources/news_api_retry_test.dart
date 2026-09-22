import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:news_app/features/news/data/datasources/news_api_data_source.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';

/// Success envelope with no articles.
String okBody() => json.encode(<String, dynamic>{
  'status': 'ok',
  'totalResults': 0,
  'articles': <dynamic>[],
});

String errorBody(String code) => json.encode(<String, dynamic>{
  'status': 'error',
  'code': code,
  'message': 'nope',
});

void main() {
  /// Records every wait the data source asks for, without actually waiting, so
  /// backoff is asserted without any real delay.
  late List<Duration> waits;

  setUp(() => waits = <Duration>[]);

  NewsApiDataSource sourceFor(
    List<http.Response> responses, {
    RetryPolicy policy = const RetryPolicy(),
  }) {
    int index = 0;
    return NewsApiDataSource(
      apiKey: 'test-key',
      client: MockClient((http.Request request) async {
        final http.Response response =
            responses[index < responses.length ? index : responses.length - 1];
        index++;
        return response;
      }),
      retryPolicy: policy,
      sleep: (Duration duration) async => waits.add(duration),
    );
  }

  Future<NewsResponseDto> headlines(NewsApiDataSource source) {
    return source.fetchTopHeadlines(
      country: 'id',
      category: 'general',
      page: 1,
      pageSize: 20,
    );
  }

  group('retrying', () {
    test('retries a 429 and succeeds on a later attempt', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response(errorBody('rateLimited'), 429),
        http.Response(okBody(), 200),
      ]);

      final NewsResponseDto result = await headlines(source);

      expect(result.status, 'ok');
      expect(waits, hasLength(1));
    });

    test('retries a 503 and succeeds on a later attempt', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response('', 503),
        http.Response(okBody(), 200),
      ]);

      await headlines(source);

      expect(waits, hasLength(1));
    });

    test('gives up after the configured number of attempts', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response(errorBody('rateLimited'), 429),
      ]);

      await expectLater(
        headlines(source),
        throwsA(
          isA<NewsApiException>().having(
            (NewsApiException e) => e.statusCode,
            'statusCode',
            429,
          ),
        ),
      );

      // Three attempts means two waits between them.
      expect(waits, hasLength(2));
    });

    test('backs off exponentially', () async {
      final NewsApiDataSource source = sourceFor(
        <http.Response>[http.Response('', 500)],
        policy: const RetryPolicy(
          maxAttempts: 4,
          baseDelay: Duration(milliseconds: 100),
        ),
      );

      await expectLater(headlines(source), throwsA(isA<NewsApiException>()));

      expect(waits, <Duration>[
        const Duration(milliseconds: 100),
        const Duration(milliseconds: 200),
        const Duration(milliseconds: 400),
      ]);
    });

    test('honours Retry-After over the computed backoff', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response(
          errorBody('rateLimited'),
          429,
          headers: <String, String>{'retry-after': '5'},
        ),
        http.Response(okBody(), 200),
      ]);

      await headlines(source);

      expect(waits, <Duration>[const Duration(seconds: 5)]);
    });

    test('clamps an excessive Retry-After', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response(
          errorBody('rateLimited'),
          429,
          headers: <String, String>{'retry-after': '3600'},
        ),
        http.Response(okBody(), 200),
      ], policy: const RetryPolicy(maxDelay: Duration(seconds: 8)));

      await headlines(source);

      expect(waits, <Duration>[const Duration(seconds: 8)]);
    });

    test(
      'ignores an HTTP-date Retry-After and falls back to backoff',
      () async {
        final NewsApiDataSource source = sourceFor(<http.Response>[
          http.Response(
            errorBody('rateLimited'),
            429,
            headers: <String, String>{
              'retry-after': 'Wed, 21 Oct 2026 07:28:00 GMT',
            },
          ),
          http.Response(okBody(), 200),
        ]);

        await headlines(source);

        expect(waits, <Duration>[const Duration(milliseconds: 400)]);
      },
    );
  });

  group('not retrying', () {
    test('a rejected key fails immediately', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response(errorBody('apiKeyInvalid'), 401),
      ]);

      await expectLater(headlines(source), throwsA(isA<NewsApiException>()));

      expect(waits, isEmpty, reason: 'retrying a bad key only burns quota');
    });

    test('a plan limit fails immediately', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response(errorBody('maximumResultsReached'), 426),
      ]);

      await expectLater(headlines(source), throwsA(isA<NewsApiException>()));

      expect(waits, isEmpty);
    });

    test('a malformed request fails immediately', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response(errorBody('parametersMissing'), 400),
      ]);

      await expectLater(headlines(source), throwsA(isA<NewsApiException>()));

      expect(waits, isEmpty);
    });

    test('the policy can be disabled entirely', () async {
      final NewsApiDataSource source = sourceFor(<http.Response>[
        http.Response('', 503),
      ], policy: RetryPolicy.none);

      await expectLater(headlines(source), throwsA(isA<NewsApiException>()));

      expect(waits, isEmpty);
    });
  });

  group('transport failures', () {
    test('a dropped connection is retried', () async {
      int calls = 0;
      final NewsApiDataSource source = NewsApiDataSource(
        apiKey: 'test-key',
        client: MockClient((http.Request request) async {
          calls++;
          if (calls == 1) throw http.ClientException('connection closed');
          return http.Response(okBody(), 200);
        }),
        sleep: (Duration duration) async => waits.add(duration),
      );

      await headlines(source);

      expect(calls, 2);
      expect(waits, hasLength(1));
    });

    test('a persistent transport failure eventually surfaces', () async {
      final NewsApiDataSource source = NewsApiDataSource(
        apiKey: 'test-key',
        client: MockClient(
          (http.Request request) async =>
              throw http.ClientException('connection closed'),
        ),
        sleep: (Duration duration) async => waits.add(duration),
      );

      await expectLater(
        headlines(source),
        throwsA(isA<http.ClientException>()),
      );
      expect(waits, hasLength(2));
    });
  });

  group('RetryPolicy', () {
    test('stops once the attempt budget is spent', () {
      const RetryPolicy policy = RetryPolicy(maxAttempts: 2);

      expect(policy.delayFor(attempt: 1, statusCode: 429), isNotNull);
      expect(policy.delayFor(attempt: 2, statusCode: 429), isNull);
    });

    test('treats a transport failure as retryable', () {
      const RetryPolicy policy = RetryPolicy();

      expect(policy.delayFor(attempt: 1), isNotNull);
    });
  });
}
