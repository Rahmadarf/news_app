import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/routing/app_router.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/theme/app_theme.dart';

/// The application shell. Holds the router for the lifetime of the app.
class NewsApp extends StatefulWidget {
  const NewsApp({super.key});

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'News App',
      theme: AppTheme.light,
      routerConfig: _router,
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
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
