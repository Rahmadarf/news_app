import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/core/widgets/confirm_dialog.dart';
import 'package:news_app/features/news/domain/entities/news_country.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Reader preferences.
///
/// Every control here changes real behaviour: the theme, the reading text
/// size, which edition the feed requests, and which language the app renders.
/// Nothing is stored for show.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTab)),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          children: <Widget>[
            _SectionLabel(label: l10n.settingsAppearance),
            const _ThemeModeTile(),
            const _TextSizeTile(),

            _SectionLabel(label: l10n.settingsContent),
            const _CountryTile(),
            const _LanguageTile(),

            _SectionLabel(label: l10n.settingsLibrary),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: Text(l10n.savedArticles),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppRoutes.bookmarksPath),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(l10n.readingHistoryTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.historyPath),
            ),

            _SectionLabel(label: l10n.settingsStorage),
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: Text(l10n.clearCacheTitle),
              subtitle: Text(l10n.clearCacheSubtitle),
              onTap: () => _clearCache(context, ref),
            ),

            _SectionLabel(label: l10n.settingsAbout),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.openSourceLicenses),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: l10n.appName,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.gutter),
              child: Text(
                l10n.aboutNewsline,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NewsRepository repository = ref.read(newsRepositoryProvider);

    final bool confirmed = await confirmAction(
      context,
      title: l10n.clearCacheTitle,
      // Says plainly what survives, because a reader cannot be expected to
      // know which store this clears.
      message: l10n.clearCacheConfirmBody,
      confirmLabel: l10n.clearAction,
    );
    if (!confirmed) return;

    try {
      await repository.clearCache();
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.clearCacheDone)));
    } on Object {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.errorCacheTitle)));
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final NewslineTokens tokens = NewslineTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter,
        Spacing.xl,
        Spacing.gutter,
        Spacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: tokens.textSecondary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeMode mode = ref.watch(themeModeProvider);

    String labelFor(ThemeMode mode) => switch (mode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };

    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: Text(l10n.themeTitle),
      subtitle: Text(labelFor(mode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPicker(
        context,
        title: l10n.themeTitle,
        options: ThemeMode.values,
        labelFor: labelFor,
        selected: mode,
        onSelected: ref.read(themeModeProvider.notifier).set,
      ),
    );
  }
}

class _CountryTile extends ConsumerWidget {
  const _CountryTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewsCountry country = ref.watch(selectedCountryProvider);

    return ListTile(
      leading: const Icon(Icons.public),
      title: Text(l10n.editionTitle),
      subtitle: Text(country.label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPicker<NewsCountry>(
        context,
        title: l10n.editionTitle,
        options: NewsCountry.values,
        labelFor: (NewsCountry c) => c.label,
        selected: country,
        onSelected: ref.read(selectedCountryProvider.notifier).select,
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale? locale = ref.watch(appLocaleProvider);

    String labelFor(Locale? locale) => switch (locale?.languageCode) {
      'id' => 'Bahasa Indonesia',
      'en' => 'English',
      _ => l10n.languageSystem,
    };

    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(l10n.languageTitle),
      subtitle: Text(labelFor(locale)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPicker<Locale?>(
        context,
        title: l10n.languageTitle,
        options: <Locale?>[null, ...AppLocaleController.supported],
        labelFor: labelFor,
        selected: locale,
        onSelected: ref.read(appLocaleProvider.notifier).select,
      ),
    );
  }
}

class _TextSizeTile extends ConsumerWidget {
  const _TextSizeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double scale = ref.watch(readingTextScaleProvider);
    final ReadingTextScaleController controller = ref.read(
      readingTextScaleProvider.notifier,
    );

    return ListTile(
      leading: const Icon(Icons.format_size),
      title: Text(l10n.readingTextSizeTitle),
      subtitle: Text(l10n.readingTextSizeSubtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: controller.canDecrease ? controller.decrease : null,
            tooltip: l10n.decreaseTextSize,
            icon: const Icon(Icons.text_decrease),
          ),
          Text(
            '${(scale * 100).round()}%',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          IconButton(
            onPressed: controller.canIncrease ? controller.increase : null,
            tooltip: l10n.increaseTextSize,
            icon: const Icon(Icons.text_increase),
          ),
        ],
      ),
    );
  }
}

/// Single-choice bottom sheet shared by every picker on this screen.
///
/// Plain rows with a check mark rather than radios: `RadioListTile` now wants
/// a `RadioGroup` ancestor, and a sheet that closes on selection has no use
/// for a persistent group.
Future<void> _showPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelFor,
  required T selected,
  required void Function(T) onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.gutter,
              vertical: Spacing.sm,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.headlineMedium,
              ),
            ),
          ),
          for (final T option in options)
            ListTile(
              title: Text(labelFor(option)),
              trailing: option == selected
                  ? Icon(
                      Icons.check,
                      color: NewslineTokens.of(sheetContext).accent,
                    )
                  : null,
              selected: option == selected,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onSelected(option);
              },
            ),
        ],
      ),
    ),
  );
}
