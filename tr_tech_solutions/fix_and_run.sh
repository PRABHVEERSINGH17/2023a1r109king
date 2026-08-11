#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
echo "Fixing TR Tech Solutions project..."
flutter clean
flutter pub get
echo
echo "DONE. Press F5 in VS Code or run: flutter run -d chrome"
