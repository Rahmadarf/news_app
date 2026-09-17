part of 'app_pages.dart';

abstract class Routes {
  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const NEWS_DETAIL = _Paths.NEWS_DETAIL;
}

abstract class _Paths {
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const NEWS_DETAIL = '/news-detail';
}
