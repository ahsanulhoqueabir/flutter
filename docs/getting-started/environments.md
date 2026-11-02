# Environments

The app has three environments: **dev**, **staging**, and **prod**. Each one is a JSON file in `config/`:

```json
{
  "APP_ENV": "dev",
  "APP_NAME": "Template Dev",
  "API_BASE_URL": "https://api.dev.example.com",
  "ENABLE_HTTP_LOGS": "true"
}
```

You choose one when you run or build:

```bash
flutter run --dart-define-from-file=config/staging.json
dart run scripts/build.dart apk --env staging
```

## How the app reads them

Flutter compiles these values into the app as constants. The class `Env` in `lib/core/config/env.dart` is the only place that reads them:

```dart
Env.name          // 'dev' | 'staging' | 'prod'
Env.apiBaseUrl
Env.enableHttpLogs
Env.isProd
```

Use `Env` everywhere else. Don't call `String.fromEnvironment` in other files.

## Adding a new value

1. Add the key to **all three** files in `config/`.
2. Add a matching `static const` field to `Env`, with a sensible `defaultValue`.
3. Use `Env.yourValue` in code.

## Secrets

Anything in these files ends up inside the app binary, and anyone can extract it. Only put **public** values here: URLs, feature flags, public API keys meant for client apps. Real secrets belong on your backend.

For machine-specific overrides, create `config/dev.local.json` (git-ignored) and run with `--dart-define-from-file=config/dev.local.json`.
