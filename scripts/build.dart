// ignore_for_file: avoid_print

/// Builds a release artifact and bumps the version automatically.
///
/// Usage (run from the project root):
///   `dart run scripts/build.dart <target> [--env dev|staging|prod] [--bump build|patch|minor|major|none]`
///
/// Targets: apk, appbundle, ipa, ios, web, windows, macos, linux
///
/// Defaults: --env prod --bump build
///
/// Examples:
///   dart run scripts/build.dart appbundle                 # 1.2.3+4 -> 1.2.3+5, then build
///   dart run scripts/build.dart apk --env staging --bump patch
///   dart run scripts/build.dart ipa --bump minor
///
/// If the build fails, pubspec.yaml is restored to its previous version.
library;

import 'dart:io';

import 'version.dart';

const _targets = {'apk', 'appbundle', 'ipa', 'ios', 'web', 'windows', 'macos', 'linux'};
const _obfuscatable = {'apk', 'appbundle', 'ipa', 'ios', 'macos'};
const _bumps = {'build', 'patch', 'minor', 'major', 'none'};

Future<void> main(List<String> args) async {
  if (args.isEmpty || !_targets.contains(args.first)) {
    stderr.writeln(
      'Usage: dart run scripts/build.dart <${_targets.join('|')}> '
      '[--env dev|staging|prod] [--bump ${_bumps.join('|')}]',
    );
    exit(64);
  }

  final target = args.first;
  final env = _option(args, '--env') ?? 'prod';
  final bump = _option(args, '--bump') ?? 'build';

  final envFile = File('config/$env.json');
  if (!envFile.existsSync()) _fail('Missing ${envFile.path}');
  if (!_bumps.contains(bump)) _fail('--bump must be one of ${_bumps.join(', ')}');

  final before = readVersion();
  final version = bump == 'none' ? before : bumpVersion(bump).$2;
  print('Building $target ($env) version $version');

  final flutterArgs = [
    'build',
    target,
    '--release',
    '--dart-define-from-file=${envFile.path}',
    if (_obfuscatable.contains(target)) ...[
      '--obfuscate',
      '--split-debug-info=build/symbols/$target',
    ],
  ];

  final process = await Process.start(
    'flutter',
    flutterArgs,
    mode: ProcessStartMode.inheritStdio,
    runInShell: true, // Needed on Windows where flutter is a .bat file.
  );
  final code = await process.exitCode;

  if (code != 0) {
    if (bump != 'none') {
      writeVersion(before);
      stderr.writeln('Build failed. Version restored to $before.');
    }
    exit(code);
  }
  print('\nDone: $target $version.');
  if (_obfuscatable.contains(target)) {
    print('Archive build/symbols/$target/ to de-obfuscate crash reports for this release.');
  }
}

String? _option(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
