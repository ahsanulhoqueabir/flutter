import 'package:flutter/material.dart';

/// Central theme. Change [_seed] to rebrand; read colors via
/// `Theme.of(context).colorScheme` instead of hard-coding them in widgets.
abstract final class AppTheme {
  static const _seed = Colors.indigo;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
