#!/usr/bin/env bash
# Install the built release APK onto a connected Android phone.
set -euo pipefail
cd "$(dirname "$0")/.."

APK="release/TR-Tech-Solutions.apk"
if [[ ! -f "$APK" ]]; then
  echo "APK missing — building…"
  chmod +x scripts/build_apk.sh
  ./scripts/build_apk.sh
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found."
  echo "Copy this file to your phone and open it:"
  echo "  $(pwd)/$APK"
  exit 1
fi

echo "Devices:"
adb devices
echo
echo "Installing $APK …"
adb install -r "$APK"
echo
echo "Done. Open TR Tech Solutions on your phone → Continue with Demo Mode."
