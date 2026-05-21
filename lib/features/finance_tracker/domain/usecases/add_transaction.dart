import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';
import '../repositories/finance_repository.dart';

class AddTransactionParams {
  const AddTransactionParams({
    required this.title,
    required this.amount,
    required this.type,
    this.category = 'general',
  });

  final String title;
  final double amount;
  final TransactionType type;
  final String category;
}

class AddTransaction extends UseCase<Transaction, AddTransactionParams> {
  const AddTransaction(this._repository);

  final FinanceRepository _repository;

  @override
  Future<Either<Failure, Transaction>> call(AddTransactionParams params) {
    return _repository.addTransaction(
      title: params.title,
      amount: params.amount,
      type: params.type,
      category: params.category,
    );
  }
}
