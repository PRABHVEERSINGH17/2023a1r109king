# Open this project in Visual Studio Code

## Fix for "No file or variants found for asset: assets/.env"

This is fixed. The app now uses `assets/supabase.env` (committed with your Supabase keys).

## Steps

1. Pull latest code:
```bash
git clone https://github.com/PRABHVEERSINGH17/2023a1r109king.git
cd 2023a1r109king
git checkout cursor/tr-tech-demo-mode-2b7a
git pull
code tr_tech_solutions
```

2. In VS Code install **Dart** + **Flutter** extensions

3. In terminal:
```bash
flutter pub get
flutter run -d chrome
```

Or press **F5** → **TR Tech (Chrome)**

4. On login click **Explore Demo Dashboard** or Sign Up with your email

## If you still see CardTheme errors

Your Flutter SDK may be newer. Run:
```bash
flutter --version
flutter upgrade
```
Then in `lib/core/theme/app_theme.dart` change `CardTheme(` to `CardThemeData(` if VS Code suggests it.
