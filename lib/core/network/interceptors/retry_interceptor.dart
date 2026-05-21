import 'dart:io';

import 'package:dio/dio.dart';

import '../../logging/app_log.dart';
import '../api_map_utils.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, this.maxRetries = 2});

  final Dio dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.extra[DioExtras.disableRetry] == true) {
      handler.next(err);
      return;
    }

    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    var retryCount = (err.requestOptions.extra[DioExtras.retryCount] as int?) ?? 0;
    var lastError = err;

    while (retryCount < maxRetries && _shouldRetry(lastError)) {
      final attempt = retryCount + 1;
      final delay = Duration(milliseconds: 300 * attempt);
      lastError.requestOptions.extra[DioExtras.retryCount] = attempt;
      lastError.requestOptions.extra[DioExtras.skipErrorLog] = true;

      AppLog.netWarn(
        '[${_id(lastError.requestOptions)}] retry $attempt after ${delay.inMilliseconds}ms',
      );

      await Future.delayed(delay);

      final requestOptions = lastError.requestOptions;
      final previousDisable = requestOptions.extra[DioExtras.disableRetry];
      requestOptions.extra[DioExtras.disableRetry] = true;
      try {
        final response = await dio.fetch<dynamic>(requestOptions);
        response.requestOptions.extra[DioExtras.skipErrorLog] = false;
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        lastError = e;
        retryCount = attempt;
      } finally {
        if (previousDisable == null) {
          requestOptions.extra.remove(DioExtras.disableRetry);
        } else {
          requestOptions.extra[DioExtras.disableRetry] = previousDisable;
        }
      }
    }

    lastError.requestOptions.extra[DioExtras.skipErrorLog] = false;
    handler.next(lastError);
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.data is FormData) return false;
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.error is SocketException;
  }

  String _id(RequestOptions options) {
    final value = options.extra[DioExtras.requestId];
    return value is String ? value : 'REQ-?';
  }
}
