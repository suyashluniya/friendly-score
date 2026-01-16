import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static const String _appName = 'FriendlyScore';
  // Automatically disable debug logs in release builds
  static bool _enableDebug = kDebugMode;

  static void setDebugMode(bool enabled) {
    _enableDebug = enabled;
  }

  static void debug(String message, {String? tag}) {
    if (_enableDebug) {
      _log(LogLevel.debug, message, tag: tag);
    }
  }

  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final prefix = _getPrefix(level);
    final tagStr = tag != null ? '[$tag] ' : '';
    final logMessage = '$prefix $tagStr$message';

    // Use developer.log for better Flutter DevTools integration
    developer.log(
      logMessage,
      name: _appName,
      time: DateTime.now(),
      level: _getLogLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return '✅';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  static int _getLogLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
