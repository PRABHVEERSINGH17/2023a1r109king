# TR Tech Solutions — Android APK

## Built APK

Release APK path:

```
tr_tech_solutions/release/TR-Tech-Solutions.apk
```

Size: ~27 MB  
Package ID: `com.trtechsolutions.app`  
Version: `1.0.0` (versionCode 1)

## Install on phone

1. Copy `TR-Tech-Solutions.apk` to your Android phone
2. Open the file
3. Allow **Install unknown apps** if asked
4. Install and open **TR Tech Solutions**
5. Tap **Continue with Demo Mode** or sign in

## Rebuild APK later (VS Code)

```bat
cd tr_tech_solutions
scripts\build_apk.bat
```

Or:

```bash
flutter build apk --release
```

## Note

- This APK is signed with a local upload keystore for testing/sideloading.
- For Play Store, prefer `.aab` via `scripts\build_play_aab.bat` (see `PLAY_STORE.md`).
