import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/finance_dashboard.dart';
import '../entities/finance_sync_event.dart';
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';

abstract class FinanceRepository {
  Stream<List<Transaction>> watchTransactions();

  Stream<FinanceSyncEvent> watchSyncEvents();

  Future<Either<Failure, FinanceDashboard>> getDashboard();

  Future<Either<Failure, Transaction>> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
  });

  Future<Either<Failure, Unit>> deleteTransaction(String id);

  Future<Either<Failure, Unit>> syncPending();
}

/// Sentinel for void success in [Either].
class Unit {
  const Unit();
}
