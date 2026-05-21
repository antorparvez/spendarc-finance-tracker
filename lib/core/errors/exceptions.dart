class AppException implements Exception {
  AppException(this.message, {this.code, this.errors});

  final String message;
  final int? code;
  final dynamic errors;

  @override
  String toString() =>
      'AppException(code: $code, message: $message, errors: $errors)';
}

class NetworkException extends AppException {
  NetworkException([super.message = 'No internet connection'])
    : super(code: -1);
}

class TimeoutException extends AppException {
  TimeoutException([super.message = 'Request timeout']) : super(code: -2);
}

class ServerException extends AppException {
  ServerException({required String message, int? code, dynamic errors})
    : super(message, code: code, errors: errors);
}

class UnknownException extends AppException {
  UnknownException([super.message = 'Unexpected error']) : super(code: -999);
}
