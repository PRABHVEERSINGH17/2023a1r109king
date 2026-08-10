# TR Technology Solutions LLP

Flutter + Supabase business management app.

## Important

Use this branch (not `main`):

```bash
git fetch origin
git checkout cursor/clickable-dashboard-2b7a
cd tr_tech_solutions
flutter pub get
flutter run -d chrome
```

On login, tap **Continue with Demo Mode**  
(or `admin@trtechsolutions.com` / `demo1234`)

## What works now

- Modern teal UI
- Add Client → auto-creates lead, project, invoice, payment, service, ticket
- Open a client hub to see everything linked

## App folder

```text
tr_tech_solutions/
```

## Host online

```bash
cd tr_tech_solutions
flutter build web --release
# then drag build/web to https://app.netlify.com/drop
```

More: `tr_tech_solutions/HOSTING.md`
