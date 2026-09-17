import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(() => NewsController());
  }
}
