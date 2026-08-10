# Host TR Tech Solutions live (Flutter Web)

This app can run in a browser and be hosted on the internet.

## Quick start (on your PC)

### 1. Install Flutter
https://docs.flutter.dev/get-started/install

### 2. Get this branch

```bash
git clone https://github.com/PRABHVEERSINGH17/2023a1r109king.git
cd 2023a1r109king
git checkout cursor/clickable-dashboard-2b7a
cd tr_tech_solutions
```

### 3. Run locally (live preview)

```bash
flutter pub get
flutter run -d chrome
```

Login with **Continue with Demo Mode**.

---

## Host online (recommended: Netlify Drop — easiest)

### Build the website

```bash
cd tr_tech_solutions
chmod +x scripts/build_web.sh
./scripts/build_web.sh
```

This creates the folder: `tr_tech_solutions/build/web`

### Deploy with Netlify Drop (no CLI needed)

1. Open https://app.netlify.com/drop
2. Drag and drop the **`build/web`** folder
3. Netlify gives you a live URL like `https://something.netlify.app`

Done — share that link.

---

## Option B — Netlify CLI

```bash
npm install -g netlify-cli
cd tr_tech_solutions
./scripts/build_web.sh
netlify deploy --prod --dir=build/web
```

`netlify.toml` is already included in this project.

---

## Option C — Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
cd tr_tech_solutions
firebase init hosting
# Set public directory to: build/web
# Configure as single-page app: Yes
./scripts/build_web.sh
firebase deploy --only hosting
```

---

## Option D — GitHub Pages

```bash
cd tr_tech_solutions
flutter build web --release --base-href "/2023a1r109king/"
# Then upload build/web contents to the gh-pages branch
# (repo name must match the base-href path)
```

---

## Android phone (APK — mobile app)

### Build on your PC

```bash
git checkout cursor/clickable-dashboard-2b7a
cd tr_tech_solutions
flutter pub get
flutter build apk --release
```

APK file:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Or:

```bash
chmod +x scripts/build_apk.sh
./scripts/build_apk.sh
# → release/TR-Tech-Solutions.apk
```

### Install on phone

1. Copy the APK to your Android phone (USB, Drive, or download link)
2. Open the APK
3. Allow **Install unknown apps** for Files/Chrome
4. Install → Open → tap **Continue with Demo Mode**

Requires Android 6.0+.

Or use the Play Store packaging notes in `PLAY_STORE.md`.

---

## After hosting

1. Open your live URL
2. Tap **Continue with Demo Mode**
3. Dashboard, Clients, Invoices, Reports all work with sample data

Supabase keys are already in `assets/supabase.env` for this project.
