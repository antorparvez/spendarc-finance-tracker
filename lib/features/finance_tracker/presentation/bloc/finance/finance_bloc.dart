import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/finance_dashboard.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/delete_transaction.dart';
import '../../../domain/usecases/get_finance_dashboard.dart';
import '../../../domain/usecases/watch_transactions.dart';
import '../sync/sync_bloc.dart';
import '../sync/sync_event.dart';
import '../sync/sync_state.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc({
    required GetFinanceDashboard getDashboard,
    required AddTransaction addTransaction,
    required DeleteTransaction deleteTransaction,
    required WatchTransactions watchTransactions,
    required SyncBloc syncBloc,
  })  : _getDashboard = getDashboard,
        _addTransaction = addTransaction,
        _deleteTransaction = deleteTransaction,
        _watchTransactions = watchTransactions,
        _syncBloc = syncBloc,
        super(const FinanceState()) {
    on<FinanceStarted>(_onStarted);
    on<FinanceRefreshRequested>(_onRefresh);
    on<FinanceTransactionsUpdated>(_onTransactionsUpdated);
    on<FinanceSyncStateChanged>(_onSyncStateChanged);
    on<FinanceAddRequested>(_onAdd);
    on<FinanceDeleteRequested>(_onDelete);
    on<FinanceParticleBurstCleared>(_onClearBurst);
  }

  final GetFinanceDashboard _getDashboard;
  final AddTransaction _addTransaction;
  final DeleteTransaction _deleteTransaction;
  final WatchTransactions _watchTransactions;
  final SyncBloc _syncBloc;

  StreamSubscription<List<Transaction>>? _txSub;
  StreamSubscription<SyncState>? _syncBlocSub;
  int _lastSyncTick = 0;

  Future<void> _onStarted(FinanceStarted event, Emitter<FinanceState> emit) async {
    await _txSub?.cancel();
    await _syncBlocSub?.cancel();

    _txSub = _watchTransactions().listen(
      (tx) => add(FinanceTransactionsUpdated(tx)),
    );

    _syncBlocSub = _syncBloc.stream.listen((syncState) {
      add(
        FinanceSyncStateChanged(
          isSyncing: syncState.isSyncing,
          completedTick: syncState.completedTick,
        ),
      );
    });

    _syncBloc.add(SyncStarted());
    add(FinanceRefreshRequested());
  }

  Future<void> _onRefresh(
    FinanceRefreshRequested event,
    Emitter<FinanceState> emit,
  ) async {
    if (!event.silent) {
      emit(state.copyWith(isLoading: true, clearFailure: true));
    }
    final result = await _getDashboard(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (dashboard) => emit(
        state.copyWith(
          isLoading: false,
          dashboard: dashboard,
          clearFailure: true,
        ),
      ),
    );
  }

  void _onTransactionsUpdated(
    FinanceTransactionsUpdated event,
    Emitter<FinanceState> emit,
  ) {
    final current = state.dashboard;
    if (current == null) return;
    emit(
      state.copyWith(
        dashboard: current.copyWith(transactions: event.transactions),
      ),
    );
  }

  void _onSyncStateChanged(
    FinanceSyncStateChanged event,
    Emitter<FinanceState> emit,
  ) {
    emit(state.copyWith(isSyncing: event.isSyncing));
    if (event.completedTick > _lastSyncTick) {
      _lastSyncTick = event.completedTick;
      add(FinanceRefreshRequested(silent: true));
    }
  }

  Future<void> _onAdd(
    FinanceAddRequested event,
    Emitter<FinanceState> emit,
  ) async {
    final previous = state.dashboard;
    if (previous == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final optimistic = Transaction(
      id: 'optimistic-$now',
      title: event.title.trim(),
      amount: event.amount.abs(),
      type: event.type,
      category: event.category,
      createdAtMs: now,
      updatedAtMs: now,
      syncVersion: 0,
      isPending: true,
    );

    final optimisticList = [optimistic, ...previous.transactions];
    emit(
      state.copyWith(
        dashboard: _rebuildDashboard(previous, optimisticList),
        showParticleBurst: true,
        clearFailure: true,
        clearRollback: true,
      ),
    );

    final result = await _addTransaction(
      AddTransactionParams(
        title: event.title,
        amount: event.amount,
        type: event.type,
        category: event.category,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          dashboard: previous,
          failure: failure,
          showParticleBurst: false,
          rollbackMessage: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(showParticleBurst: false, clearRollback: true));
        add(FinanceRefreshRequested(silent: true));
      },
    );
  }

  Future<void> _onDelete(
    FinanceDeleteRequested event,
    Emitter<FinanceState> emit,
  ) async {
    final previous = state.dashboard;
    if (previous == null) return;

    final filtered =
        previous.transactions.where((t) => t.id != event.id).toList();
    emit(
      state.copyWith(
        dashboard: _rebuildDashboard(previous, filtered),
        clearFailure: true,
      ),
    );

    final result = await _deleteTransaction(DeleteTransactionParams(event.id));
    result.fold(
      (failure) => emit(state.copyWith(dashboard: previous, failure: failure)),
      (_) => add(FinanceRefreshRequested(silent: true)),
    );
  }

  void _onClearBurst(
    FinanceParticleBurstCleared event,
    Emitter<FinanceState> emit,
  ) {
    if (state.showParticleBurst) {
      emit(state.copyWith(showParticleBurst: false));
    }
  }

  FinanceDashboard _rebuildDashboard(
    FinanceDashboard base,
    List<Transaction> transactions,
  ) {
    double income = 0;
    double expense = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    final progress = base.monthlyBudget <= 0
        ? 0.0
        : (expense / base.monthlyBudget).clamp(0.0, 1.0);

    return base.copyWith(
      balance: income - expense,
      totalIncome: income,
      totalExpense: expense,
      spendingProgress: progress,
      transactions: transactions,
    );
  }

  @override
  Future<void> close() {
    _txSub?.cancel();
    _syncBlocSub?.cancel();
    return super.close();
  }
}
