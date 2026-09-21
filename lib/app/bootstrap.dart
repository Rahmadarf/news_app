import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/config/app_config.dart';

/// Outcome of application start-up.
///
/// Configuration is validated before any widget is built, so a misconfigured
/// build shows an actionable screen instead of failing mid-render.
@immutable
sealed class BootstrapResult {
  const BootstrapResult();
}

/// Start-up succeeded. [overrides] seed the root [ProviderScope].
final class BootstrapSuccess extends BootstrapResult {
  const BootstrapSuccess(this.overrides);

  final List<Override> overrides;
}

/// Start-up failed because the compile-time configuration is unusable.
final class BootstrapFailure extends BootstrapResult {
  const BootstrapFailure(this.error);

  final ConfigurationError error;
}

/// The single place where the application is initialized and its dependency
/// graph is constructed.
///
/// Everything expensive or asynchronous belongs here — not in a widget, and
/// not in a controller. Local persistence is opened here once it lands, which
/// is why this returns a `Future` even though it currently has no await.
Future<BootstrapResult> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final AppConfig config = AppConfig.fromEnvironment();
    return BootstrapSuccess(<Override>[
      appConfigProvider.overrideWithValue(config),
    ]);
  } on ConfigurationError catch (error) {
    return BootstrapFailure(error);
  }
}
