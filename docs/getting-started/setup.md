# Setup

This page takes you from a fresh machine to the app running on a device or emulator.

## 1. Install the tools

| Tool | Version | Needed for |
|---|---|---|
| Flutter SDK | stable channel, 3.47 or newer (Dart 3.13+) | everything |
| Android Studio + Android SDK | latest | Android builds and the emulator |
| JDK | 17 | Android builds (bundled with Android Studio) |
| Xcode + CocoaPods | latest, macOS only | iOS and macOS builds |
| Visual Studio 2022 with "Desktop development with C++" | Windows only | Windows desktop builds |
| VS Code or Android Studio | any | editing (VS Code settings are included in `.vscode/`) |

Follow the official guide for your OS: <https://docs.flutter.dev/get-started/install>.

Then check everything is wired up:

```bash
flutter doctor
```

Fix anything marked with a red cross for the platforms you care about. You don't need every platform.

## 2. Get the code and dependencies

```bash
git clone <your-repo-url> my_app
cd my_app
flutter pub get
```

## 3. Run the app

Start an emulator or plug in a device, then:

```bash
flutter devices                                        # list available targets
flutter run --dart-define-from-file=config/dev.json    # run with the dev environment
```

In VS Code, open the Run and Debug panel and pick **dev**, **staging**, or **prod (profile)**. These launch configurations already pass the right config file.

While the app is running, press `r` for hot reload, `R` for hot restart, `q` to quit.

> If you run without `--dart-define-from-file`, the app falls back to the defaults in `lib/core/config/env.dart`.

## 4. Check your work

Before pushing code, run the same checks CI runs:

```bash
dart run scripts/check.dart
```

This checks formatting, runs the analyzer, and runs all tests. It stops at the first failure.

## Troubleshooting

| Problem | Fix |
|---|---|
| `flutter: command not found` | Add `<flutter-sdk>/bin` to your `PATH` and open a new terminal. |
| Android license errors | `flutter doctor --android-licenses` |
| iOS build fails on pods | `cd ios && pod install --repo-update`, then try again. |
| Strange build errors after switching branches | `flutter clean && flutter pub get` |
