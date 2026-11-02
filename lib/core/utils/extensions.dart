import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isWide => MediaQuery.sizeOf(this).width >= Breakpoints.expanded;

  /// Closes the keyboard.
  void unfocus() => FocusScope.of(this).unfocus();
}

extension StringX on String {
  /// Up to two initials, e.g. "Ada Lovelace" -> "AL".
  String get initials {
    final parts = trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get capitalized => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

extension DateTimeX on DateTime {
  /// Locale-independent short date, e.g. "12 Mar 2026".
  String get formatted {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '$day ${months[month - 1]} $year';
  }
}
