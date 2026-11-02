---
paths:
  - "lib/**/*providers.dart"
  - "lib/**/presentation/**/*.dart"
  - "lib/app/**/*.dart"
---

# Riverpod rules (flutter_riverpod 3.x, no codegen)

Pick the provider type by what it holds:

| Need | Use |
|---|---|
| A dependency/service (repository, client) | `Provider<T>` |
| Read-only async data, keyed or not | `FutureProvider` / `FutureProvider.autoDispose.family` |
| Async data plus mutations (refresh, add, delete) | `AsyncNotifierProvider` + `AsyncNotifier` |
| Sync app state (theme, filters, form state) | `NotifierProvider` + `Notifier` |

Do not use `StateProvider`, `StateNotifierProvider`, or `ChangeNotifierProvider`: they are legacy in Riverpod 3 and live in `package:flutter_riverpod/legacy.dart`.

- In `build()` of widgets and providers use `ref.watch`. In callbacks (`onPressed`, notifier methods) use `ref.read`.
- Use `.autoDispose` for screen-scoped data (details pages, search results). Keep app-wide caches (lists, user) non-autoDispose.
- To reload: `ref.invalidate(provider)` from UI, or `ref.invalidateSelf(); await future;` inside a notifier.
- Mutations: call the repository, then set `state = AsyncData(...)`. Let exceptions propagate to the caller unless the UI must show them inline.
- Widgets that need `ref` extend `ConsumerWidget` / `ConsumerStatefulWidget`. Don't wrap trees in `Consumer` unless rebuilding a small part.
- Tests: `Override` is imported from `package:flutter_riverpod/misc.dart`. Override repositories with `overrideWithValue(mock)`.
- Riverpod 3 retries failed providers automatically. Tests disable this via `retry: (_, _) => null` in `pumpApp`.
