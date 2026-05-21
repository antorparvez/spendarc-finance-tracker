import 'package:riverpod_boilerplate/core/errors/failures.dart';
import 'package:riverpod_boilerplate/core/utils/either.dart';
import 'dart:async';

import 'package:riverpod_boilerplate/features/finance_tracker/domain/entities/finance_dashboard.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/entities/finance_sync_event.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/entities/transaction.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/entities/transaction_type.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/repositories/finance_repository.dart';

class MockFinanceRepository implements FinanceRepository {
  MockFinanceRepository({
    this.failOnAdd = false,
    List<Transaction>? seed,
  }) : _transactions = seed ?? [];

  final bool failOnAdd;
  final List<Transaction> _transactions;

  int get transactionCount => _transactions.length;

  @override
  Stream<List<Transaction>> watchTransactions() async* {
    yield _transactions;
  }

  @override
  Stream<FinanceSyncEvent> watchSyncEvents() => const Stream.empty();

  @override
  Future<Either<Failure, FinanceDashboard>> getDashboard() async {
    return Right(
      FinanceDashboard(
        balance: 100,
        totalIncome: 200,
        totalExpense: 100,
        spendingProgress: 0.2,
        weeklyTrend: const [10, 20, 15, 30, 12, 18, 22],
        transactions: List.unmodifiable(_transactions),
        monthlyBudget: 5000,
      ),
    );
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
  }) async {
    if (failOnAdd) {
      return const Left(ServerFailure(message: 'sync failed'));
    }
    final tx = Transaction(
      id: 'mock-${_transactions.length}',
      title: title,
      amount: amount,
      type: type,
      category: category,
      createdAtMs: 1,
      updatedAtMs: 1,
      syncVersion: 1,
    );
    _transactions.insert(0, tx);
    return Right(tx);
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    return const Right(Unit());
  }

  @override
  Future<Either<Failure, Unit>> syncPending() async => const Right(Unit());
}
