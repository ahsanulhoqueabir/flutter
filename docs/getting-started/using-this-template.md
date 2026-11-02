# Starting a new project from this template

Follow these steps once, right after copying the template.

## 1. Copy the template

Either use "Use this template" on GitHub, or copy the folder without its history:

```bash
cp -r template my_app && cd my_app
rm -rf .git build .dart_tool
git init
```

## 2. Rename the Dart package

1. In `pubspec.yaml`, change `name: template` to your package name (lowercase with underscores, e.g. `my_app`) and update `description`.
2. Find and replace `package:template/` with `package:my_app/` across `test/` (app code in `lib/` uses relative imports, so nothing changes there).
3. Run `flutter pub get`.

## 3. Set the app identity on each platform

| Platform | What to change | File |
|---|---|---|
| Android | `applicationId` and `namespace` (e.g. `com.company.myapp`) | `android/app/build.gradle.kts` |
| Android | App name: `android:label` | `android/app/src/main/AndroidManifest.xml` |
| Android | Move `MainActivity.kt` to the folder matching the new package and update its `package` line | `android/app/src/main/kotlin/...` |
| iOS | Bundle identifier, display name, team | Open `ios/Runner.xcworkspace` in Xcode → Runner target → General / Signing |
| macOS | Same as iOS | `macos/Runner.xcworkspace` |
| Web | `<title>` and app name | `web/index.html`, `web/manifest.json` |
| Windows | Window title and binary name | `windows/runner/main.cpp`, `windows/CMakeLists.txt` |
| Linux | `BINARY_NAME`, `APPLICATION_ID` | `linux/CMakeLists.txt` |

Delete platform folders you won't ship (e.g. `rm -rf linux`). You can add them back later with `flutter create --platforms=linux .`.

## 4. Configure your environments

Edit `config/dev.json`, `config/staging.json`, `config/prod.json` with your real API URLs and app names. See [environments.md](environments.md).

## 5. Rebrand

- Change the seed color in `lib/app/theme/app_theme.dart`.
- Replace app icons and splash screens (the packages `flutter_launcher_icons` and `flutter_native_splash` are the usual choice).

## 6. Remove the examples

`lib/features/posts/` and its tests are a reference implementation that calls a public demo API. When your first real feature exists:

1. Delete `lib/features/posts/` and `test/features/posts/`.
2. Remove its routes from `lib/app/router/routes.dart` and `app_router.dart`, and point `initialLocation` at your home screen.

Keep `features/settings/` if you want the theme switcher.

## 7. Reset the version

```bash
dart run scripts/version.dart set 0.1.0
```

Then edit `CHANGELOG.md`, update the root `README.md`, and run `dart run scripts/check.dart`.
