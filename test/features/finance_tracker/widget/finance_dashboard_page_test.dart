import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:riverpod_boilerplate/core/localization/supported_locales.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_bloc.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/sync/sync_bloc.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_event.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/pages/finance_dashboard_page.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/add_transaction.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/delete_transaction.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/get_finance_dashboard.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/sync_finance_queue.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/watch_sync_events.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/watch_transactions.dart';

import '../mocks/mock_finance_repository.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Finance dashboard shows balance card', (tester) async {
    final repo = MockFinanceRepository();
    final syncBloc = SyncBloc(
      watchSyncEvents: WatchSyncEvents(repo),
      syncFinanceQueue: SyncFinanceQueue(repo),
    );
    final financeBloc = FinanceBloc(
      getDashboard: GetFinanceDashboard(repo),
      addTransaction: AddTransaction(repo),
      deleteTransaction: DeleteTransaction(repo),
      watchTransactions: WatchTransactions(repo),
      syncBloc: syncBloc,
    );

    financeBloc.add(FinanceRefreshRequested());

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: SupportedLocales.values,
        path: 'l10n',
        fallbackLocale: SupportedLocales.fallback,
        startLocale: SupportedLocales.fallback,
        child: MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: syncBloc),
              BlocProvider.value(value: financeBloc),
            ],
            child: const FinanceDashboardPage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('\$100.00'), findsWidgets);
    expect(find.textContaining('\$200.00'), findsOneWidget);
    await financeBloc.close();
    await syncBloc.close();
  });
}
