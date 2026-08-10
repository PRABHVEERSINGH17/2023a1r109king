# Open this project in Visual Studio Code

## 1. Install required tools

1. [Visual Studio Code](https://code.visualstudio.com/)
2. [Flutter SDK](https://docs.flutter.dev/get-started/install)
3. In VS Code, install these extensions when prompted:
   - **Dart**
   - **Flutter**

## 2. Get the code

### Option A — Clone from GitHub

```bash
git clone https://github.com/PRABHVEERSINGH17/2023a1r109king.git
cd 2023a1r109king
git checkout cursor/tr-tech-demo-mode-2b7a
code tr_tech_solutions
```

### Option B — Open folder already on your PC

In VS Code:

**File → Open Folder…** → select `tr_tech_solutions`

## 3. Add your Supabase keys

Create file `assets/.env` inside `tr_tech_solutions`:

```env
SUPABASE_URL=https://izpxnkovciqjotfbofkc.supabase.co
SUPABASE_ANON_KEY=paste-your-anon-key-here
```

## 4. Install packages

In VS Code terminal (`Ctrl + `` `):

```bash
flutter pub get
```

## 5. Run the app

1. Press **F5**, or
2. Click **Run → Start Debugging**, or
3. Choose **TR Tech (Chrome)** from the Run and Debug panel

Or in terminal:

```bash
flutter run -d chrome
```

## 6. Login

- Click **Explore Demo Dashboard**, or
- Sign up / sign in with your email (Supabase auth)

## Project location

```
tr_tech_solutions/
├── lib/                  ← all Flutter source code
├── supabase/             ← SQL schema files
├── assets/.env           ← your Supabase keys (create this)
├── pubspec.yaml
└── .vscode/              ← VS Code run configs
```
