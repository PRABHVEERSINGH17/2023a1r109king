@echo off
setlocal
cd /d "%~dp0\.."

if not exist "android\keystore" mkdir "android\keystore"

echo.
echo Creating Play Store upload keystore...
echo Save the passwords in a password manager. If you lose this keystore, you cannot update the app.
echo.

keytool -genkey -v ^
  -keystore android\keystore\trtech-upload-key.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 ^
  -alias trtech ^
  -dname "CN=TR Technology Solutions, OU=Mobile, O=TR Technology Solutions LLP, L=City, ST=State, C=IN"

if errorlevel 1 (
  echo keytool failed. Make sure Java JDK is installed.
  exit /b 1
)

echo.
set /p STOREPASS=Enter the same keystore password you just created: 
copy /Y android\key.properties.example android\key.properties >nul

powershell -Command "(Get-Content android\key.properties) -replace 'YOUR_STORE_PASSWORD','%STOREPASS%' -replace 'YOUR_KEY_PASSWORD','%STOREPASS%' | Set-Content android\key.properties"

echo.
echo Created:
echo   android\keystore\trtech-upload-key.jks
echo   android\key.properties
echo.
echo NEXT: run scripts\build_play_aab.bat
endlocal
