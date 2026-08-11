#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f android/key.properties ]]; then
  echo "Missing android/key.properties"
  echo "Run ./scripts/create_keystore.sh first."
  exit 1
fi

echo "Building Play Store Android App Bundle..."
flutter clean
flutter pub get
flutter build appbundle --release

echo
echo "DONE."
echo "Upload this file to Google Play Console:"
echo "  build/app/outputs/bundle/release/app-release.aab"
