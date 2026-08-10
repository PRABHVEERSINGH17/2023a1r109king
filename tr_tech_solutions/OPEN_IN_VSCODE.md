# Open this project in Visual Studio Code

## 1. Install required tools

1. [Visual Studio Code](https://code.visualstudio.com/)
2. [Flutter SDK](https://docs.flutter.dev/get-started/install)
3. In VS Code, install extensions: **Dart** and **Flutter**

## 2. Get the code

```bash
git clone https://github.com/PRABHVEERSINGH17/2023a1r109king.git
cd 2023a1r109king
git checkout cursor/clickable-dashboard-2b7a
code tr_tech_solutions
```

## 3. Install packages

In VS Code terminal:

```bash
flutter pub get
```

Supabase keys are already in `assets/supabase.env`.

## 4. Run the app

**Chrome (web):**
```bash
flutter run -d chrome
```

**Or press F5** in VS Code.

## 5. Login

Tap **Continue with Demo Mode**  
(or email `admin@trtechsolutions.com` / password `demo1234`)

## Host online

See **[HOSTING.md](HOSTING.md)** — build web and drag `build/web` to Netlify Drop for a live URL.
