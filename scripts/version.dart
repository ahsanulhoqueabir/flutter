// ignore_for_file: avoid_print

/// Version manager for `pubspec.yaml`.
///
/// Usage:
///   dart run scripts/version.dart show
///   dart run scripts/version.dart build    # 1.2.3+4 -> 1.2.3+5
///   dart run scripts/version.dart patch    # 1.2.3+4 -> 1.2.4+5
///   dart run scripts/version.dart minor    # 1.2.3+4 -> 1.3.0+5
///   dart run scripts/version.dart major    # 1.2.3+4 -> 2.0.0+5
///   dart run scripts/version.dart set 1.4.0   # keeps and increments build number
///
/// The build number ALWAYS increases, because the App Store and Play Store
/// reject uploads whose build number is not higher than the previous one.
/// Flutter copies this version into Android (versionName/versionCode) and
/// iOS/macOS (CFBundleShortVersionString/CFBundleVersion) at build time,
/// so pubspec.yaml is the single source of truth.
library;

import 'dart:io';

final _pubspec = File('pubspec.yaml');
final _versionLine = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$', multiLine: true);

class AppVersion {
  const AppVersion(this.major, this.minor, this.patch, this.build);

  final int major;
  final int minor;
  final int patch;
  final int build;

  String get name => '$major.$minor.$patch';

  @override
  String toString() => '$name+$build';

  AppVersion bump(String part) => switch (part) {
    'build' => AppVersion(major, minor, patch, build + 1),
    'patch' => AppVersion(major, minor, patch + 1, build + 1),
    'minor' => AppVersion(major, minor + 1, 0, build + 1),
    'major' => AppVersion(major + 1, 0, 0, build + 1),
    _ => throw ArgumentError('Unknown version part "$part"'),
  };
}

AppVersion readVersion() {
  final match = _versionLine.firstMatch(_pubspec.readAsStringSync());
  if (match == null) {
    throw StateError('pubspec.yaml must contain a line like "version: 1.0.0+1"');
  }
  return AppVersion(
    int.parse(match[1]!),
    int.parse(match[2]!),
    int.parse(match[3]!),
    int.parse(match[4]!),
  );
}

void writeVersion(AppVersion v) {
  final content = _pubspec.readAsStringSync();
  _pubspec.writeAsStringSync(content.replaceFirst(_versionLine, 'version: $v'));
}

/// Bumps [part] in pubspec.yaml and returns `(old, new)`.
(AppVersion, AppVersion) bumpVersion(String part) {
  final old = readVersion();
  final next = old.bump(part);
  writeVersion(next);
  return (old, next);
}

void main(List<String> args) {
  if (!_pubspec.existsSync()) {
    stderr.writeln('Run this from the project root (pubspec.yaml not found).');
    exit(64);
  }

  final command = args.isEmpty ? 'show' : args.first;
  try {
    switch (command) {
      case 'show':
        print(readVersion());
      case 'build' || 'patch' || 'minor' || 'major':
        final (old, next) = bumpVersion(command);
        print('Version: $old -> $next');
      case 'set':
        final parts = args.length > 1
            ? args[1].split('.').map(int.tryParse).toList()
            : const <int?>[];
        if (parts.length != 3 || parts.contains(null)) {
          throw ArgumentError('Usage: set MAJOR.MINOR.PATCH, e.g. set 1.4.0');
        }
        final old = readVersion();
        final next = AppVersion(parts[0]!, parts[1]!, parts[2]!, old.build + 1);
        writeVersion(next);
        print('Version: $old -> $next');
      default:
        throw ArgumentError('Unknown command "$command". Use show|build|patch|minor|major|set.');
    }
  } on Object catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}
