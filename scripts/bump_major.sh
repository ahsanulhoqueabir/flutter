#!/usr/bin/env sh
# Major release: 1.2.3+4 -> 2.0.0+5
set -e
cd "$(dirname "$0")/.."
dart run scripts/version.dart major
