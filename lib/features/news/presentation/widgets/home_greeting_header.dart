import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Avatar, time-of-day greeting, and the notifications action.
///
/// The reader identity is local and anonymous; there is no account service.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key, required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  /// Morning before 11, afternoon before 18, evening after.
  static String greetingFor(AppLocalizations l10n, DateTime now) {
    if (now.hour < 11) return l10n.greetingMorning;
    if (now.hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final String reader = l10n.greetingReader;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter,
        Spacing.sm,
        Spacing.sm,
        Spacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: Dimens.avatar,
            height: Dimens.avatar,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.tintedSurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              reader.characters.first.toUpperCase(),
              style: text.titleSmall?.copyWith(color: tokens.accent),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  greetingFor(l10n, clock.now()),
                  style: text.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reader,
                  style: text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotificationsTap,
            tooltip: l10n.notificationsLabel,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}
