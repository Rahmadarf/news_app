/// Route paths and names, in one place.
///
/// Query parameters are part of the contract: they make every destination
/// expressible as a URL, which is what keeps deep linking possible and what
/// lets the article screen recover when no object was handed to it.
abstract final class AppRoutes {
  static const String feedName = 'feed';
  static const String feedPath = '/';

  static const String discoverName = 'discover';
  static const String discoverPath = '/discover';

  static const String bookmarksName = 'bookmarks';
  static const String bookmarksPath = '/bookmarks';

  static const String settingsName = 'settings';
  static const String settingsPath = '/settings';

  /// Carries the canonical article URL in `?url=`.
  static const String articleName = 'article';
  static const String articlePath = '/article';

  static const String queryParam = 'q';
  static const String urlParam = 'url';

  /// Discover with a pre-filled term, for deep links.
  static String discoverWithQuery(String query) => Uri(
    path: discoverPath,
    queryParameters: <String, String>{queryParam: query},
  ).toString();

  static String article(String articleUrl) => Uri(
    path: articlePath,
    queryParameters: <String, String>{urlParam: articleUrl},
  ).toString();
}
