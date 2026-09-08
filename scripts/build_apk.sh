#!/usr/bin/env bash
# Baut die Android-APK (nur arm64, Release).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

find_flutter() {
  if command -v flutter >/dev/null 2>&1; then
    command -v flutter
  elif [ -x "$HOME/tools/flutter/bin/flutter" ]; then
    echo "$HOME/tools/flutter/bin/flutter"
  elif [ -x "$HOME/sdks/flutter/bin/flutter" ]; then
    echo "$HOME/sdks/flutter/bin/flutter"
  else
    return 1
  fi
}

FLUTTER_BIN="$(find_flutter)" || {
  echo "Flutter nicht gefunden. Bitte zuerst scripts/setup.sh ausführen." >&2
  exit 1
}
export PATH="$(dirname "$FLUTTER_BIN"):$PATH"

echo "Verwende: $FLUTTER_BIN"
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" build apk --release --target-platform android-arm64

echo ""
echo "Fertig! APK: build/app/outputs/flutter-apk/app-release.apk"
