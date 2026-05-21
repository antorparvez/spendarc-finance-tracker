import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_boilerplate/core/errors/failures.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/entities/transaction_type.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/add_transaction.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/delete_transaction.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/get_finance_dashboard.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/sync_finance_queue.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/watch_sync_events.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/watch_transactions.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_bloc.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_event.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/sync/sync_bloc.dart';

import '../mocks/mock_finance_repository.dart';

void main() {
  FinanceBloc buildBloc({bool failOnAdd = false}) {
    final repo = MockFinanceRepository(failOnAdd: failOnAdd);
    final syncBloc = SyncBloc(
      watchSyncEvents: WatchSyncEvents(repo),
      syncFinanceQueue: SyncFinanceQueue(repo),
    );
    return FinanceBloc(
      getDashboard: GetFinanceDashboard(repo),
      addTransaction: AddTransaction(repo),
      deleteTransaction: DeleteTransaction(repo),
      watchTransactions: WatchTransactions(repo),
      syncBloc: syncBloc,
    );
  }

  test('refresh emits dashboard', () async {
    final bloc = buildBloc();
    bloc.add(FinanceRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(bloc.state.dashboard, isNotNull);
    expect(bloc.state.isLoading, isFalse);
    await bloc.close();
  });

  test('optimistic add rolls back on repository failure', () async {
    final bloc = buildBloc(failOnAdd: true);
    bloc.add(FinanceRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final previousCount = bloc.state.dashboard!.transactions.length;
    bloc.add(
      FinanceAddRequested(
        title: 'Fail',
        amount: 9,
        type: TransactionType.expense,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.dashboard!.transactions.length, previousCount);
    expect(bloc.state.failure, isA<ServerFailure>());
    await bloc.close();
  });
}
