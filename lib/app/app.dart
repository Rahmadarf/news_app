import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/app/routing/app_router.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

/// The application shell. Holds the router for the lifetime of the app.
class NewsApp extends ConsumerStatefulWidget {
  const NewsApp({super.key});

  @override
  ConsumerState<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends ConsumerState<NewsApp> {
  late final GoRouter _router = createRouter();

  @override
  void initState() {
    super.initState();
    // Relative timestamps ("28 menit lalu") need the Indonesian messages
    // registered before the first frame renders one.
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(appLocaleProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: _resolveLocale,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Indonesian is the product default; English is used only when the device
  /// asks for it explicitly.
  static Locale _resolveLocale(
    List<Locale>? deviceLocales,
    Iterable<Locale> supported,
  ) {
    for (final Locale locale in deviceLocales ?? const <Locale>[]) {
      for (final Locale candidate in supported) {
        if (candidate.languageCode == locale.languageCode) return candidate;
      }
    }
    return const Locale('id');
  }
}

/// Shown instead of the app when the compile-time configuration is unusable.
///
/// Copy here is developer-facing on purpose and deliberately unlocalized; this
/// screen is unreachable in a correctly configured build.
class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key, required this.error});

  final ConfigurationError error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Builder(
        builder: (BuildContext context) {
          final NewslineTokens tokens = NewslineTokens.of(context);
          final TextTheme text = Theme.of(context).textTheme;

          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.settings_suggest_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: Spacing.lg),
                      Text('Configuration error', style: text.headlineMedium),
                      const SizedBox(height: Spacing.md),
                      Text(error.summary, style: text.bodySmall),
                      const SizedBox(height: Spacing.md),
                      Text(
                        error.remedy,
                        style: text.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
