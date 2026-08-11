#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/flutter/bin:${PATH}"
export CHROME_EXECUTABLE="${CHROME_EXECUTABLE:-/usr/local/bin/google-chrome}"

echo "==> Installing TR Tech Solutions (Flutter CRM) dependencies"
cd /workspace/tr_tech_solutions
flutter pub get

echo "==> Installing College FAQ Chatbot (Python) dependencies"
cd /workspace/college-faq-chatbot/backend
chmod +x install_deps.sh
./install_deps.sh

echo "==> Cloud Agent install complete"
