class Constants {
  static const String baseUrl = 'https://newsapi.org/v2';

  // Endpoints
  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  // Categories
  static const List<String> categories = [
    'general',
    'technology',
    'business',
    'sports',
    'health',
    'science',
    'entertainment',
  ];

  // Countries
  static const String defaultCountry = 'us';

  // App info
  static const String appName = 'News App';
}
