import 'package:flutter/widgets.dart';

/// Spacing scale (multiples of 4). Use these instead of magic numbers.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal padding for screen content.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}

/// Layout breakpoints (Material 3 window size classes).
abstract final class Breakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  /// Max width for forms and reading content on wide screens.
  static const double formMaxWidth = 440;
  static const double contentMaxWidth = 720;
}

/// Vertical/horizontal gap. `Gap(AppSpacing.md)` reads better than a bare SizedBox.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
