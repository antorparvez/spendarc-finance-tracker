/// Lightweight [Either] without external packages.
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L get left => switch (this) {
        Left(value: final l) => l,
        Right() => throw StateError('Either is Right, not Left'),
      };

  R get right => switch (this) {
        Right(value: final r) => r,
        Left() => throw StateError('Either is Left, not Right'),
      };

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return switch (this) {
      Left(value: final l) => onLeft(l),
      Right(value: final r) => onRight(r),
    };
  }
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;
}
