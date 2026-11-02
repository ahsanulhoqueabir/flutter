# Networking

All HTTP traffic goes through one place: `lib/core/network/`.

| File | Role |
|---|---|
| `network_providers.dart` | Creates the single `Dio` instance (base URL, timeouts, interceptors) and the `ApiClient` provider |
| `api_client.dart` | `get`, `post`, `put`, `patch`, `delete`; converts Dio errors to `ApiException` |
| `api_exception.dart` | The error types the rest of the app sees |
| `interceptors.dart` | `AuthInterceptor` (bearer token) and `LoggingInterceptor` |

## Making a request

Requests are made from **repositories only**:

```dart
class PostsRepository {
  PostsRepository(this._api);
  final ApiClient _api;

  Future<Post> fetchPost(int id) async {
    final json = await _api.get<Map<String, dynamic>>('/posts/$id');
    return Post.fromJson(json);
  }
}

final postsRepositoryProvider = Provider((ref) => PostsRepository(ref.watch(apiClientProvider)));
```

The type argument is the raw JSON shape: `Map<String, dynamic>` for an object, `List<dynamic>` for an array.

## Errors

`ApiClient` catches every `DioException` and throws an `ApiException` instead:

| Exception | When |
|---|---|
| `NetworkException` | No connection |
| `RequestTimeoutException` | Connect, send, or receive timeout |
| `UnauthorizedException` | HTTP 401 |
| `ForbiddenException` | HTTP 403 |
| `NotFoundException` | HTTP 404 |
| `ValidationException(fieldErrors)` | HTTP 400 or 422 |
| `TooManyRequestsException` | HTTP 429 |
| `MaintenanceException` | HTTP 503 |
| `BadResponseException` | Response body has an unexpected shape |
| `ServerException(statusCode)` | Any other non-2xx response |
| `CancelledException` | The request was cancelled |
| `UnknownApiException` | Anything else |

Every exception has a `message` that is safe to show to users. Because `ApiException` is `sealed`, you can `switch` over it and the compiler checks you've covered every case.

In providers, errors flow into `AsyncValue.error` automatically, and `AsyncValueView` displays them. For actions (button presses), catch them:

```dart
try {
  await ref.read(postsProvider.notifier).add(title: t, body: b);
} on ApiException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
}
```

## Authentication

`AuthInterceptor` adds `Authorization: Bearer <token>` to every request when a token is saved, and signs the user out if the server rejects that token. Sign in and out through `authProvider`, which saves and clears the token:

```dart
await ref.read(authProvider.notifier).login(email: email, password: password);
await ref.read(authProvider.notifier).logout();
```

For production apps holding real credentials, move the token to `flutter_secure_storage`. To refresh expired tokens, add an interceptor that catches 401 responses, refreshes, and retries.

## Logging

When `ENABLE_HTTP_LOGS` is `true` (dev and staging), every request and response is logged via `AppLogger`. It's off in prod.
