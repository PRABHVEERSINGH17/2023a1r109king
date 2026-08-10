# Build APK — College FAQ Chatbot (Android)

The Android app works **offline** — no Python server needed. All FAQs and ML matching run on your phone.

---

## Build APK on your laptop (recommended)

### Step 1 — Install Flutter

**Linux:**
```bash
sudo snap install flutter --classic
flutter doctor
```

**Windows:** Download from https://docs.flutter.dev/get-started/install/windows

**Mac:**
```bash
brew install flutter
```

### Step 2 — Accept Android licenses

```bash
flutter doctor --android-licenses
```
Type `y` for all prompts.

### Step 3 — Build APK

```bash
cd ~/Desktop/minor/2023a1r109king-main/college-faq-chatbot/mobile
flutter pub get
flutter build apk --release
```

### Step 4 — Get your APK file

After build completes, APK is here:

```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

Copy to phone and install (enable **Install from unknown sources** in Android settings).

---

## Quick debug APK (faster build, larger file)

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

---

## Install APK on phone

1. Copy `app-release.apk` to phone (USB, WhatsApp, Google Drive)
2. Open the file on phone
3. Tap **Install**
4. Open **College FAQ Chatbot** app

---

## App features (same as web version)

- 28 college FAQs in 8 categories
- TF-IDF + cosine similarity (ML matching on device)
- Chat UI with categories drawer
- Works **without internet** after install
- Confidence score on each answer

---

## Customize college name

Edit: `mobile/assets/faq_data.json`  
Then rebuild: `flutter build apk --release`

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `flutter: command not found` | Install Flutter SDK |
| Android licenses | `flutter doctor --android-licenses` |
| Build fails | Run `flutter doctor` and fix red items |
| Can't install APK | Settings → Security → Allow unknown sources |

---

## Project structure

```
mobile/
├── lib/                  # Dart source code
│   ├── main.dart
│   ├── services/chatbot_service.dart   # ML engine
│   └── screens/chat_screen.dart        # Chat UI
├── assets/faq_data.json  # FAQ database
└── android/              # Android config
```
