# Fix the google_fonts error (do this in VS Code terminal)

You are getting this error because you are on the **old `main` branch**.

Run these commands **exactly**:

```bash
cd 2023a1r109king
git fetch origin
git checkout cursor/fix-vscode-env-error-2b7a
git pull origin cursor/fix-vscode-env-error-2b7a
cd tr_tech_solutions
flutter clean
flutter pub get
flutter run -d chrome
```

Or press **F5** → **TR Tech (Chrome)**

## How to confirm the fix loaded

Open `tr_tech_solutions/pubspec.yaml` — it must **NOT** contain `google_fonts`.

Open `tr_tech_solutions/lib/core/theme/app_theme.dart` — it must **NOT** contain `GoogleFonts`.

If you still see `google_fonts` in those files, you are still on the wrong branch.
