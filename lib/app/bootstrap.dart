import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/core/persistence/database_connection.dart';
import 'package:news_app/core/persistence/settings_store.dart';

/// Outcome of application start-up.
///
/// Configuration is validated and storage is opened before any widget is
/// built, so a misconfigured build shows an actionable screen instead of
/// failing mid-render.
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
/// not in a controller.
Future<BootstrapResult> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig config;
  try {
    config = AppConfig.fromEnvironment();
  } on ConfigurationError catch (error) {
    return BootstrapFailure(error);
  }

  final AppDatabase database = AppDatabase(openAppDatabaseFile());
  final SettingsStore settings = await SettingsStore.open();

  return BootstrapSuccess(<Override>[
    appConfigProvider.overrideWithValue(config),
    appDatabaseProvider.overrideWithValue(database),
    settingsStoreProvider.overrideWithValue(settings),
  ]);
}
