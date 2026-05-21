import '../errors/failures.dart';
import '../utils/either.dart';

/// Base contract for domain use cases returning [Either].
abstract class UseCase<TResult, Params> {
  const UseCase();

  Future<Either<Failure, TResult>> call(Params params);
}

/// Use when a use case takes no parameters.
class NoParams {
  const NoParams();
}
