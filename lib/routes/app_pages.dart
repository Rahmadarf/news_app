import 'package:get/get.dart';
import 'package:news_app/views/home_view.dart';
import 'package:news_app/views/news_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.HOME;

  static final routes = [
    GetPage(name: _Paths.HOME, page: () => const HomeView()),
    GetPage(name: _Paths.NEWS_DETAIL, page: () => NewsDetailView()),
  ];
}
