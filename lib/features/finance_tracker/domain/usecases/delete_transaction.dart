import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/finance_repository.dart';

class DeleteTransactionParams {
  const DeleteTransactionParams(this.id);

  final String id;
}

class DeleteTransaction extends UseCase<Unit, DeleteTransactionParams> {
  const DeleteTransaction(this._repository);

  final FinanceRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteTransactionParams params) {
    return _repository.deleteTransaction(params.id);
  }
}
