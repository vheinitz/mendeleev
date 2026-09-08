#!/usr/bin/env bash
# Lädt/installiert die benötigten Werkzeuge (Flutter SDK und Android SDK),
# falls sie noch nicht vorhanden sind. Bereits installierte Werkzeuge werden
# erkannt und übersprungen.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FLUTTER_DIR="${FLUTTER_DIR:-$HOME/tools/flutter}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.7}"
CMDLINE_TOOLS_VERSION="11076708" # Android commandline-tools build

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m[OK]\033[0m   %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
fail()  { printf '\033[1;31m[FEHLER]\033[0m %s\n' "$*"; exit 1; }

command -v curl >/dev/null 2>&1 || fail "curl wird benötigt (sudo apt install curl)."
command -v unzip >/dev/null 2>&1 || fail "unzip wird benötigt (sudo apt install unzip)."
command -v tar >/dev/null 2>&1 || fail "tar wird benötigt."

# ---------------------------------------------------------------- Flutter
FLUTTER_BIN=""
if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="$(command -v flutter)"
elif [ -x "$FLUTTER_DIR/bin/flutter" ]; then
  FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"
fi

if [ -z "$FLUTTER_BIN" ]; then
  info "Flutter SDK nicht gefunden – lade Version $FLUTTER_VERSION herunter ..."
  mkdir -p "$(dirname "$FLUTTER_DIR")"
  URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  curl -fL "$URL" -o /tmp/flutter.tar.xz
  rm -rf "$FLUTTER_DIR"
  tar -xf /tmp/flutter.tar.xz -C "$(dirname "$FLUTTER_DIR")"
  FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"
  ok "Flutter installiert unter $FLUTTER_DIR"
else
  ok "Flutter gefunden: $FLUTTER_BIN"
fi
export PATH="$(dirname "$FLUTTER_BIN"):$PATH"

# ------------------------------------------------------------ Android SDK
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

if [ ! -f "$ANDROID_SDK_ROOT/platform-tools/adb" ]; then
  info "Android SDK nicht vollständig – lade commandline-tools herunter ..."
  mkdir -p "$ANDROID_SDK_ROOT"
  URL="https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"
  curl -fL "$URL" -o /tmp/cmdline-tools.zip
  rm -rf /tmp/cmdline-tools
  unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools
  rm -rf "$ANDROID_SDK_ROOT/cmdline-tools/latest"
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
  mv /tmp/cmdline-tools/cmdline-tools "$ANDROID_SDK_ROOT/cmdline-tools/latest"
  ok "commandline-tools installiert"
else
  ok "Android SDK gefunden: $ANDROID_SDK_ROOT"
fi

SDKMANAGER=""
for c in \
  "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" \
  "$ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager"; do
  if [ -x "$c" ]; then SDKMANAGER="$c"; break; fi
done

if [ -z "$SDKMANAGER" ]; then
  warn "sdkmanager nicht gefunden – Android-Pakete bitte manuell installieren."
else
  info "Installiere/aktualisiere Android-Pakete ..."
  yes | "$SDKMANAGER" --licenses >/dev/null 2>&1 || true
  "$SDKMANAGER" "platform-tools" "build-tools;36.0.0" "platforms;android-36" >/dev/null
  ok "Android-Pakete installiert"
fi

# ------------------------------------------------------------- Abhängigkeiten
cd "$ROOT"
"$FLUTTER_BIN" --version
"$FLUTTER_BIN" pub get

ok "Fertig. APK bauen mit: scripts/build_apk.sh"
