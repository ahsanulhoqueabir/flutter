import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/feedback/status_view.dart';
import '../utils/logger.dart';

/// Routes every uncaught error to [AppLogger]; connect crash reporting there.
void setupErrorHandling() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error('Flutter error', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught error', error, stack);
    return true;
  };

  // Release builds would otherwise show a blank grey box when a widget throws.
  if (!kDebugMode) {
    ErrorWidget.builder = (_) => const Material(child: StatusView.error());
  }
}
