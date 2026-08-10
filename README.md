# TR Technology Solutions — Fully Working CRM

Flutter business CRM for **TR Technology Solutions LLP**.

## Use this branch

```bash
git fetch origin
git checkout cursor/clickable-dashboard-2b7a
git reset --hard origin/cursor/clickable-dashboard-2b7a
cd tr_tech_solutions
```

## Run (recommended — works immediately)

```bash
flutter pub get
flutter run -d chrome
```

On the login screen tap **Continue with Demo Mode**.

That loads a complete working workspace:

- Dashboard KPIs & charts
- Clients (add client → auto-creates lead, project, invoice, payment, service, ticket)
- Leads, Services, Projects
- Invoices, Payments, Expenses, Tickets
- Reports & Settings

Demo login also works: `admin@trtechsolutions.com` / `demo1234`

## Build Android APK

```bash
cd tr_tech_solutions
flutter pub get
flutter build apk --release
```

Install:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Requires **Gradle 8.11.1** (already set on this branch).

## Host web online

```bash
flutter build web --release
```

Upload `build/web` to [Netlify Drop](https://app.netlify.com/drop).

See `tr_tech_solutions/HOSTING.md`.

## Live Supabase (optional)

1. Put keys in `tr_tech_solutions/assets/supabase.env`
2. Run `supabase/schema.sql` then `supabase/fix_missing.sql` in Supabase SQL Editor
3. Sign up / sign in with a real account

If the live backend errors, open **Settings → Switch to Demo Mode** for the full sample CRM.

## App folder

```text
tr_tech_solutions/
```
