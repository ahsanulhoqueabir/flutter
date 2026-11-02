#!/usr/bin/env sh
# Minor release: 1.2.3+4 -> 1.3.0+5
set -e
cd "$(dirname "$0")/.."
dart run scripts/version.dart minor
