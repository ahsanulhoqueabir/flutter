import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Minimal app logger. Swap the body for a crash-reporting SDK later
/// without touching call sites. Never use `print` in app code.
abstract final class AppLogger {
  static void debug(String message) {
    if (kDebugMode) developer.log(message, name: 'app');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'app', level: 1000, error: error, stackTrace: stackTrace);
  }
}
