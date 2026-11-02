---
name: add-api-endpoint
description: Add a new HTTP endpoint call to an existing feature repository and expose it to the UI through a Riverpod provider. Use when the user asks to call a new API, fetch more data, or add a create/update/delete request.
---

# Add an API endpoint

1. Find the feature's repository in `lib/features/<name>/data/`. If none exists, use the `new-feature` skill instead.
2. Add a method that calls `_api.get/post/put/patch/delete<T>(path, ...)` with `T` being the raw JSON type (`Map<String, dynamic>` or `List<dynamic>`), then maps to a model. Add or extend the model in `domain/` if needed.
3. Expose it:
   - **Read** data → a `FutureProvider` (`.autoDispose.family` if it takes an argument) in `<name>_providers.dart`.
   - **Write** (create/update/delete) → a method on the feature's `AsyncNotifier` that calls the repository, then updates `state`. The UI calls `ref.read(xProvider.notifier).method(...)` and handles errors with try/catch on `ApiException` (show a `SnackBar` with `e.message`).
4. Never call the repository directly from a widget for reads.
5. Add a test with a mocked repository or a mocked `ApiClient`.
6. Run `dart run scripts/check.dart`.

If the endpoint needs auth, nothing extra is needed: `AuthInterceptor` adds the bearer token. If the endpoint needs a different base URL, ask the user before adding a second Dio instance.
