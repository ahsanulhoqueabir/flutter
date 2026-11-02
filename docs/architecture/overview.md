# Architecture overview

The project is organized **by feature**, with a small shared core. The goal is that each feature can be understood (and deleted) on its own, while cross-cutting concerns like HTTP live in one place.

## Folder structure

```
lib/
├── main.dart              Entry point: loads async dependencies, starts ProviderScope
├── app/                   The app shell
│   ├── app.dart           MaterialApp.router: theme, router, title
│   ├── router/            Route constants and the GoRouter provider
│   └── theme/             Light and dark ThemeData
├── core/                  Infrastructure shared by all features (no feature code here)
│   ├── config/env.dart    Environment values
│   ├── network/           Dio setup, ApiClient, ApiException, interceptors
│   ├── storage/           LocalStorage wrapper around SharedPreferences
│   └── utils/             Logger and small helpers
├── shared/widgets/        Reusable widgets with no feature knowledge
└── features/
    ├── posts/             Example feature (reference implementation)
    │   ├── domain/        Models
    │   ├── data/          Repository: talks to the API
    │   ├── posts_providers.dart   State exposed to the UI
    │   └── presentation/  Screens and widgets
    └── settings/          Theme switcher (example of local state)
```

## The layers

Each feature has three layers. Dependencies only point downward.

```
 presentation   Screens and widgets. Watch providers, render state, forward user actions.
      │
      ▼
 providers      Riverpod providers and notifiers. Hold state, cache data, expose actions.
      │
      ▼
 data           Repositories. Know endpoints and JSON. Return models.
      │
      ▼
 core/network   ApiClient → Dio. Sends requests, converts errors.
```

**Why repositories?** They keep endpoint paths and JSON parsing out of state code. You can test providers by mocking one class, and you can swap the API without touching the UI.

**Why not more layers?** Many "clean architecture" setups add use cases, entity/DTO pairs, and abstract repository interfaces. For most apps these add files without adding value. If a feature grows complex enough to need them, add them to that feature only.

## How data reaches a widget

Take the posts list as an example:

1. `PostsScreen` calls `ref.watch(postsProvider)`.
2. `postsProvider` (an `AsyncNotifier`) runs `build()`, which calls `PostsRepository.fetchPosts()`.
3. The repository calls `ApiClient.get('/posts')`, which uses the shared `Dio` instance (base URL, timeouts, auth header, logging).
4. The JSON is mapped to `List<Post>` and returned.
5. The screen receives `AsyncValue<List<Post>>` and renders loading, error, or data through `AsyncValueView`.

Any other widget that calls `ref.watch(postsProvider)` gets the **same cached data**, with no second request. This is how data is shared across the app without duplicating logic.

## Dependency injection

Riverpod is also the dependency-injection system. Every service is a `Provider`:

```
sharedPreferencesProvider → localStorageProvider
dioProvider → apiClientProvider → postsRepositoryProvider → postsProvider
```

Tests replace any link in that chain with `overrideWithValue(fake)`. There is no service locator and no global singletons.

## Where to put new code

| You are adding... | Put it in |
|---|---|
| A screen, its state, its API calls | `lib/features/<feature>/` |
| A widget used by two or more features | `lib/shared/widgets/` |
| Something every feature needs (HTTP, storage, analytics, logging) | `lib/core/<area>/` |
| App-wide setup (routes, theme) | `lib/app/` |
