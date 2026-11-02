import 'dart:async';

import 'package:flutter/foundation.dart';

/// Delays [run] until calls stop for [duration]. Use for search-as-you-type.
/// Call [dispose] from the owning widget's `dispose`.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 350)});

  final Duration duration;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() => _timer?.cancel();
}
