# Android release files

| File | What it is |
|------|------------|
| `TR-Tech-Solutions.apk` | **Install this on your Android phone** |
| `app-release.aab` | Upload to Google Play Console (optional) |

## Install on your phone (no website link)

### Way 1 — USB cable (best)

1. On phone: **Settings → About phone → tap Build number 7 times** (Developer mode)
2. Enable **USB debugging**
3. Plug phone into PC
4. On PC:

```bash
cd tr_tech_solutions
flutter install --release
```

Or copy the APK:

```bash
adb install -r release/TR-Tech-Solutions.apk
```

### Way 2 — Copy the file

1. Copy `TR-Tech-Solutions.apk` to your phone (USB / Bluetooth / Drive)
2. On phone open **Files** → tap the APK
3. Allow **Install unknown apps** if asked
4. Open **TR Tech Solutions**
5. Tap **Continue with Demo Mode**

The app works on your phone as a normal Android application.
