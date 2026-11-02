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
   static const orders = '/orders';
   ```
2. Add a route in `app_router.dart`, inside a shell branch if it should keep the bottom bar:
   ```dart
   GoRoute(path: Routes.orders, builder: (_, _) => const OrdersScreen()),
   ```
3. For parameters, parse them in the router and pass typed values to the screen:
   ```dart
   GoRoute(
     path: '/users/:id',
     builder: (_, state) => UserScreen(userId: int.parse(state.pathParameters['id']!)),
   ),
   ```

## Guards

Access rules live in `resolveRedirect` in `app_router.dart`, a plain function covered by `test/app/redirect_test.dart`. New routes require sign-in by default. To change that, add the path to `Routes.public` or `Routes.authOnly`. See [app-flow.md](app-flow.md).
