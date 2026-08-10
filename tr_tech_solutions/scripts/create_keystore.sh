#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p android/keystore

echo "Creating Play Store upload keystore..."
echo "Save the passwords in a password manager. If you lose this keystore, you cannot update the app."
echo

keytool -genkey -v \
  -keystore android/keystore/trtech-upload-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias trtech \
  -dname "CN=TR Technology Solutions, OU=Mobile, O=TR Technology Solutions LLP, L=City, ST=State, C=IN"

read -r -s -p "Enter the same keystore password you just created: " STOREPASS
echo
cp android/key.properties.example android/key.properties
sed -i "s/YOUR_STORE_PASSWORD/${STOREPASS}/g; s/YOUR_KEY_PASSWORD/${STOREPASS}/g" android/key.properties

echo
echo "Created:"
echo "  android/keystore/trtech-upload-key.jks"
echo "  android/key.properties"
echo
echo "NEXT: run ./scripts/build_play_aab.sh"
