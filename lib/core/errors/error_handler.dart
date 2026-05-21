import 'dart:convert';

import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  ErrorHandler._();

  static Failure mapToFailure(Object error) {
    if (error is Failure) {
      return error;
    }

    if (error is String) {
      final text = error.trim();
      return UnknownFailure(text.isNotEmpty ? text : 'Something went wrong');
    }

    if (error is DioException) {
      return _mapDioToFailure(error);
    }

    if (error is AppException) {
      return _mapAppExceptionToFailure(error);
    }

    return const UnknownFailure('Something went wrong');
  }

  static Failure _mapDioToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure('Request timeout');
      case DioExceptionType.badResponse:
        return ServerFailure(
          message: _messageFromBadResponse(e),
          code: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const UnknownFailure('Request cancelled');
      case DioExceptionType.unknown:
        return UnknownFailure(
          e.message?.isNotEmpty == true ? e.message! : 'Unexpected error',
        );
      case DioExceptionType.badCertificate:
        return const UnknownFailure('Bad certificate');
    }
  }

  static String _messageFromBadResponse(DioException e) {
    final fromBody = _parseApiErrorBody(e.response?.data);
    if (fromBody != null && fromBody.isNotEmpty) {
      return fromBody;
    }
    return _fallbackMessageForHttpCode(e.response?.statusCode);
  }

  static String? _parseApiErrorBody(dynamic data) {
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return null;
      try {
        final decoded = jsonDecode(trimmed);
        return _parseApiErrorBody(decoded);
      } catch (_) {
        return trimmed.length <= 280 ? trimmed : null;
      }
    }

    if (data is List) {
      final lines = <String>[];
      for (final item in data) {
        final parsed = _parseApiErrorBody(item);
        if (parsed != null && parsed.trim().isNotEmpty) {
          lines.add(parsed.trim());
        }
      }
      if (lines.isNotEmpty) {
        return lines.join('\n');
      }
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final base = _firstNonEmptyString([
        map['message'],
        map['detail'],
        map['title'],
        map['error_description'],
        map['errorMessage'],
      ]);

      final rawErrors = map['errors'] ?? map['error'];
      if (rawErrors is Map && rawErrors.isNotEmpty) {
        final nestedMessage = rawErrors['message'];
        final nestedBase = _firstNonEmptyString([
          nestedMessage,
          rawErrors['detail'],
          rawErrors['title'],
        ]);
        final detail = _formatValidationErrors(
          Map<String, dynamic>.from(rawErrors),
        );
        if (detail.isNotEmpty) {
          if (base != null) return '$base\n\n$detail';
          if (nestedBase != null) return '$nestedBase\n\n$detail';
          return detail;
        }
        if (base == null && nestedBase != null) return nestedBase;
      }

      final nestedData = map['data'];
      if (nestedData != null) {
        final nestedDataMessage = _parseApiErrorBody(nestedData);
        if (nestedDataMessage != null && nestedDataMessage.isNotEmpty) {
          if (base != null) return '$base\n\n$nestedDataMessage';
          return nestedDataMessage;
        }
      }

      if (base != null) return base;
    }

    return null;
  }

  static String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static String _formatValidationErrors(Map<String, dynamic> errors) {
    final lines = <String>[];
    for (final entry in errors.entries) {
      final v = entry.value;
      if (v is String && v.isNotEmpty) {
        lines.add('• $v');
      } else if (v is List) {
        for (final item in v) {
          if (item == null) continue;
          final parsed = _parseApiErrorBody(item);
          if (parsed != null && parsed.isNotEmpty) {
            lines.add('• $parsed');
            continue;
          }
          if ('$item'.isNotEmpty) {
            lines.add('• $item');
          }
        }
      } else if (v is Map) {
        final parsed = _parseApiErrorBody(v);
        if (parsed != null && parsed.isNotEmpty) {
          lines.add('• $parsed');
        }
      } else if (v != null) {
        lines.add('• ${entry.key}: $v');
      }
    }
    return lines.join('\n');
  }

  static String _fallbackMessageForHttpCode(int? code) {
    if (code == null) return 'Something went wrong';
    if (code >= 500) return 'Server error. Please try again later.';
    switch (code) {
      case 400:
        return 'Invalid request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation failed';
      default:
        return 'Something went wrong';
    }
  }

  static Failure _mapAppExceptionToFailure(AppException e) {
    if (e is NetworkException) {
      return NetworkFailure(
        e.message.isNotEmpty ? e.message : 'No internet connection',
      );
    }
    if (e is TimeoutException) {
      return TimeoutFailure(
        e.message.isNotEmpty ? e.message : 'Request timeout',
      );
    }
    if (e is ServerException) {
      return ServerFailure(
        message: e.message.isNotEmpty ? e.message : 'Something went wrong',
        code: e.code,
      );
    }
    return UnknownFailure(
      e.message.isNotEmpty ? e.message : 'Unexpected error',
    );
  }
}
