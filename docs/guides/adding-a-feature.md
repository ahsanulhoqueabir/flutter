# Adding a feature

This walkthrough builds a "users" feature: a list of users from `GET /users`. Each step mirrors a file in `lib/features/posts/`, so open it alongside.

## 1. Create the folders

```
lib/features/users/
├── domain/user.dart
├── data/users_repository.dart
├── users_providers.dart
└── presentation/users_screen.dart
```

## 2. The model

`domain/user.dart`, an immutable class that knows how to read itself from JSON:

```dart
@immutable
class User {
  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  final int id;
  final String name;
  final String email;
}
```

Add `toJson`, `==`, and `hashCode` like `Post` does if you send it to the server or compare instances.

## 3. The repository

`data/users_repository.dart`. This is the only place that knows the endpoint:

```dart
class UsersRepository {
  UsersRepository(this._api);
  final ApiClient _api;

  Future<List<User>> fetchUsers() async {
    final data = await _api.get<List<dynamic>>('/users');
    return data.cast<Map<String, dynamic>>().map(User.fromJson).toList();
  }
}

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(apiClientProvider)),
);
```

## 4. The provider

`users_providers.dart`. If you only read the list, a `FutureProvider` is enough:

```dart
final usersProvider = FutureProvider<List<User>>(
  (ref) => ref.watch(usersRepositoryProvider).fetchUsers(),
);
```

If you'll also add, edit, or delete users, use an `AsyncNotifier` (see `PostsNotifier`).

## 5. The screen

`presentation/users_screen.dart`:

```dart
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: AsyncValueView(
        value: ref.watch(usersProvider),
        onRetry: () => ref.invalidate(usersProvider),
        data: (users) => ListView(
          children: [for (final u in users) ListTile(title: Text(u.name), subtitle: Text(u.email))],
        ),
      ),
    );
  }
}
```

## 6. The route

In `routes.dart` add `static const users = '/users';`, and in `app_router.dart`:

```dart
GoRoute(path: Routes.users, builder: (_, _) => const UsersScreen()),
```

## 7. Tests

Create `test/features/users/users_screen_test.dart` by copying `posts_screen_test.dart` and swapping the names. Test at least the data state and the error state.

## 8. Check

```bash
dart run scripts/check.dart
```

Now **any** widget anywhere can call `ref.watch(usersProvider)` and get the same list, fetched once.
