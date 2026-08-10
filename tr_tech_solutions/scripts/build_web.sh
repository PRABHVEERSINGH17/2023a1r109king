#!/usr/bin/env bash
# Build TR Tech Solutions for web hosting.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Getting packages..."
flutter pub get

echo "==> Building web release..."
flutter build web --release

echo
echo "DONE. Static site is ready at: build/web"
echo
echo "Host it with one of these:"
echo "  1) Netlify Drop:  https://app.netlify.com/drop  (drag the build/web folder)"
echo "  2) Firebase:      firebase deploy --only hosting"
echo "  3) Local preview:  cd build/web && python3 -m http.server 8080"
echo "  4) Surge:         npx surge build/web"
