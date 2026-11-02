# Navigation

The app uses [go_router](https://pub.dev/packages/go_router).

- `lib/app/router/routes.dart`: every path as a constant, plus helper functions for paths with parameters.
- `lib/app/router/app_router.dart`: the `GoRouter`, exposed as `routerProvider`.

## Navigating

```dart
context.push(Routes.settings);           // push onto the stack (back button returns)
context.go(Routes.posts);                // replace the stack
context.push(Routes.postDetail(42));     // path with a parameter
context.pop();                            // go back
```

Never write path strings like `'/posts/42'` in widgets. Use `Routes`.

## Adding a screen

1. Add the path to `Routes`:
   ```dart
   static const profile = '/profile';
   ```
2. Add a route in `app_router.dart`:
   ```dart
   GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
   ```
3. For parameters, parse them in the router and pass typed values to the screen:
   ```dart
   GoRoute(
     path: '/users/:id',
     builder: (_, state) => UserScreen(userId: int.parse(state.pathParameters['id']!)),
   ),
   ```

## Guards (e.g. login required)

Because the router is a provider, it can read other providers. Add a `redirect`:

```dart
redirect: (context, state) {
  final loggedIn = ref.read(authProvider) != null;
  if (!loggedIn && state.matchedLocation != Routes.login) return Routes.login;
  return null;
},
```

To re-run the redirect when login state changes, pass a `refreshListenable` that notifies on auth changes.
