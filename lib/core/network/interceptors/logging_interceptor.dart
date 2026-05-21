import 'dart:convert';

import 'package:dio/dio.dart';

import '../../logging/app_log.dart';
import '../api_map_utils.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  static int _sequence = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra.putIfAbsent(DioExtras.requestId, _nextId);
    options.extra.putIfAbsent(
      DioExtras.startTimeMs,
      () => DateTime.now().millisecondsSinceEpoch,
    );
    options.extra.putIfAbsent(DioExtras.skipErrorLog, () => false);

    final retry = (options.extra[DioExtras.retryCount] as int?) ?? 0;
    if (retry == 0 && AppLog.isEnabled) {
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (AppLog.isEnabled) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppLog.isEnabled && err.requestOptions.extra[DioExtras.skipErrorLog] != true) {
      _logError(err);
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final id = _id(options);
    AppLog.net('→ [$id] ${options.method} ${options.uri}');

    final headers = _sanitizeMap(options.headers);
    final token = headers['Authorization'] ?? headers['authorization'];
    headers.remove('Authorization');
    headers.remove('authorization');

    if (headers.isNotEmpty) {
      AppLog.net('  headers ${_encode(headers)}');
    }

    if (options.queryParameters.isNotEmpty) {
      AppLog.net('  query ${_encode(options.queryParameters)}');
    }

    if (token != null) {
      AppLog.net('  token $token');
    }

    if (AppLog.config.logNetworkBodies && !_isEmpty(options.data)) {
      AppLog.netDump('  body', _encode(_sanitize(options.data)));
    }
  }

  void _logResponse(Response<dynamic> response) {
    final id = _id(response.requestOptions);
    final ms = _elapsedMs(response.requestOptions);
    final status = response.statusCode ?? 0;
    final req = response.requestOptions;

    AppLog.net('← [$id] $status ${ms}ms ${req.method} ${req.uri}');

    if (AppLog.config.logNetworkBodies && !_isEmpty(response.data)) {
      AppLog.netDump('  response', _encode(_sanitize(response.data)));
    }
  }

  void _logError(DioException err) {
    final id = _id(err.requestOptions);
    final ms = _elapsedMs(err.requestOptions);
    final status = err.response?.statusCode;
    final detail = _apiMessage(err.response?.data) ?? _shortMessage(err.message);
    final req = err.requestOptions;

    AppLog.netError(
      '← [$id] ${err.type.name}'
      '${status != null ? ' $status' : ''} ${ms}ms ${req.method} ${req.uri} — $detail',
    );

    if (AppLog.config.logNetworkBodies) {
      if (!_isEmpty(err.requestOptions.data)) {
        AppLog.netDump('body', _encode(_sanitize(err.requestOptions.data)));
      }
      if (!_isEmpty(err.response?.data)) {
        AppLog.netDump(
          'error response',
          _encode(_sanitize(err.response?.data)),
        );
      }
    }
  }

  String _nextId() {
    _sequence = (_sequence + 1) % 100000;
    return 'REQ-${_sequence.toString().padLeft(5, '0')}';
  }

  String _id(RequestOptions options) {
    final value = options.extra[DioExtras.requestId];
    return value is String ? value : 'REQ-?';
  }

  int _elapsedMs(RequestOptions options) {
    final start = options.extra[DioExtras.startTimeMs];
    if (start is int) {
      return DateTime.now().millisecondsSinceEpoch - start;
    }
    return 0;
  }

  String _encode(dynamic value) {
    if (value == null) return '';
    try {
      return const JsonEncoder().convert(value);
    } catch (_) {
      return '$value';
    }
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    return {
      for (final e in map.entries)
        e.key: _shouldRedact(e.key) ? '***' : _sanitize(e.value, key: e.key),
    };
  }

  dynamic _sanitize(dynamic value, {String? key}) {
    if (value == null) return null;
    if (value is Map) {
      return {
        for (final e in value.entries)
          '${e.key}': _shouldRedact('${e.key}')
              ? '***'
              : _sanitize(e.value, key: '${e.key}'),
      };
    }
    if (value is List) {
      return value.map((e) => _sanitize(e)).toList();
    }
    if (key != null && _shouldRedact(key)) return '***';
    return value;
  }

  bool _shouldRedact(String key) {
    if (!AppLog.config.redactSensitiveFields) return false;
    const keys = {
      'authorization',
      'token',
      'access_token',
      'password',
      'cookie',
    };
    return keys.contains(key.toLowerCase());
  }

  bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Map) return value.isEmpty;
    if (value is List) return value.isEmpty;
    return false;
  }

  String _shortMessage(String? message) {
    if (message == null || message.trim().isEmpty) return 'Unknown error';
    return message.trim().split('\n').first;
  }

  String? _apiMessage(dynamic data) {
    if (data is Map) {
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    return null;
  }
}
