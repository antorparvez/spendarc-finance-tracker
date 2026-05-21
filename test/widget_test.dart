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
import 'package:riverpod_boilerplate/features/home/presentation/screens/home_screen.dart';
import 'package:riverpod_boilerplate/shared/di/app_dependencies.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('shows flavor configuration', (WidgetTester tester) async {
    FlavorConfig.initialize(Environment.dev);

    final localStorage = await LocalStorageService.create();
    final dependencies = AppDependencies.create(
      localStorage: localStorage,
      secureStorage: SecureStorageService(),
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: SupportedLocales.values,
        path: 'l10n',
        fallbackLocale: SupportedLocales.fallback,
        startLocale: SupportedLocales.fallback,
        child: AppScope.wrapForTest(
          dependencies: dependencies,
          child: const MaterialApp(home: HomeScreen(enableAutoLoad: false)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BLoC Boilerplate Dev'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
