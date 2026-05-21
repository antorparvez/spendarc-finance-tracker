import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:riverpod_boilerplate/config/environment.dart';
import 'package:riverpod_boilerplate/config/flavor_config.dart';
import 'package:riverpod_boilerplate/core/storage/local_storage_service.dart';
import 'package:riverpod_boilerplate/core/storage/secure_storage_service.dart';
import 'package:riverpod_boilerplate/core/usecases/usecase.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/get_finance_dashboard.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/finance_tracker_di.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/widgets/balance_card.dart';
import 'package:riverpod_boilerplate/shared/di/app_dependencies.dart';
import 'package:riverpod_boilerplate/shared/di/service_locator.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    await disposeServiceLocator();
  });

  testWidgets('seeded finance repository exposes balance for UI', (tester) async {
    FlavorConfig.initialize(Environment.dev);

    final localStorage = await LocalStorageService.create();
    final dependencies = AppDependencies.create(
      localStorage: localStorage,
      secureStorage: SecureStorageService(),
    );
    setupServiceLocator(dependencies);

    final bundle = getIt<FinanceBundle>();
    final result = await GetFinanceDashboard(bundle.repository)(const NoParams());
    expect(result.isRight, isTrue);
    final dashboard = result.right;

    await tester.pumpWidget(
      MaterialApp(
        home: BalanceCard(
          balance: dashboard.balance,
          income: dashboard.totalIncome,
          expense: dashboard.totalExpense,
        ),
      ),
    );

    expect(find.textContaining('\$'), findsWidgets);
    bundle.dispose();
  });
}
