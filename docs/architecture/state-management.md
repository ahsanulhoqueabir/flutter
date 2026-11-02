# State management (Riverpod)

The project uses [flutter_riverpod](https://riverpod.dev) 3.x with **hand-written providers**. There is no code generation, so there is no `build_runner` step and no generated files.

## Choosing a provider

| What you need | Provider | Example in this repo |
|---|---|---|
| A service or dependency | `Provider` | `apiClientProvider`, `postsRepositoryProvider` |
| Data loaded once, read-only | `FutureProvider` | — |
| Data that depends on an argument | `FutureProvider.autoDispose.family` | `postProvider(id)` |
| Async data you also change (refresh, add, delete) | `AsyncNotifierProvider` | `postsProvider` |
| Synchronous state you change | `NotifierProvider` | `themeModeProvider` |

Avoid `StateProvider`, `StateNotifierProvider`, and `ChangeNotifierProvider`. They are legacy in Riverpod 3.

## Reading providers

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);         // rebuilds when it changes
    return ElevatedButton(
      onPressed: () => ref.read(postsProvider.notifier).refresh(),  // one-off action
      child: const Text('Refresh'),
    );
  }
}
```

- `ref.watch` inside `build` methods.
- `ref.read` inside callbacks and notifier methods.
- `ref.invalidate(provider)` throws away cached data so it reloads on next watch (used for "Retry").

## Showing async data

Use `AsyncValueView` so every screen handles loading and errors the same way:

```dart
AsyncValueView(
  value: ref.watch(postsProvider),
  onRetry: () => ref.invalidate(postsProvider),
  data: (posts) => PostsList(posts),
)
```

## Caching and lifetime

- Without `.autoDispose`, a provider keeps its value for the whole app session. Use this for data many screens share (current user, lists).
- With `.autoDispose`, the value is dropped when no widget is watching. Use this for screen-specific data (a detail page).

## Writing a notifier

```dart
final todosProvider = AsyncNotifierProvider<TodosNotifier, List<Todo>>(TodosNotifier.new);

class TodosNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() => ref.watch(todosRepositoryProvider).fetchAll();

  Future<void> add(String title) async {
    final created = await ref.read(todosRepositoryProvider).create(title);
    state = AsyncData([...state.value ?? [], created]);
  }
}
```

## Automatic retry

Riverpod 3 retries a failing provider automatically with backoff. That's useful on flaky networks. The test helper turns it off so failures show up immediately.

## Startup dependencies

Some things need `await` before the app starts (e.g. `SharedPreferences`). Load them in `main()` and inject them with `overrides`:

```dart
final prefs = await SharedPreferences.getInstance();
runApp(ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  child: const App(),
));
```
