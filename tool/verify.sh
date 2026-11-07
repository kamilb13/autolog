#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."

git diff --check
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
python3 -m unittest discover -s tool -p 'test_*.py' -v
