# Code style

Most style rules are enforced automatically by `dart format` and the analyzer (`analysis_options.yaml`). If `dart run scripts/check.dart` passes, formatting and lint rules are satisfied.

## Formatting

- Line length is **100** characters.
- Run `dart format lib test scripts`, or let VS Code format on save (already configured in `.vscode/settings.json`).

## Naming

| Thing | Style | Example |
|---|---|---|
| Files and folders | `snake_case` | `posts_repository.dart` |
| Classes, enums, typedefs | `UpperCamelCase` | `PostsRepository` |
| Variables, functions, providers | `lowerCamelCase` | `postsProvider` |
| Private members | leading underscore | `_api` |
| Screens | `<Name>Screen` in `<name>_screen.dart` | `PostsScreen` |
| Repositories | `<Name>Repository` + `<name>RepositoryProvider` | `PostsRepository` |
| Notifiers | `<Name>Notifier` | `PostsNotifier` |

## Imports

- Inside `lib/`, use relative imports (`'../../core/network/api_client.dart'`).
- In `test/`, use package imports (`'package:template/...'`).
- Order: `dart:`, then `package:`, then relative. The analyzer enforces this.

## General rules

- One public class per file. Small private helper widgets can share the file.
- Use `const` wherever possible. Prefer `final` for locals.
- Prefer extracting a widget class over a `_buildSomething()` method.
- No `print`. Use `AppLogger.debug` / `AppLogger.error`.
- No hard-coded colors or text styles in widgets. Use `Theme.of(context)`.
- Write a doc comment (`///`) on public classes and on anything non-obvious. Explain *why*, not *what*.
- Keep functions short. If a widget's `build` method doesn't fit on one screen, split it.

## Dependencies

Before adding a package, check:

1. Is it well-maintained (recent releases, good pub.dev score)?
2. Can we do it in a few lines ourselves?
3. Does it overlap with something we already use?

Add with `flutter pub add <name>` and mention why in the pull request.
