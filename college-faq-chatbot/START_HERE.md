# START HERE — College FAQ Chatbot

## What you got

A **complete, ready-to-run** college FAQ chatbot with:
- Chat web app (open in browser)
- AI/ML backend (TF-IDF + NLP)
- 28 pre-loaded college FAQs
- Project report outline

---

## Run on Ubuntu / Linux (Web app)

Copy and paste **all commands** in Terminal:

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip unzip wget

cd ~/Desktop/minor
wget -O repo.zip https://github.com/PRABHVEERSINGH17/2023a1r109king/archive/refs/heads/main.zip
unzip -o repo.zip
cd 2023a1r109king-main/college-faq-chatbot
chmod +x run.sh
./run.sh
```

Open **http://localhost:8000** in Chrome/Firefox.

> **Note:** Do NOT use `pip3 install` globally on Ubuntu — the app uses a virtual environment automatically.

---

## Android APK (mobile app — works offline)

### Build on your laptop

```bash
sudo snap install flutter --classic
flutter doctor --android-licenses

cd ~/Desktop/minor/2023a1r109king-main/college-faq-chatbot/mobile
flutter pub get
flutter build apk --release
```

APK path: `mobile/build/app/outputs/flutter-apk/app-release.apk`

Full guide: **`mobile/BUILD_APK.md`**

### Download from GitHub Actions

1. https://github.com/PRABHVEERSINGH17/2023a1r109king/actions
2. Open **Build Android APK** → latest run
3. Download **college-faq-chatbot-apk** artifact
4. Install on Android phone

---

## Run on Windows

1. Install [Python 3.10+](https://www.python.org/downloads/) — check **"Add Python to PATH"**
2. Double-click **`run.bat`**
3. Open **http://localhost:8000**

---

## Manual run (if run.sh fails)

```bash
cd ~/Desktop/minor/2023a1r109king-main/college-faq-chatbot/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

---

## Test the chatbot

Type these in the chat box:

| Question | Expected topic |
|----------|----------------|
| What is the tuition fee? | Fees |
| How do I apply for admission? | Admissions |
| When are semester exams? | Exams |
| Hostel rules? | Hostel |
| Placement record? | Placements |

---

## Change college name & FAQs

Edit: **`backend/data/faq_data.json`**

1. Change `"college_name"` at the top
2. Edit questions/answers under each category
3. Restart the app

---

## Run automated tests (for viva/demo)

```bash
cd college-faq-chatbot/backend
source .venv/bin/activate
python test_chatbot.py
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `externally-managed-environment` | Use `./run.sh` or virtual env — never `sudo pip3 install` |
| `No module named venv` | `sudo apt install python3-venv` |
| `No module named uvicorn` | Activate venv: `source backend/.venv/bin/activate` then `pip install -r requirements.txt` |
| Port 8000 in use | Close other apps or change port in `run.sh` |
| Folder not found | Use `2023a1r109king-main` after ZIP download |

---

## Project files for college submission

| File | Use |
|------|-----|
| `README.md` | Technical documentation |
| `PROJECT_REPORT.md` | Copy into your report |
| `backend/app/chatbot.py` | ML algorithm code |
| `frontend/` | Web UI screenshots |
