#!/usr/bin/env bash
# Build a release APK with clear diagnostics for common SDK/Gradle failures.
set -euo pipefail
cd "$(dirname "$0")/.."

RED=$'\033[31m'
GRN=$'\033[32m'
YLW=$'\033[33m'
NC=$'\033[0m'

echo "==> TR Tech Solutions — APK build"
echo

if ! command -v flutter >/dev/null 2>&1; then
  echo "${RED}Flutter not found in PATH.${NC}"
  echo "Install Flutter, then reopen the terminal."
  exit 1
fi

JAVA_VER="$(java -version 2>&1 | head -n1 || true)"
echo "Java: $JAVA_VER"
if ! java -version 2>&1 | grep -Eq '"1[7-9]|"2[0-9]'; then
  echo "${RED}Java 17+ is required for this Android Gradle Plugin.${NC}"
  echo "Ubuntu: sudo apt install openjdk-17-jdk"
  echo "Then:   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
  exit 1
fi

# Resolve Android SDK location (Flutter / android/local.properties / env).
SDK_DIR="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "${SDK_DIR}" && -f android/local.properties ]]; then
  SDK_DIR="$(grep -E '^sdk\.dir=' android/local.properties | head -1 | cut -d= -f2- | tr -d '\r' | sed 's/\\\\/\//g')"
fi
if [[ -z "${SDK_DIR}" ]]; then
  SDK_DIR="$(flutter doctor -v 2>/dev/null | awk -F'Android SDK at ' '/Android SDK at /{print $2; exit}')"
fi

echo "Android SDK: ${SDK_DIR:-"(not found)"}"
echo "Flutter: $(flutter --version 2>/dev/null | head -1)"
echo

if [[ -z "${SDK_DIR}" || ! -d "${SDK_DIR}" ]]; then
  echo "${RED}Android SDK not found.${NC}"
  echo "Install Android Studio OR command-line tools, then set:"
  echo "  export ANDROID_HOME=\$HOME/Android/Sdk"
  echo "  export ANDROID_SDK_ROOT=\$ANDROID_HOME"
  exit 1
fi

export ANDROID_HOME="$SDK_DIR"
export ANDROID_SDK_ROOT="$SDK_DIR"

# Warn about incomplete distro packages (common on Ubuntu).
if [[ "$SDK_DIR" == "/usr/lib/android-sdk" ]]; then
  echo "${YLW}Warning: /usr/lib/android-sdk is often incomplete (apt package).${NC}"
  echo "If this build fails, install a full SDK via Android Studio, or run:"
  echo "  sudo apt install google-android-cmdline-tools-13.0-installer"
  echo "  yes | sdkmanager --licenses"
  echo "  sdkmanager \"platform-tools\" \"platforms;android-34\" \"build-tools;34.0.0\" \"ndk;27.0.12077973\""
  echo
fi

find_sdkmanager() {
  local c
  for c in \
    "$SDK_DIR/cmdline-tools/latest/bin/sdkmanager" \
    "$SDK_DIR/cmdline-tools/bin/sdkmanager" \
    "$(command -v sdkmanager 2>/dev/null || true)"; do
    if [[ -n "$c" && -x "$c" ]]; then
      echo "$c"
      return 0
    fi
  done
  # Debian/Ubuntu sometimes nests a versioned folder.
  local hit
  hit="$(find "$SDK_DIR/cmdline-tools" -type f -name sdkmanager 2>/dev/null | head -1 || true)"
  if [[ -n "$hit" && -x "$hit" ]]; then
    echo "$hit"
    return 0
  fi
  return 1
}

need_install=0
[[ -d "$SDK_DIR/platforms/android-34" ]] || need_install=1
[[ -d "$SDK_DIR/build-tools/34.0.0" || -d "$SDK_DIR/build-tools/33.0.1" ]] || need_install=1

if [[ "$need_install" -eq 1 ]]; then
  echo "${YLW}Missing platform/build-tools for API 34 — trying sdkmanager…${NC}"
  if SM="$(find_sdkmanager)"; then
    yes | "$SM" --sdk_root="$SDK_DIR" --licenses >/tmp/trtech-sdk-licenses.log 2>&1 || true
    "$SM" --sdk_root="$SDK_DIR" \
      "platform-tools" \
      "platforms;android-34" \
      "build-tools;34.0.0" \
      "ndk;27.0.12077973" || {
        echo "${RED}sdkmanager could not install required packages.${NC}"
        echo "Install Android Studio → SDK Manager → SDK Platforms (34) + SDK Tools (NDK)."
        exit 1
      }
  else
    echo "${RED}sdkmanager not found under $SDK_DIR${NC}"
    echo "Install Android cmdline-tools or Android Studio, then re-run."
    exit 1
  fi
fi

# Ensure local.properties points at a real SDK + Flutter.
FLUTTER_SDK="$(dirname "$(dirname "$(command -v flutter)")")"
cat > android/local.properties <<EOF
sdk.dir=${SDK_DIR//\\/\\\\}
flutter.sdk=${FLUTTER_SDK}
EOF

echo "==> flutter pub get"
flutter pub get

echo "==> flutter build apk --release"
set +e
flutter build apk --release
status=$?
set -e

if [[ "$status" -ne 0 ]]; then
  echo
  echo "${RED}Build failed. Re-running Gradle with --stacktrace for details…${NC}"
  (
    cd android
    ./gradlew assembleRelease --stacktrace --info 2>&1 | tee /tmp/trtech-apk-build.log | tail -n 80
  ) || true
  echo
  echo "Full log: /tmp/trtech-apk-build.log"
  echo
  echo "Common fixes:"
  echo "  1) Java 17+:  sudo apt install openjdk-17-jdk && export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
  echo "  2) Full SDK:  use Android Studio SDK (not only /usr/lib/android-sdk)"
  echo "  3) Sync branch: git fetch origin && git reset --hard origin/cursor/clickable-dashboard-2b7a"
  echo "  4) Clean:       flutter clean && rm -rf android/.gradle build"
  echo "  5) Or skip local build — download the APK from the live demo page / release folder."
  exit "$status"
fi

mkdir -p release
cp -f build/app/outputs/flutter-apk/app-release.apk release/TR-Tech-Solutions.apk
echo
echo "${GRN}APK ready:${NC}"
echo "  release/TR-Tech-Solutions.apk"
ls -lh release/TR-Tech-Solutions.apk
