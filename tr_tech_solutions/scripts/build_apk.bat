@echo off
cd /d "%~dp0\.."
echo Building release APK...
flutter clean
flutter pub get
flutter build apk --release
if not exist release mkdir release
copy /Y build\app\outputs\flutter-apk\app-release.apk release\TR-Tech-Solutions.apk
echo.
echo APK ready:
echo   release\TR-Tech-Solutions.apk
explorer release
