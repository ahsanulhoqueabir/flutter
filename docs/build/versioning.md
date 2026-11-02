# Versioning

## How the version number works

The version lives in **one place**, the `version:` line in `pubspec.yaml`:

```yaml
version: 1.4.2+37
```

| Part | Name | Meaning | Shown to users? |
|---|---|---|---|
| `1` | major | Big or breaking changes | Yes |
| `4` | minor | New features | Yes |
| `2` | patch | Bug fixes | Yes |
| `37` | build number | Increases with every build you upload | No |

At build time Flutter copies these into each platform. You never edit native files for versioning:

- Android: `versionName = 1.4.2`, `versionCode = 37`
- iOS/macOS: `CFBundleShortVersionString = 1.4.2`, `CFBundleVersion = 37`
- Windows, Linux, web: the same values in their own metadata

**The build number always goes up**, even when major/minor/patch change. App stores reject an upload whose build number isn't higher than the previous one.

## Automatic bump on every build

The build script bumps the version before building:

```bash
dart run scripts/build.dart appbundle                  # 1.4.2+37 -> 1.4.2+38
dart run scripts/build.dart appbundle --bump patch     # 1.4.2+37 -> 1.4.3+38
dart run scripts/build.dart appbundle --bump minor     # 1.4.2+37 -> 1.5.0+38
dart run scripts/build.dart appbundle --bump major     # 1.4.2+37 -> 2.0.0+38
dart run scripts/build.dart appbundle --bump none      # no change
```

If the build fails, the old version is restored so you don't skip numbers.

## Bumping without building

```bash
dart run scripts/version.dart show      # print the current version
dart run scripts/version.dart build     # +1 build number
dart run scripts/version.dart patch
dart run scripts/version.dart minor
dart run scripts/version.dart major
dart run scripts/version.dart set 2.1.0 # set an exact version (build number still +1)
```

Dedicated scripts for the two most common release types:

| | macOS / Linux | Windows |
|---|---|---|
| Minor release | `./scripts/bump_minor.sh` | `.\scripts\bump_minor.ps1` |
| Major release | `./scripts/bump_major.sh` | `.\scripts\bump_major.ps1` |

On macOS/Linux, make the shell scripts executable once: `chmod +x scripts/*.sh`.

## Which bump should I use?

- Re-uploading the same release to TestFlight or an internal track → `build`
- Released bug fixes only → `patch`
- Released new features → `minor`
- Redesign, dropped features, or breaking data changes → `major`

## Recommended release routine

1. `dart run scripts/check.dart`
2. `dart run scripts/build.dart appbundle --bump minor` (or whichever bump fits)
3. `dart run scripts/build.dart ipa --bump none`
4. Move the "Unreleased" notes in `CHANGELOG.md` under the new version.
5. Commit `pubspec.yaml` and `CHANGELOG.md`, then tag: `git tag v1.5.0+38 && git push --tags`.

## In CI

CI builds use `--bump none`, because a CI runner shouldn't change the committed version. Bump locally (or in a dedicated release job that commits the bump) and let CI build what's committed.
