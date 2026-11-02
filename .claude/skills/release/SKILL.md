---
name: release
description: Bump the app version and produce release builds using the project's scripts. Use when the user asks to release, cut a version, bump the version, or build an APK/AAB/IPA/web release.
---

# Release

Versioning is done ONLY through `scripts/version.dart`/`scripts/build.dart`. Never edit `version:` in `pubspec.yaml` by hand.

1. Confirm with the user: target(s) (`apk`, `appbundle`, `ipa`, `web`, ...), environment (`prod` default), and bump type:
   - `build` (default): new build of the same version, e.g. a re-upload or hotfix test.
   - `patch`: bug fixes. `minor`: new features. `major`: breaking/big release.
2. Run `dart run scripts/check.dart` first. Stop if it fails.
3. Build: `dart run scripts/build.dart <target> --env <env> --bump <type>`.
   For several targets, bump on the first and use `--bump none` for the rest so they share one version.
4. Move `## [Unreleased]` entries in `CHANGELOG.md` under a new `## [x.y.z] - YYYY-MM-DD` heading.
5. Report the new version and output paths (see `docs/build/manual-build.md`). Remind the user that `build/symbols/` must be kept for crash de-obfuscation.

Do not commit, tag, or push unless the user asks. Suggested tag: `v<x.y.z>+<build>`.
