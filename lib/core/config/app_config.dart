/// Compile-time application configuration.
///
/// Values are supplied with `--dart-define` and read through
/// [String.fromEnvironment], so no secret file is ever bundled as a Flutter
/// asset.
///
/// SECURITY NOTE — read this before treating [newsApiKey] as a secret.
///
/// `--dart-define` keeps the key out of version control. It does **not** make
/// the key secret on the device: the value is embedded as a plain string inside
/// the compiled binary and can be recovered from any distributed APK/IPA/bundle.
/// The only real protection for a NewsAPI key is a backend proxy that holds the
/// key server-side and that the app calls instead of newsapi.org. That proxy is
/// out of scope for the current work and is tracked as a backlog item.
library;

/// Which news data source the application talks to.
enum NewsDataSourceMode {
  /// Local fixtures. Requires no API key and consumes no NewsAPI quota.
  mock,

  /// Real NewsAPI over HTTPS. Requires a valid API key.
  live;

  static NewsDataSourceMode? tryParse(String value) {
    for (final NewsDataSourceMode mode in NewsDataSourceMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }
}

/// Raised when the compile-time configuration cannot produce a usable
/// [AppConfig]. Carries a developer-facing explanation, not final UI copy.
class ConfigurationError implements Exception {
  const ConfigurationError({required this.summary, required this.remedy});

  /// What is wrong.
  final String summary;

  /// The concrete command or change that fixes it.
  final String remedy;

  @override
  String toString() => 'ConfigurationError: $summary\n$remedy';
}

/// Resolved, validated application configuration.
class AppConfig {
  const AppConfig({required this.dataSourceMode, required this.newsApiKey});

  /// `--dart-define` key selecting the data source. Defaults to
  /// [NewsDataSourceMode.mock] so a fresh clone runs without any key.
  static const String dataSourceModeKey = 'NEWS_DATA_SOURCE';

  /// `--dart-define` key carrying the NewsAPI key. Only required in
  /// [NewsDataSourceMode.live].
  static const String newsApiKeyKey = 'NEWS_API_KEY';

  static const String _rawDataSourceMode = String.fromEnvironment(
    dataSourceModeKey,
    defaultValue: 'mock',
  );

  static const String _rawNewsApiKey = String.fromEnvironment(newsApiKeyKey);

  final NewsDataSourceMode dataSourceMode;

  /// Always empty in [NewsDataSourceMode.mock].
  final String newsApiKey;

  bool get usesLiveApi => dataSourceMode == NewsDataSourceMode.live;

  /// Reads and validates the compile-time configuration.
  ///
  /// Throws [ConfigurationError] instead of silently falling back to an empty
  /// key, so a misconfigured live build fails with an actionable message rather
  /// than an opaque HTTP 401 at runtime.
  factory AppConfig.fromEnvironment() =>
      AppConfig.from(rawMode: _rawDataSourceMode, rawApiKey: _rawNewsApiKey);

  /// Testable seam for [AppConfig.fromEnvironment].
  factory AppConfig.from({required String rawMode, required String rawApiKey}) {
    final String mode = rawMode.trim();
    final String apiKey = rawApiKey.trim();

    final NewsDataSourceMode? parsedMode = NewsDataSourceMode.tryParse(mode);
    if (parsedMode == null) {
      final String allowed = NewsDataSourceMode.values
          .map((NewsDataSourceMode m) => m.name)
          .join(', ');
      throw ConfigurationError(
        summary:
            'Unknown $dataSourceModeKey value "$mode". Allowed values: $allowed.',
        remedy:
            'Run with --dart-define=$dataSourceModeKey=mock, or omit the flag '
            'entirely to use the mock default.',
      );
    }

    if (parsedMode == NewsDataSourceMode.live && apiKey.isEmpty) {
      throw const ConfigurationError(
        summary:
            '$dataSourceModeKey=live requires a non-empty $newsApiKeyKey, but '
            'none was provided at compile time.',
        remedy:
            'Run with --dart-define=$dataSourceModeKey=live '
            '--dart-define=$newsApiKeyKey=<your-key>, or drop both flags to run '
            'against mock data.',
      );
    }

    return AppConfig(
      dataSourceMode: parsedMode,
      // The key is meaningless outside live mode; do not carry it around.
      newsApiKey: parsedMode == NewsDataSourceMode.live ? apiKey : '',
    );
  }
}
