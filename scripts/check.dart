// ignore_for_file: avoid_print

/// Runs every quality gate: format check, analyze, test.
///
/// Usage: `dart run scripts/check.dart`
library;

import 'dart:io';

Future<void> main() async {
  final steps = [
    ['dart', 'format', '--output=none', '--set-exit-if-changed', 'lib', 'test', 'scripts'],
    ['flutter', 'analyze'],
    ['flutter', 'test'],
  ];

  for (final step in steps) {
    print('\n> ${step.join(' ')}');
    final process = await Process.start(
      step.first,
      step.sublist(1),
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );
    final code = await process.exitCode;
    if (code != 0) {
      stderr.writeln('\nFailed: ${step.join(' ')}');
      exit(code);
    }
  }
  print('\nAll checks passed.');
}
