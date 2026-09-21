import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/config/app_config.dart';

void main() {
  group('AppConfig.from', () {
    test('defaults to mock mode and carries no key', () {
      final AppConfig config = AppConfig.from(rawMode: 'mock', rawApiKey: '');

      expect(config.dataSourceMode, NewsDataSourceMode.mock);
      expect(config.usesLiveApi, isFalse);
      expect(config.newsApiKey, isEmpty);
    });

    test('drops a stray key when running in mock mode', () {
      final AppConfig config = AppConfig.from(
        rawMode: 'mock',
        rawApiKey: 'leftover-key',
      );

      expect(config.newsApiKey, isEmpty);
    });

    test('accepts live mode with a key', () {
      final AppConfig config = AppConfig.from(
        rawMode: 'live',
        rawApiKey: '  abc123  ',
      );

      expect(config.dataSourceMode, NewsDataSourceMode.live);
      expect(config.usesLiveApi, isTrue);
      expect(config.newsApiKey, 'abc123');
    });

    test('rejects live mode without a key', () {
      expect(
        () => AppConfig.from(rawMode: 'live', rawApiKey: ''),
        throwsA(
          isA<ConfigurationError>().having(
            (ConfigurationError e) => e.summary,
            'summary',
            contains('NEWS_API_KEY'),
          ),
        ),
      );
    });

    test('rejects live mode when the key is only whitespace', () {
      expect(
        () => AppConfig.from(rawMode: 'live', rawApiKey: '   '),
        throwsA(isA<ConfigurationError>()),
      );
    });

    test('rejects an unknown data-source mode', () {
      expect(
        () => AppConfig.from(rawMode: 'staging', rawApiKey: 'abc123'),
        throwsA(
          isA<ConfigurationError>().having(
            (ConfigurationError e) => e.summary,
            'summary',
            contains('staging'),
          ),
        ),
      );
    });
  });
}
