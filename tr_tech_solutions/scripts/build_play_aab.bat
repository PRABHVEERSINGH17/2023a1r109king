@echo off
cd /d "%~dp0\.."

if not exist "android\key.properties" (
  echo Missing android\key.properties
  echo Run scripts\create_keystore.bat first.
  exit /b 1
)

echo Building Play Store Android App Bundle...
flutter clean
flutter pub get
flutter build appbundle --release

echo.
echo DONE.
echo Upload this file to Google Play Console:
echo   build\app\outputs\bundle\release\app-release.aab
explorer build\app\outputs\bundle\release
