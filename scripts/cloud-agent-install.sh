#!/usr/bin/env bash
set -euo pipefail

ensure_flutter() {
  if [ -x /opt/flutter/bin/flutter ]; then
    export PATH="/opt/flutter/bin:${PATH}"
    git config --global --add safe.directory /opt/flutter
    return 0
  fi

  echo "==> Installing Flutter SDK to /opt/flutter"
  sudo mkdir -p /opt/flutter
  sudo git clone --depth 1 -b stable https://github.com/flutter/flutter.git /opt/flutter
  sudo chown -R "$(id -u)":"$(id -g)" /opt/flutter
  export PATH="/opt/flutter/bin:${PATH}"
  git config --global --add safe.directory /opt/flutter
  flutter config --enable-web --no-analytics
  flutter precache --web
}

ensure_flutter

if [ -x /usr/local/bin/google-chrome ]; then
  export CHROME_EXECUTABLE=/usr/local/bin/google-chrome
fi

echo "==> Installing TR Tech Solutions (Flutter CRM) dependencies"
cd /workspace/tr_tech_solutions
flutter pub get

echo "==> Installing College FAQ Chatbot (Python) dependencies"
cd /workspace/college-faq-chatbot/backend
chmod +x install_deps.sh
./install_deps.sh

echo "==> Cloud Agent install complete"
