import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Share, copy, and open actions for an article.
///
/// All of them use the article's real canonical URL. Nothing here fabricates a
/// link or claims to have published anything.
abstract final class ArticleActions {
  /// Native share sheet with the headline and the real article URL.
  static Future<void> share(Article article) {
    return SharePlus.instance.share(
      ShareParams(
        text: '${article.title}\n\n${article.url}',
        subject: article.title,
      ),
    );
  }

  static Future<void> copyLink(BuildContext context, String url) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    await Clipboard.setData(ClipboardData(text: url));

    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
  }

  /// Opens [rawUrl] in an in-app browser view, falling back to the external
  /// browser, and finally reporting failure.
  ///
  /// `inAppBrowserView` is a platform view — Custom Tabs on Android, Safari
  /// View Controller on iOS — so no WebView dependency is needed. Desktop and
  /// web have no such view, which is exactly what the fallback covers.
  static Future<void> openInBrowser(BuildContext context, String rawUrl) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final Uri? uri = Uri.tryParse(rawUrl);
    if (uri != null && await _tryLaunch(uri)) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.couldNotOpenLink)));
  }

  static Future<bool> _tryLaunch(Uri uri) async {
    for (final LaunchMode mode in <LaunchMode>[
      LaunchMode.inAppBrowserView,
      LaunchMode.externalApplication,
    ]) {
      try {
        if (await launchUrl(uri, mode: mode)) return true;
      } on PlatformException {
        // This platform has no such view; try the next mode.
        continue;
      }
    }
    return false;
  }
}
