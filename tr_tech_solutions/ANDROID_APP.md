# Real Android App — TR Tech Solutions

This is a normal Android application (APK), not a website link.

## Install file (already built)

```text
tr_tech_solutions/release/TR-Tech-Solutions.apk
```

Also available in this Cursor run’s artifacts as `TR-Tech-Solutions.apk`.

## Put it on your phone

### Option A — USB (recommended)

1. Enable **Developer options** on the phone (tap Build number 7 times)
2. Turn on **USB debugging**
3. Connect phone to PC with a cable
4. Run:

```bash
cd ~/Downloads/tr_App/2023a1r109king
git fetch origin
git reset --hard origin/cursor/clickable-dashboard-2b7a
cd tr_tech_solutions
adb install -r release/TR-Tech-Solutions.apk
```

If `adb` is missing, install Android platform-tools, or use Option B.

### Option B — Copy APK to phone

1. Copy `tr_tech_solutions/release/TR-Tech-Solutions.apk` to the phone  
   (USB file transfer, Google Drive, WhatsApp to yourself, etc.)
2. On the phone, open the file
3. Allow install from that source
4. Tap **Install**
5. Open **TR Tech Solutions**

## Use the app

1. Tap **Continue with Demo Mode**
2. Go to **Clients → Add Client**
3. Everything works on-device (demo data is saved on the phone)

To use online cloud accounts later: **Settings → Exit Demo Mode & Go Online**  
(needs Supabase setup — see `GO_ONLINE.md`)

## Rebuild yourself

```bash
cd tr_tech_solutions
chmod +x scripts/build_apk.sh
./scripts/build_apk.sh
```

## Google Play Store (optional)

Use `release/app-release.aab` with a Play Developer account.  
See `PLAY_STORE.md`.
