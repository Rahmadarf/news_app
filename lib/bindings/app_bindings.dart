import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/services/news_service.dart';

class AppBindings implements Bindings {
  const AppBindings({required this.newsService});

  final NewsService newsService;

  @override
  void dependencies() {
    // Still a permanent singleton. Feature-scoped ownership is Part 3 work;
    // see docs/AUDIT.md H-2.
    Get.put<NewsController>(NewsController(newsService), permanent: true);
  }
}
