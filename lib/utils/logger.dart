import 'package:flutter/foundation.dart';

/// Logger utility for conditional logging
/// Logs only in debug mode, silent in production
class Logger {
  /// Log a message (only in debug mode)
  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Log an info message with emoji
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ $message');
    }
  }

  /// Log a success message with emoji
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ $message');
    }
  }

  /// Log a warning message with emoji
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ $message');
    }
  }

  /// Log an error message with emoji
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Log a debug message (verbose)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('🔍 $message');
    }
  }
}
