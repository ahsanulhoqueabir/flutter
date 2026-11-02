# Testing

## Running tests

```bash
flutter test                                   # all tests
flutter test test/features/posts               # one folder
flutter test --name "shows error"              # tests whose name matches
flutter test --coverage                        # writes coverage/lcov.info
```

## What to test

| Code | Test type | Example |
|---|---|---|
| `ApiClient`, utilities | Unit test | `test/core/network/api_client_test.dart` |
| Repositories | Unit test with a mocked `ApiClient` | — |
| Notifiers with logic | Unit test with `ProviderContainer` | — |
| Screens | Widget test with a mocked repository | `test/features/posts/posts_screen_test.dart` |

At minimum, every screen gets a test for its success state and its error state.

## File layout

`test/` mirrors `lib/`. A file at `lib/features/posts/data/posts_repository.dart` is tested in `test/features/posts/posts_repository_test.dart`.

## Mocking

Use [mocktail](https://pub.dev/packages/mocktail). No code generation needed:

```dart
class _MockPostsRepository extends Mock implements PostsRepository {}

final repo = _MockPostsRepository();
when(() => repo.fetchPosts()).thenAnswer((_) async => [/* ... */]);
```

## Widget tests

`test/helpers/pump_app.dart` wraps a widget in `ProviderScope` and `MaterialApp`, provides in-memory `SharedPreferences`, and turns off Riverpod's automatic retry:

```dart
await tester.pumpApp(
  const PostsScreen(),
  overrides: [postsRepositoryProvider.overrideWithValue(repo)],
);
await tester.pumpAndSettle();
expect(find.text('Hello'), findsOneWidget);
```

## Provider tests

```dart
test('loads posts', () async {
  final container = ProviderContainer.test(
    overrides: [postsRepositoryProvider.overrideWithValue(repo)],
  );
  expect(await container.read(postsProvider.future), hasLength(1));
});
```

`ProviderContainer.test` disposes itself when the test ends.

## Rules

- Tests never call the real network.
- One behavior per test; the name says what that behavior is.
- Arrange, act, assert, in that order, with a blank line between them.
