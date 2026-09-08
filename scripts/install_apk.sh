#!/usr/bin/env bash
# Installiert die gebaute APK auf einem angeschlossenen Android-Gerät.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK" ]; then
  echo "APK nicht gefunden. Bitte zuerst scripts/build_apk.sh ausführen." >&2
  exit 1
fi

ADB_BIN="adb"
if ! command -v adb >/dev/null 2>&1; then
  if [ -x "$HOME/Android/Sdk/platform-tools/adb" ]; then
    ADB_BIN="$HOME/Android/Sdk/platform-tools/adb"
  else
    echo "adb nicht gefunden. Bitte Android platform-tools installieren (scripts/setup.sh)." >&2
    exit 1
  fi
fi

echo "Installiere: $APK"
"$ADB_BIN" install -r "$APK"
