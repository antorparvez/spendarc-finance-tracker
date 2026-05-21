import 'package:dio/dio.dart';

import '../../logging/app_log.dart';

typedef ConnectivityChecker = Future<bool> Function();

class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor({required this.isConnected});

  final ConnectivityChecker isConnected;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!await isConnected()) {
      AppLog.netWarn('offline — ${options.method} ${options.uri}');
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );
      return;
    }
    handler.next(options);
  }
}
