# CLAUDE.md

Instructions for Claude Code and other AI coding agents working in this repo.
Read this first. Deeper docs live in `docs/`; path-specific rules in `.claude/rules/`.

## What this project is

A Flutter app template. Stack (do not swap without being asked):

| Concern | Choice | Where |
|---|---|---|
| State management / DI | `flutter_riverpod` 3.x, **manual providers, no code generation** | everywhere |
| HTTP | `dio` behind `ApiClient` | `lib/core/network/` |
| Navigation | `go_router` | `lib/app/router/` |
| Local storage | `shared_preferences` behind `LocalStorage` | `lib/core/storage/` |
| Environments | `--dart-define-from-file=config/<env>.json` read by `Env` | `config/`, `lib/core/config/env.dart` |
| Tests | `flutter_test` + `mocktail` | `test/` |

Dart package name is `template` (imports look like `package:template/...`).

## Layout

```
lib/
  main.dart                 # bootstraps prefs, ProviderScope, runApp
  app/                      # app shell: App widget, router, theme
  core/                     # cross-cutting infrastructure, no feature code
    config/env.dart         # the ONLY place that reads dart-defines
    network/                # Dio, ApiClient, ApiException, interceptors, providers
    storage/                # LocalStorage + providers
    utils/logger.dart       # AppLogger (never use print)
  shared/widgets/           # reusable, feature-agnostic widgets (AsyncValueView, ErrorView...)
  features/<name>/
    domain/                 # models (plain immutable classes)
    data/                   # <name>_repository.dart + its Provider
    <name>_providers.dart   # Riverpod state (Notifier / AsyncNotifier / FutureProvider)
    presentation/           # screens + widgets/ subfolder
test/                       # mirrors lib/; helpers/pump_app.dart for widget tests
scripts/                    # version.dart, build.dart, check.dart (+ .sh/.ps1 wrappers)
config/                     # dev.json, staging.json, prod.json
docs/                       # human documentation
```

`features/posts` is the reference implementation. Copy its shape for new features.

## Data flow (the one rule that matters most)

```
Widget --watch--> feature provider --read--> Repository --> ApiClient --> Dio
```

- Widgets never call `ApiClient`, `Dio`, or repositories directly for data; they `ref.watch` a provider.
- Repositories are the only classes that know endpoint paths and JSON shape. They return models, never `Response` or `Map`.
- `ApiClient` throws only `ApiException` subclasses. Don't catch `DioException` outside `core/network`.
- Shared data = shared provider. If two screens need the same data, both watch the same provider; never fetch twice.
- Render `AsyncValue` with `AsyncValueView` (from `shared/widgets`) instead of hand-written `.when`.

## Commands

```bash
flutter pub get
flutter run --dart-define-from-file=config/dev.json
dart run scripts/check.dart             # format check + analyze + test (run before finishing any task)
flutter test path/to/file_test.dart     # single test file
dart format lib test scripts            # format (page width 100)
dart run scripts/version.dart show      # current version
dart run scripts/build.dart apk --env prod   # release build, bumps build number
```

## Conventions

- Files `snake_case.dart`; one public widget/class per file; providers named `xxxProvider`.
- Relative imports inside `lib/`; `package:template/...` imports in `test/`.
- Prefer `const` constructors, `final` locals, trailing commas, single quotes (enforced by lints).
- Colors/typography from `Theme.of(context)`; never hard-code colors in widgets.
- Routes are constants in `lib/app/router/routes.dart`; navigate with `context.push(Routes.x)`.
- New storage keys go in `LocalStorage` as typed getters/setters.
- Every new repository and notifier gets a test; widget tests use `tester.pumpApp(...)` with provider overrides.

## Do not

- Do not add packages (freezed, riverpod_generator, bloc, get_it, http, etc.) unless the user asks. If you think one is needed, say so and why.
- Do not edit `android/`, `ios/`, etc. native folders unless the task is platform-specific.
- Do not edit the `version:` line in `pubspec.yaml` by hand; use `scripts/version.dart`.
- Do not put secrets in `config/*.json`; they are compiled into the app and readable by anyone.
- Do not invent APIs. If unsure whether a Riverpod/Dio/go_router API exists in the installed version, check `pubspec.lock` and the package source in the pub cache, or ask.

## Definition of done

1. `dart run scripts/check.dart` passes (format, analyze with zero issues, tests).
2. New code follows the `features/posts` pattern and has tests.
3. Docs in `docs/` updated if you changed architecture, scripts, or setup steps.

## Skills available in `.claude/skills/`

- `new-feature`: scaffold a feature module end to end.
- `add-api-endpoint`: add an endpoint to an existing repository and expose it via a provider.
- `release`: bump version and produce release builds.
