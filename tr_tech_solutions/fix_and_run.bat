@echo off
echo Fixing TR Tech Solutions project...
cd /d "%~dp0"
flutter clean
flutter pub get
echo.
echo DONE. Now press F5 in VS Code or run: flutter run -d chrome
pause
