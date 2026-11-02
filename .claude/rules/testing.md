---
paths:
  - "test/**"
---

# Testing rules

- `test/` mirrors `lib/`: `lib/features/x/data/x_repository.dart` → `test/features/x/x_repository_test.dart`.
- Import app code with `package:template/...`.
- Mock with `mocktail` (`class _MockX extends Mock implements X {}`). No `mockito`, no build_runner.
- Widget tests: `await tester.pumpApp(const MyScreen(), overrides: [xRepositoryProvider.overrideWithValue(mock)])` from `test/helpers/pump_app.dart`.
- Provider/notifier unit tests: `final container = ProviderContainer.test(overrides: [...]);` then `await container.read(xProvider.future)`.
- Never hit the real network in tests.
- Test names describe behavior: `'shows error view with retry on failure'`.
