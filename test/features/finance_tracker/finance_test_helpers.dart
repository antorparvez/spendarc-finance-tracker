import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/add_transaction.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/delete_transaction.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/get_finance_dashboard.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/sync_finance_queue.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/watch_sync_events.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/watch_transactions.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_bloc.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_event.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/sync/sync_bloc.dart';

import 'mocks/mock_finance_repository.dart';

class FinanceTestHarness {
  FinanceTestHarness({
    required this.financeBloc,
    required this.syncBloc,
    required this.repository,
  });

  final FinanceBloc financeBloc;
  final SyncBloc syncBloc;
  final MockFinanceRepository repository;

  static FinanceTestHarness create({bool failOnAdd = false}) {
    final repo = MockFinanceRepository(failOnAdd: failOnAdd);
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
    return FinanceTestHarness(
      financeBloc: financeBloc,
      syncBloc: syncBloc,
      repository: repo,
    );
  }

  Future<void> loadDashboard() async {
    financeBloc.add(FinanceRefreshRequested());
    await financeBloc.stream.firstWhere(
      (s) => s.dashboard != null && !s.isLoading,
    );
  }

  Future<void> dispose() async {
    await financeBloc.close();
    await syncBloc.close();
  }
}
