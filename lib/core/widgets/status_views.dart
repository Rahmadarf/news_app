import 'package:flutter/material.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/core/theme/app_colors.dart';

/// Turns a typed [Failure] into user-facing copy.
///
/// Wording lives in presentation, not in the data layer, so localization can
/// replace it later without touching repositories.
({String title, String message}) describeFailure(Failure failure) {
  return switch (failure) {
    ConfigurationFailure() => (
      title: 'App is not configured',
      message: 'This build is missing its news configuration.',
    ),
    NoConnectionFailure() => (
      title: 'No connection',
      message: 'Check your internet connection and try again.',
    ),
    TimeoutFailure() => (
      title: 'Request timed out',
      message: 'The server took too long to respond.',
    ),
    UnauthorizedFailure() => (
      title: 'Access denied',
      message: 'The news service rejected this app\'s credentials.',
    ),
    RateLimitedFailure() => (
      title: 'Too many requests',
      message: 'The news service is rate limiting us. Try again later.',
    ),
    UpgradeRequiredFailure() => (
      title: 'Not available on this plan',
      message: 'The news service does not allow this request.',
    ),
    ServerFailure() => (
      title: 'Service unavailable',
      message: 'The news service is having trouble. Try again later.',
    ),
    MalformedResponseFailure() => (
      title: 'Unexpected response',
      message: 'The news service sent something we could not read.',
    ),
    CacheFailure() => (
      title: 'Storage problem',
      message: 'Saved articles could not be read.',
    ),
    UnknownFailure() => (
      title: 'Something went wrong',
      message: 'Please try again.',
    ),
  };
}

/// Full-screen failure state with a retry affordance.
class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ({String title, String message}) copy = describeFailure(failure);

    return _CenteredMessage(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      title: copy.title,
      message: copy.message,
      action: onRetry == null
          ? null
          : ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
    );
  }
}

/// Full-screen empty state.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.newspaper,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      icon: icon,
      iconColor: AppColors.textHint,
      title: title,
      message: message,
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
