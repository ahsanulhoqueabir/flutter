# Building the app manually

This page explains how to build release versions of the app yourself, platform by platform.

There are two ways to build:

- **The build script** (recommended): bumps the version, picks the environment, adds obfuscation. One command.
- **Plain Flutter commands**: full control, nothing automatic. Useful when debugging a build problem.

Both are described below.

## Before any build

```bash
flutter pub get
dart run scripts/check.dart      # make sure formatting, analysis and tests pass
```

## Option A: the build script

```bash
dart run scripts/build.dart <target> [--env dev|staging|prod] [--bump build|patch|minor|major|none] [--split-per-abi]
```

- `--env` defaults to `prod`.
- `--bump` defaults to `build` (increase only the build number). See [versioning.md](versioning.md).
- `--split-per-abi` (APK only) builds one smaller APK per CPU architecture. See [Android](#android).
- If the build fails, the version in `pubspec.yaml` is put back.

Wrappers exist if you prefer: `./scripts/build.sh appbundle` (macOS/Linux) or `.\scripts\build.ps1 appbundle` (Windows).

| Target | Command | Output |
|---|---|---|
| Android APK | `dart run scripts/build.dart apk` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android App Bundle (Play Store) | `dart run scripts/build.dart appbundle` | `build/app/outputs/bundle/release/app-release.aab` |
| iOS (App Store / TestFlight) | `dart run scripts/build.dart ipa` | `build/ios/ipa/*.ipa` |
| Web | `dart run scripts/build.dart web` | `build/web/` |
| Windows | `dart run scripts/build.dart windows` | `build/windows/x64/runner/Release/` |
| macOS | `dart run scripts/build.dart macos` | `build/macos/Build/Products/Release/*.app` |
| Linux | `dart run scripts/build.dart linux` | `build/linux/x64/release/bundle/` |

Building for several platforms with the same version? Bump on the first and skip on the rest:

```bash
dart run scripts/build.dart appbundle --bump minor
dart run scripts/build.dart ipa --bump none
```

## Option B: plain Flutter commands

### Android

1. Set up signing once (see [signing.md](signing.md)). Without it, release builds are signed with the debug key and the Play Store will reject them.
2. Build:
   ```bash
   # App Bundle for the Play Store
   flutter build appbundle --release --dart-define-from-file=config/prod.json \
     --obfuscate --split-debug-info=build/symbols/appbundle

   # APK for direct install / testers
   flutter build apk --release --dart-define-from-file=config/prod.json \
     --obfuscate --split-debug-info=build/symbols/apk
   ```
   **One APK per CPU architecture** (smaller files, for direct distribution):
   ```bash
   dart run scripts/build.dart apk --split-per-abi
   # or, without the script:
   flutter build apk --release --split-per-abi --dart-define-from-file=config/prod.json \
     --obfuscate --split-debug-info=build/symbols/apk
   ```
   This creates three files in `build/app/outputs/flutter-apk/`:

   | File | Devices |
   |---|---|
   | `app-arm64-v8a-release.apk` | Nearly all modern phones |
   | `app-armeabi-v7a-release.apk` | Older 32-bit phones |
   | `app-x86_64-release.apk` | Emulators and x86 devices |

   To build only some of them with the plain Flutter command, add `--target-platform android-arm64,android-arm`.
   Flutter gives each architecture its own version code, so it won't equal the build number in `pubspec.yaml`.
   The Play Store doesn't need this: upload the `.aab` and Google delivers the right architecture to each device.
3. Upload the `.aab` in Google Play Console → your app → Release → Create new release.
4. Install an APK on a connected device: `flutter install` or `adb install build/app/outputs/flutter-apk/app-release.apk`.

### iOS (requires a Mac)

1. Open `ios/Runner.xcworkspace` in Xcode once. Under Runner → Signing & Capabilities, select your team and check the bundle identifier.
2. Install pods: `cd ios && pod install && cd ..`
3. Build:
   ```bash
   flutter build ipa --release --dart-define-from-file=config/prod.json \
     --obfuscate --split-debug-info=build/symbols/ipa
   ```
4. Upload `build/ios/ipa/*.ipa` with the **Transporter** app, or open `build/ios/archive/Runner.xcarchive` in Xcode → Distribute App.

### Web

```bash
flutter build web --release --dart-define-from-file=config/prod.json
```

Deploy the contents of `build/web/` to any static host (Firebase Hosting, Netlify, Cloudflare Pages, S3). If the app is served from a sub-path, add `--base-href /sub-path/`.

### Windows (on Windows)

```bash
flutter build windows --release --dart-define-from-file=config/prod.json
```

Ship the whole `build/windows/x64/runner/Release/` folder; the `.exe` needs the DLLs and `data/` folder next to it. For an installer, use MSIX (`msix` package) or Inno Setup.

### macOS (on a Mac)

```bash
flutter build macos --release --dart-define-from-file=config/prod.json
```

Sign and notarize the `.app` through Xcode before distributing outside the App Store.

### Linux (on Linux)

```bash
flutter build linux --release --dart-define-from-file=config/prod.json
```

Ship the `bundle/` folder, or package it as a Snap, Flatpak, or AppImage.

## Obfuscation and debug symbols

`--obfuscate --split-debug-info=build/symbols/...` makes the app harder to reverse-engineer and smaller. The files in `build/symbols/` are needed to read crash stack traces later, so **archive them for every release** (they are git-ignored). To decode a stack trace:

```bash
flutter symbolize -i crash.txt -d build/symbols/appbundle/app.android-arm64.symbols
```

## Cleaning up

If a build behaves strangely:

```bash
flutter clean
flutter pub get
```
