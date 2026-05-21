import 'package:flutter/foundation.dart';

import 'log_config.dart';

/// Plain [debugPrint] logging for debug builds. No ANSI colors or env tags.
class AppLog {
  AppLog._();

  static LogConfig _config = const LogConfig(
    enabled: false,
    environment: 'unknown',
    appName: 'App',
  );

  static bool get isEnabled => _config.enabled;

  static LogConfig get config => _config;

  static void initialize(LogConfig config) {
    _config = config;
  }

  static void core(String message) => _emit(message);

  static void storage(String message) => _emit(message);

  static void net(String message) => _emit(message);

  static void netWarn(String message) => _emit(message);

  static void netError(String message) => _emit(message);

  static const int _consoleChunkSize = 800;

  /// JSON payloads — chunked so the console does not truncate with `<…>`.
  static void netDump(String label, String content) {
    if (!_config.enabled || content.isEmpty) return;

    final max = _config.maxBodyLength;
    final text = max > 0 && content.length > max
        ? '${content.substring(0, max)}… (+${content.length - max} chars)'
        : content;

    var offset = 0;
    var isFirst = true;
    while (offset < text.length) {
      final end = offset + _consoleChunkSize > text.length
          ? text.length
          : offset + _consoleChunkSize;
      final chunk = text.substring(offset, end);
      final line = isFirst ? '$label: $chunk' : chunk;
      // ignore: avoid_print
      print(line);
      isFirst = false;
      offset = end;
    }
  }

  static void _emit(String message) {
    if (!_config.enabled) return;
    debugPrint(message);
  }
}
