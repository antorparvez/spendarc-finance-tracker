import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/finance_repository.dart';

class SyncFinanceQueue extends UseCase<Unit, NoParams> {
  const SyncFinanceQueue(this._repository);

  final FinanceRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.syncPending();
  }
}
