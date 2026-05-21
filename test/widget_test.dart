import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:riverpod_boilerplate/app/app_scope.dart';
import 'package:riverpod_boilerplate/config/environment.dart';
import 'package:riverpod_boilerplate/config/flavor_config.dart';
import 'package:riverpod_boilerplate/core/localization/supported_locales.dart';
import 'package:riverpod_boilerplate/core/storage/local_storage_service.dart';
import 'package:riverpod_boilerplate/core/storage/secure_storage_service.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/finance_tracker_di.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_event.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_bloc.dart';
import 'package:riverpod_boilerplate/features/home/presentation/screens/home_screen.dart';
import 'package:riverpod_boilerplate/shared/di/app_dependencies.dart';
import 'package:riverpod_boilerplate/shared/di/service_locator.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() async {
    await disposeServiceLocator();
  });

  testWidgets('home shows finance balance', (WidgetTester tester) async {
    FlavorConfig.initialize(Environment.dev);

    final localStorage = await LocalStorageService.create();
    final dependencies = AppDependencies.create(
      localStorage: localStorage,
      secureStorage: SecureStorageService(),
    );
    setupServiceLocator(dependencies);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: SupportedLocales.values,
        path: 'l10n',
        fallbackLocale: SupportedLocales.fallback,
        startLocale: SupportedLocales.fallback,
        child: AppScope.wrap(
          dependencies: dependencies,
          child: const MaterialApp(home: HomeScreen()),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.textContaining('\$'),
      findsWidgets,
      reason: 'Seeded finance dashboard should show currency',
    );
  });
}
