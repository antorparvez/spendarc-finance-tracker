import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../config/environment.dart';
import '../config/flavor_config.dart';
import '../core/localization/locale_cubit.dart';
import '../core/localization/supported_locales.dart';
import '../core/logging/app_log.dart';
import '../core/logging/log_config.dart';
import '../core/storage/local_storage_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/storage/migration/storage_migration.dart';
import '../core/storage/migration/storage_migrations_registry.dart';
import '../core/system/system_ui_config.dart';
import '../core/theme/theme_cubit.dart';
import '../shared/di/app_dependencies.dart';
import 'app.dart';
import 'app_scope.dart';

Future<void> bootstrap(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(environment);

  final config = FlavorConfig.config;
  final isProd = environment == Environment.prod;

  AppLog.initialize(
    LogConfig(
      enabled: kDebugMode,
      environment: config.environment,
      appName: config.appName,
      logNetworkBodies: true,
      redactSensitiveFields: isProd,
      maxBodyLength: isProd ? 4000 : 0,
    ),
  );

  EasyLocalization.logger
    ..enableBuildModes = []
    ..enableLevels = []
    ..printer = (_, {name, stackTrace, level}) {};

  SystemUiConfig.apply(
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );

  await EasyLocalization.ensureInitialized();

  final localStorage = await LocalStorageService.create();
  final secureStorage = SecureStorageService();

  await StorageMigrationRunner(
    local: localStorage,
    secure: secureStorage,
    migrations: kStorageMigrations,
  ).run();

  final dependencies = AppDependencies.create(
    localStorage: localStorage,
    secureStorage: secureStorage,
  );

  if (AppLog.isEnabled) {
    AppLog.core(
      'bootstrap · ${config.environment} · ${config.baseUrl} · '
      'locale ${LocaleCubit.readStored(localStorage).languageCode} · '
      'theme ${ThemeModeCubit.readStored(localStorage).name}',
    );
  }

  runApp(
    AppScope.wrap(
      dependencies: dependencies,
      child: EasyLocalization(
        supportedLocales: SupportedLocales.values,
        path: 'l10n',
        fallbackLocale: SupportedLocales.fallback,
        child: const App(),
      ),
    ),
  );
}
