# Flutter Template

A production-ready starting point for Flutter apps.

- **Riverpod 3** for state management and dependency injection (no code generation)
- **Dio** behind a single `ApiClient` with typed errors and auth/logging interceptors
- **go_router** navigation with central route constants
- **dev / staging / prod** environments via `--dart-define-from-file`
- Material 3 light/dark theme with persisted theme mode
- **Automatic versioning** on every build, plus major/minor bump scripts
- Tests with `mocktail`, GitHub Actions CI, strict lints
- Docs for developers (`docs/`) and instructions for AI agents (`CLAUDE.md`, `.claude/`)

## Quick start

```bash
flutter pub get
flutter run --dart-define-from-file=config/dev.json
```

## Common commands

| Task | Command |
|---|---|
| Run all checks (format, analyze, test) | `dart run scripts/check.dart` |
| Show version | `dart run scripts/version.dart show` |
| Release build (bumps build number) | `dart run scripts/build.dart appbundle` |
| Minor release bump | `./scripts/bump_minor.sh` or `.\scripts\bump_minor.ps1` |
| Major release bump | `./scripts/bump_major.sh` or `.\scripts\bump_major.ps1` |

## Project layout

```
lib/
  app/        App widget, router, theme
  core/       Config, networking, storage, logging
  shared/     Reusable widgets
  features/   One folder per feature (posts = reference example)
test/         Mirrors lib/
scripts/      Versioning, build, and check scripts
config/       Environment files
docs/         Documentation
```

## Documentation

Start at [docs/README.md](docs/README.md). Starting a new app from this template? See
[docs/getting-started/using-this-template.md](docs/getting-started/using-this-template.md).
