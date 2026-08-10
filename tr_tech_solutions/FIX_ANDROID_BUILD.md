# Fix Android APK build failures

If you see something like:

```text
BUILD FAILED in 1s
Running Gradle task 'assembleRelease'... failed
Using Android SDK: /usr/lib/android-sdk
```

your SDK/Java setup is incomplete — not the Dart app code.

## Fastest fix (recommended)

```bash
cd ~/Downloads/tr_App/2023a1r109king
git fetch origin
git reset --hard origin/cursor/clickable-dashboard-2b7a
cd tr_tech_solutions
chmod +x scripts/build_apk.sh
./scripts/build_apk.sh
```

That script checks Java 17, SDK platforms/build-tools, and prints the real Gradle stacktrace if it still fails.

## Requirements

1. **Java 17+** (required by Android Gradle Plugin 8.7)
   ```bash
   sudo apt install openjdk-17-jdk
   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
   java -version
   ```
2. **A complete Android SDK** (API 34 + build-tools).  
   Ubuntu’s `/usr/lib/android-sdk` is often a stub and fails quickly.
3. **This branch** (Gradle **8.11.1** + AGP **8.7.3**):
   `cursor/clickable-dashboard-2b7a`

## Install a real SDK (Ubuntu)

### Option A — Android Studio (easiest)
1. Install Android Studio
2. SDK Manager → install **Android 14 (API 34)** + **Build-Tools** + **NDK (Side by side)**
3. Point Flutter at it:
   ```bash
   flutter config --android-sdk "$HOME/Android/Sdk"
   export ANDROID_HOME="$HOME/Android/Sdk"
   export ANDROID_SDK_ROOT="$ANDROID_HOME"
   ```

### Option B — cmdline-tools
```bash
# example locations vary by install method
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;27.0.12077973"
yes | sdkmanager --licenses
```

## Clean rebuild

```bash
cd tr_tech_solutions
flutter clean
rm -rf android/.gradle build
flutter pub get
flutter build apk --release
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Still failing?

Re-run with full logs and share the **first** `* What went wrong:` block:

```bash
cd tr_tech_solutions/android
./gradlew assembleRelease --stacktrace
```

Or skip building on this PC and install the already-built APK from the project’s live demo / `release/` folder when available.
