import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/bindings/app_bindings.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final AppConfig config = AppConfig.fromEnvironment();
    runApp(MyApp(newsService: createNewsService(config)));
  } on ConfigurationError catch (error) {
    // A misconfigured build must say so, not crash before the first frame and
    // not silently degrade into HTTP 401s.
    runApp(ConfigurationErrorApp(error: error));
  }
}

/// Picks the data source for [config]. Selection happens once, at startup.
NewsService createNewsService(AppConfig config) {
  return switch (config.dataSourceMode) {
    NewsDataSourceMode.mock => const MockNewsService(),
    NewsDataSourceMode.live => NewsApiService(config.newsApiKey),
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.newsService});

  final NewsService newsService;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: AppBindings(newsService: newsService),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Shown instead of the app when the compile-time configuration is unusable.
///
/// Copy here is developer-facing on purpose; this screen is unreachable in a
/// correctly configured build.
class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key, required this.error});

  final ConfigurationError error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.settings_suggest_outlined,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuration error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error.summary,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  error.remedy,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
