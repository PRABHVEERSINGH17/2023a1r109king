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
flutter build apk --release
```

Copy to phone:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Install → open → **Continue with Demo Mode**.

## What you can do

1. Open **Clients**
2. Tap **Add Client**
3. Client hub opens with linked invoice, payment, service, project, lead, ticket
4. Check **Invoices / Payments / Services** — records appear there too

## If something looks empty

**Settings → Reset Demo Workspace**
