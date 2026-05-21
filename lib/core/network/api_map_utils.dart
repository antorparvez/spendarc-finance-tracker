import 'package:dio/dio.dart';

import '../../shared/models/base_response_model.dart';
import '../errors/exceptions.dart';

class ApiResponseParser {
  ApiResponseParser._();

  static T parseOrThrow<T>(
      Response<Map<String, dynamic>> response, {
        required T Function(dynamic raw) dataParser,
      }) {
    final body = coerceJsonMap(response.data);
    final parsed = BaseResponseModel<T>.fromJson(body, dataParser: dataParser);
    final code = response.statusCode ?? 0;
    final isOkCode = code >= 200 && code < 300;

    if (isOkCode && parsed.success && parsed.data != null) {
      return parsed.data as T;
    }

    final fallback = isOkCode ? 'Request failed' : 'Server error';
    throw ServerException(
      message: parsed.message.isNotEmpty ? parsed.message : fallback,
      code: response.statusCode,
      errors: parsed.errors,
    );
  }
}



/// Normalizes dynamic JSON (e.g. Dio `response.data`) to `Map<String, dynamic>`.
Map<String, dynamic> coerceJsonMap(dynamic raw) {
  if (raw == null) return {};
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return {};
}

/// Shared [RequestOptions.extra] keys for Dio interceptors.
abstract final class DioExtras {
  static const requestId = 'network_request_id';
  static const startTimeMs = 'network_start_time_ms';
  static const retryCount = 'retry_count';
  static const skipErrorLog = 'network_skip_error_log';
  static const disableRetry = 'network_disable_retry';
}
