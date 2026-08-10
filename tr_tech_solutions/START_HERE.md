# START HERE — TR Tech CRM

## Fastest path (working app in minutes)

```bash
cd ~/Downloads/tr_App/2023a1r109king
git fetch origin
git reset --hard origin/cursor/clickable-dashboard-2b7a
cd tr_tech_solutions
flutter pub get
flutter run -d chrome
```

Tap **Continue with Demo Mode**.

## Android phone APK

```bash
cd tr_tech_solutions
chmod +x scripts/build_apk.sh
./scripts/build_apk.sh
```

If Gradle fails (especially with `Using Android SDK: /usr/lib/android-sdk`), see **`FIX_ANDROID_BUILD.md`**.

Copy to phone:

```text
build/app/outputs/flutter-apk/app-release.apk
# or
release/TR-Tech-Solutions.apk
```

Install → open → **Continue with Demo Mode**.

## What you can do

1. Open **Clients**
2. Tap **Add Client**
3. Client hub opens with linked invoice, payment, service, project, lead, ticket
4. Check **Invoices / Payments / Services** — records appear there too
5. Refresh the page — your clients stay (Demo Mode is saved on this device)

## If something looks empty

**Settings → Reset Demo Workspace**
