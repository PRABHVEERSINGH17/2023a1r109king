# Open in Visual Studio Code

## Quick start

```bash
git clone https://github.com/PRABHVEERSINGH17/2023a1r109king.git
cd 2023a1r109king
git checkout cursor/fix-vscode-env-error-2b7a
code tr_tech_solutions
```

Or: **File → Open Folder…** → select `tr_tech_solutions`

## First time setup

1. Install extensions when prompted: **Dart** + **Flutter**
2. Open VS Code terminal (`Ctrl + `` `) and run:

```bash
flutter pub get
```

3. Press **F5** and choose **TR Tech (Chrome)**

## Supabase config (already set)

Credentials are in:

`assets/supabase.env`

```env
SUPABASE_URL=https://izpxnkovciqjotfbofkc.supabase.co
SUPABASE_ANON_KEY=...
```

No need to create `assets/.env` anymore.

## Login

- Click **Explore Demo Dashboard**, or
- Sign Up / Sign In with your email

## If you get an old error about assets/.env

You are on an old branch. Update:

```bash
git fetch origin
git checkout cursor/fix-vscode-env-error-2b7a
git pull
flutter clean
flutter pub get
flutter run -d chrome
```
