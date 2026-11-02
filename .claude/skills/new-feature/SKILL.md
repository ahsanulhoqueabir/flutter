---
name: new-feature
description: Scaffold a new feature module (model, repository, providers, screen, route, tests) following the project's features/posts pattern. Use when the user asks to add a new screen, module, or feature backed by data.
---

# New feature

Reference implementation: `lib/features/posts/`. Read it before starting; mirror its shape exactly.

Ask the user (or infer from the request) for: feature name (snake_case), endpoints and JSON shape, which screens.

## Steps

1. **Model** — `lib/features/<name>/domain/<model>.dart`
   Immutable class, `const` constructor, `fromJson` factory, `toJson`, `==`/`hashCode`. Copy `post.dart`.

2. **Repository** — `lib/features/<name>/data/<name>_repository.dart`
   Class taking `ApiClient`; one method per endpoint returning models. In the same file:
   `final <name>RepositoryProvider = Provider<XRepository>((ref) => XRepository(ref.watch(apiClientProvider)));`

3. **Providers** — `lib/features/<name>/<name>_providers.dart`
   Pick the type per `.claude/rules/riverpod.md`. List + mutations → `AsyncNotifier`; item by id → `FutureProvider.autoDispose.family`.

4. **Screens** — `lib/features/<name>/presentation/<screen>_screen.dart`
   `ConsumerWidget`, `ref.watch(provider)`, render with `AsyncValueView`, retry with `ref.invalidate`.

5. **Routes** — add constants to `lib/app/router/routes.dart`, add `GoRoute`s to `lib/app/router/app_router.dart`.

6. **Tests**
   - `test/features/<name>/<name>_screen_test.dart`: success + error state with a mocked repository (copy `posts_screen_test.dart`).
   - Notifier test if it has mutations.

7. **Verify** — run `dart run scripts/check.dart`; fix every issue before reporting done.

Do not add packages. Do not create `domain/usecases`, `entities` vs `dtos`, or abstract repository interfaces unless the user asks; this template intentionally keeps one model and one concrete repository per feature.
