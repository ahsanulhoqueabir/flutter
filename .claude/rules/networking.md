---
paths:
  - "lib/core/network/**"
  - "lib/features/*/data/**"
---

# Networking rules

- Repositories take `ApiClient` in their constructor and are exposed as `Provider<XRepository>` in the same file, built with `ref.watch(apiClientProvider)`.
- Paths are relative (`'/posts/$id'`); the base URL comes from `Env.apiBaseUrl`.
- Pass the expected JSON type to `ApiClient`: `get<List<dynamic>>` for arrays, `get<Map<String, dynamic>>` for objects. Map to models with `Model.fromJson` inside the repository.
- Never return `Response`, `Map`, or `dynamic` from a repository.
- Error handling is centralized: `ApiClient` converts `DioException` to `ApiException`. To handle a new HTTP case (e.g. 429), add a subclass in `api_exception.dart`; don't add try/catch in repositories.
- Auth headers come from `AuthInterceptor`, which reads the token from `LocalStorage`. Don't set `Authorization` manually.
- New cross-cutting behavior (retry, refresh token, headers) is an `Interceptor` in `interceptors.dart`, registered in `dioProvider`.
