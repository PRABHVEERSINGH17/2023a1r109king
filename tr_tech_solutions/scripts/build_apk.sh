#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "Building release APK..."
flutter clean
flutter pub get
flutter build apk --release
mkdir -p release
cp -f build/app/outputs/flutter-apk/app-release.apk release/TR-Tech-Solutions.apk
echo
echo "APK ready:"
echo "  release/TR-Tech-Solutions.apk"
ls -lh release/TR-Tech-Solutions.apk
