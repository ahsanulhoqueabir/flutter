# Git workflow

## Branches

- `main` is always releasable. Don't commit to it directly.
- Create a branch per change: `feature/user-profile`, `fix/login-crash`, `chore/upgrade-flutter`.
- Open a pull request into `main`. CI (`.github/workflows/ci.yml`) must pass before merging.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(posts): add pull-to-refresh
fix(network): handle 429 responses
chore: bump version to 1.3.0+12
docs: explain signing setup
refactor(settings): extract theme picker widget
test(posts): cover error state
```

Keep the first line under 72 characters. Add a body if the *why* isn't obvious.

## Before opening a pull request

```bash
dart run scripts/check.dart
```

In the description, say what changed, why, and how you tested it. Add screenshots for UI changes.

## Releases

1. Bump and build (see [versioning.md](../build/versioning.md)).
2. Update `CHANGELOG.md`.
3. Commit: `chore(release): 1.3.0+12`.
4. Tag: `git tag v1.3.0+12` and `git push --tags`.

## Never commit

- Keystores, `key.properties`, certificates, provisioning profiles
- `config/*.local.json` or any file with real secrets
- `build/` output
