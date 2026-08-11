# Install TR Tech as an App

You can use this CRM like a real phone/desktop app in two ways.

## Option A — Install from the website (easiest)

1. Open the live app link (shared by the agent / in PR)
2. On **phone**:
   - **Android Chrome**: menu ⋮ → **Install app** / **Add to Home screen**
   - **iPhone Safari**: Share → **Add to Home Screen**
3. On **computer (Chrome)**: install icon in the address bar → **Install**

The app opens full-screen like a normal app (PWA).

## Option B — Android APK file

1. Open the live page → tap **Download Android App**
2. On your phone, open the downloaded `TR-Tech-Solutions.apk`
3. Allow install from browser if asked
4. Open **TR Tech Solutions** → Demo Mode or Go Online

## Build APK yourself

```bash
cd tr_tech_solutions
chmod +x scripts/build_apk.sh
./scripts/build_apk.sh
```

Output: `release/TR-Tech-Solutions.apk`

## Go Online later

After installing, use **Exit Demo — Go Online** and follow `GO_ONLINE.md`.
