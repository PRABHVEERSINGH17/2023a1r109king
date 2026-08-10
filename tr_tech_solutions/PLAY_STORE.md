# Publish TR Tech Solutions on Google Play Store

This guide takes your Flutter app from VS Code to a live Play Store listing.

## What you need

1. A computer with:
   - Flutter SDK
   - Android Studio (or Android SDK + cmdline-tools)
   - Java JDK 17+
2. A Google account
3. Google Play Developer registration (**one-time $25 USD**)  
   https://play.google.com/console/signup

## App identity (already configured)

| Field | Value |
|-------|-------|
| App name | TR Tech Solutions |
| Application ID | `com.trtechsolutions.app` |
| Version | `1.0.0+1` in `pubspec.yaml` (`versionName+versionCode`) |
| Backend | Supabase (`assets/supabase.env`) |

## Step 1 — Pull the Play Store branch

```bash
git fetch origin
git checkout cursor/play-store-release-2b7a
git pull
cd tr_tech_solutions
```

## Step 2 — Create your upload keystore (once)

### Windows (VS Code terminal / CMD)

```bat
scripts\create_keystore.bat
```

### macOS / Linux

```bash
chmod +x scripts/*.sh
./scripts/create_keystore.sh
```

This creates:
- `android/keystore/trtech-upload-key.jks` (**keep forever, back it up**)
- `android/key.properties` (passwords — never commit)

> If you lose the keystore, you cannot publish updates to the same app listing.

## Step 3 — Build the Android App Bundle (.aab)

### Windows

```bat
scripts\build_play_aab.bat
```

### macOS / Linux

```bash
./scripts/build_play_aab.sh
```

Or manually:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output file:

```
build/app/outputs/bundle/release/app-release.aab
```

## Step 4 — Create the app in Play Console

1. Open https://play.google.com/console
2. **Create app**
   - App name: **TR Tech Solutions**
   - Default language: English (or Hindi/English India)
   - App or game: **App**
   - Free/Paid: **Free** (or Paid)
3. Accept declarations

## Step 5 — Store listing (required)

Fill these in Play Console → **Grow → Store presence → Main store listing**:

### Short description (max 80 chars)
```
All-in-one business manager for IT service providers
```

### Full description
```
TR Technology Solutions is a business management platform for IT service companies.

Manage clients, leads, services, projects, invoices, payments, expenses, and support tickets from one dark, modern dashboard.

Features:
• Dashboard with revenue and pipeline insights
• Client and lead management
• Domain/hosting service renewals
• Invoices and payments tracking
• Support ticket workflow
• Works with secure Supabase cloud backend

Built for TR Technology Solutions LLP.
```

### Graphics required
- App icon: 512 x 512 PNG
- Feature graphic: 1024 x 500 PNG
- Phone screenshots: at least 2 (use emulator screenshots)

Tip: run the app, take screenshots of Dashboard, Clients, Invoices.

## Step 6 — Privacy policy (required)

Play Store requires a public privacy policy URL.

1. Edit `store/privacy_policy.md`
2. Host it (GitHub Pages, Google Sites, or your website)
3. Paste the public URL into Play Console → App content → Privacy policy

## Step 7 — App content declarations

In Play Console complete:
- Privacy policy
- Ads (likely **No**)
- Content rating questionnaire
- Target audience
- News app / COVID / Data safety form

### Data safety (important)
Because you use Supabase Auth + user business data, declare:
- Account info (email, name)
- App activity / business data entered by user
- Data is encrypted in transit (HTTPS)
- Users can request deletion (add a support email)

## Step 8 — Upload the AAB

1. Play Console → **Test and release → Production** (or start with **Internal testing**)
2. **Create new release**
3. Upload `app-release.aab`
4. Release notes example:
   ```
   Initial release of TR Tech Solutions business management app.
   ```
5. Review and roll out

**Recommended path:** Internal testing → Closed testing → Production

## Step 9 — Review wait time

Google review often takes from a few hours to several days for first apps.

## Updating the app later

1. Bump version in `pubspec.yaml`, e.g. `1.0.1+2`
2. Rebuild AAB with the **same keystore**
3. Upload new release in Play Console

```yaml
version: 1.0.1+2
```

`+2` is `versionCode` and must always increase.

## Common errors

| Error | Fix |
|-------|-----|
| You need to use a different package name | Change `applicationId` in `android/app/build.gradle` |
| Upload key not configured | Run `create_keystore` and rebuild |
| Missing privacy policy | Host `store/privacy_policy.md` publicly |
| Target API level too low | Update Flutter / Android SDK; Play requires recent `targetSdk` |
| Debuggable / wrong signing | Ensure `key.properties` exists before building |

## Cannot finish from this cloud agent

Publishing requires:
- Your Google Play Developer account
- Your PC with Android SDK to build the `.aab`
- Your private keystore (do not share it)

This repo is prepared so you can complete the upload from VS Code on your machine.
