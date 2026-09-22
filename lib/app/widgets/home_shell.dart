import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Bottom navigation shell: Home / Discover / Bookmark / Settings.
///
/// Each tab keeps its own navigation stack and scroll position, which is what
/// preserves the back-navigation origin required by the handoff. The article
/// screen is pushed above the shell, so it hides the bar.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.hairline)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            // initialLocation: re-tapping the current tab pops it back to its
            // root instead of doing nothing.
            onDestinationSelected: (int index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.homeTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore),
                label: l10n.discoverTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.bookmark_border),
                selectedIcon: const Icon(Icons.bookmark),
                label: l10n.bookmarkTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.settingsTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder for a tab that this design stage has not built yet.
///
/// Deliberately says so rather than imitating a finished screen.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: StatusView(
            icon: Icons.construction_outlined,
            title: l10n.comingSoonTitle,
            message: l10n.comingSoonBody,
          ),
        ),
      ),
    );
  }
}
