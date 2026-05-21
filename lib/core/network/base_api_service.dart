import 'package:dio/dio.dart';

import '../errors/error_handler.dart';
import '../errors/exceptions.dart';
import 'dio_client.dart';

class BaseApiService {
  BaseApiService(this._client, {this.onUnauthorized});

  final DioClient _client;
  final Future<void> Function()? onUnauthorized;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(() {
      return _client.dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(() {
      return _client.dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(() {
      return _client.dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(() {
      return _client.dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(() {
      return _client.dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() action) async {
    try {
      final response = await action();
      await _handleUnauthorizedEnvelopeIfNeeded(response.data);
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final failure = ErrorHandler.mapToFailure(e);
        throw ServerException(
          message: failure.message,
          code: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<void> _handleUnauthorizedEnvelopeIfNeeded(dynamic data) async {
    if (data is! Map<String, dynamic>) return;
    final isSuccess = data['success'] ?? data['status'];
    final failed = isSuccess is bool && !isSuccess;
    if (!failed) return;

    final rawCode = data['statusCode'] ?? data['code'];
    final code = rawCode is int ? rawCode : int.tryParse('${rawCode ?? ''}');
    final message = '${data['message'] ?? ''}'.trim().toLowerCase();
    final isUnauthorized = code == 401 || message == 'unauthorized';
    if (!isUnauthorized) return;

    if (onUnauthorized != null) {
      try {
        await onUnauthorized!();
      } catch (_) {
        // Do not mask original unauthorized failure.
      }
    }

    throw ServerException(
      message: data['message']?.toString() ?? 'Unauthorized',
      code: 401,
    );
  }
}
