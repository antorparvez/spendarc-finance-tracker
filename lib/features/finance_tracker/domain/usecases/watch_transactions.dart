import '../entities/transaction.dart';
import '../repositories/finance_repository.dart';

/// Streams local transaction updates (offline-first).
class WatchTransactions {
  const WatchTransactions(this._repository);

  final FinanceRepository _repository;

  Stream<List<Transaction>> call() => _repository.watchTransactions();
}
