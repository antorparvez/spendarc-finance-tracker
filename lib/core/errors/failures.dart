abstract class Failure {
  const Failure(this.message, {this.code});

  final String message;
  final int? code;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection'])
    : super(code: -1);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout']) : super(code: -2);
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, int? code})
    : super(message, code: code);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error'])
    : super(code: -999);
}
