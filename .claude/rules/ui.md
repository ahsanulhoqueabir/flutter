---
paths:
  - "lib/**/presentation/**"
  - "lib/shared/widgets/**"
---

# UI rules

- Screens: `<name>_screen.dart`, class `<Name>Screen`. Feature-only widgets go in `presentation/widgets/`. Widgets used by 2+ features move to `lib/shared/widgets/`.
- Extract a widget class (not a `_buildX()` method) once a piece of UI is reused or exceeds ~40 lines.
- Use `AsyncValueView` for async data, `LoadingView` / `ErrorView` for standalone states.
- Colors: `Theme.of(context).colorScheme.*`. Text styles: `Theme.of(context).textTheme.*`. No hex colors in widgets; change `AppTheme` instead.
- Spacing with `SizedBox` / `EdgeInsets` multiples of 4.
- Add every new screen to `routes.dart` + `app_router.dart`. Path parameters are parsed in the router, and screens receive typed constructor args.
- User-facing strings are inline for now. If the project adds localization (`flutter gen-l10n`), move them to ARB files.
