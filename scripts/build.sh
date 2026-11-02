#!/usr/bin/env sh
# Release build with automatic version bump. Example: ./scripts/build.sh appbundle --env prod
set -e
cd "$(dirname "$0")/.."
dart run scripts/build.dart "$@"
