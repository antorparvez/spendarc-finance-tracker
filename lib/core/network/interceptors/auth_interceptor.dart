import 'package:dio/dio.dart';

typedef TokenProvider = Future<String?> Function();
typedef SessionExpiredHandler = Future<void> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenProvider,
    this.onSessionExpired,
  });

  final TokenProvider tokenProvider;
  final SessionExpiredHandler? onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final authHeader = err.requestOptions.headers['Authorization'];
      final hadBearer = authHeader != null && '$authHeader'.trim().isNotEmpty;
      if (hadBearer && onSessionExpired != null) {
        try {
          await onSessionExpired!();
        } catch (_) {
          // Avoid breaking the error chain if cleanup fails.
        }
      }
    }
    handler.next(err);
  }
}
