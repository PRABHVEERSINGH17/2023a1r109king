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

To leave demo and use cloud data: **Settings → Exit Demo Mode & Go Online**  
(or login → **Exit Demo — Go Online**). See `tr_tech_solutions/GO_ONLINE.md`.

That loads a complete working workspace:

- Dashboard KPIs & charts
- Clients (add client → auto-creates lead, project, invoice, payment, service, ticket)
- Leads, Services, Projects
- Invoices, Payments, Expenses, Tickets
- Reports & Settings

Demo login also works: `admin@trtechsolutions.com` / `demo1234`

## Android app (real APK — not a website)

Installable app file:

```text
tr_tech_solutions/release/TR-Tech-Solutions.apk
```

```bash
cd tr_tech_solutions
adb install -r release/TR-Tech-Solutions.apk
```

Or copy that APK to your phone and open it. Full steps: `tr_tech_solutions/ANDROID_APP.md`.

## Host web online

```bash
flutter build web --release
```

Upload `build/web` to [Netlify Drop](https://app.netlify.com/drop).

Or open the hosted install page and use **Install app / Add to Home Screen** / download the APK.  
See `tr_tech_solutions/INSTALL_APP.md`.

## Live Supabase (optional)

1. Put keys in `tr_tech_solutions/assets/supabase.env`
2. Run `supabase/schema.sql` then `supabase/fix_missing.sql` in Supabase SQL Editor
3. Sign up / sign in with a real account

### Social login (Google / Apple / LinkedIn)

Buttons are on the login screen. Enable providers once in Supabase — see  
`tr_tech_solutions/SOCIAL_LOGIN.md`.

If the live backend errors, open **Settings → Switch to Demo Mode** for the full sample CRM.

## App folder

```text
tr_tech_solutions/
```
