import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/finance_dashboard.dart';
import '../repositories/finance_repository.dart';

class GetFinanceDashboard extends UseCase<FinanceDashboard, NoParams> {
  const GetFinanceDashboard(this._repository);

  final FinanceRepository _repository;

  @override
  Future<Either<Failure, FinanceDashboard>> call(NoParams params) {
    return _repository.getDashboard();
  }
}
