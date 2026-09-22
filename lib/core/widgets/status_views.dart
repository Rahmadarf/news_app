import 'package:flutter/material.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Turns a typed [Failure] into localized, user-facing copy.
///
/// Wording lives in presentation, not in the data layer, so repositories stay
/// free of UI strings.
({String title, String message}) describeFailure(
  AppLocalizations l10n,
  Failure failure,
) {
  return switch (failure) {
    ConfigurationFailure() => (
      title: l10n.errorConfigurationTitle,
      message: l10n.errorConfigurationBody,
    ),
    NoConnectionFailure() => (
      title: l10n.errorNoConnectionTitle,
      message: l10n.errorNoConnectionBody,
    ),
    TimeoutFailure() => (
      title: l10n.errorTimeoutTitle,
      message: l10n.errorTimeoutBody,
    ),
    UnauthorizedFailure() => (
      title: l10n.errorUnauthorizedTitle,
      message: l10n.errorUnauthorizedBody,
    ),
    RateLimitedFailure() => (
      title: l10n.errorRateLimitedTitle,
      message: l10n.errorRateLimitedBody,
    ),
    UpgradeRequiredFailure() => (
      title: l10n.errorUpgradeRequiredTitle,
      message: l10n.errorUpgradeRequiredBody,
    ),
    ServerFailure() => (
      title: l10n.errorServerTitle,
      message: l10n.errorServerBody,
    ),
    MalformedResponseFailure() => (
      title: l10n.errorMalformedTitle,
      message: l10n.errorMalformedBody,
    ),
    CacheFailure() => (
      title: l10n.errorCacheTitle,
      message: l10n.errorCacheBody,
    ),
    UnknownFailure() => (
      title: l10n.errorUnknownTitle,
      message: l10n.errorUnknownBody,
    ),
  };
}

/// Centred icon, headline, body, and a single recovery action.
///
/// Used for every empty and error condition so they stay visually identical,
/// as the prototype's shared `.state` block does.
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Error variant, with copy derived from [failure].
  factory StatusView.failure({
    Key? key,
    required AppLocalizations l10n,
    required Failure failure,
    VoidCallback? onRetry,
  }) {
    final ({String title, String message}) copy = describeFailure(
      l10n,
      failure,
    );
    return StatusView(
      key: key,
      icon: failure is NoConnectionFailure
          ? Icons.cloud_off_outlined
          : Icons.error_outline,
      title: copy.title,
      message: copy.message,
      actionLabel: onRetry == null ? null : l10n.retryAction,
      onAction: onRetry,
    );
  }

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final NewslineTokens tokens = NewslineTokens.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.gutter,
        vertical: 48,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: tokens.tintedSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: tokens.accent),
          ),
          const SizedBox(height: Spacing.xl),
          Text(title, style: text.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: Spacing.sm),
          Text(message, style: text.bodySmall, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: Spacing.xl),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Accent-tinted strip shown above stale content while offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.updatedLabel});

  /// Optional `updated <relative time>` suffix from the cached feed.
  final String? updatedLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: tokens.tintedSurface,
        borderRadius: BorderRadius.circular(Radii.thumbnail),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off_outlined, size: 16, color: tokens.accent),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              updatedLabel == null
                  ? l10n.offlineBanner
                  : '${l10n.offlineBanner} · $updatedLabel',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: tokens.accent),
            ),
          ),
        ],
      ),
    );
  }
}
