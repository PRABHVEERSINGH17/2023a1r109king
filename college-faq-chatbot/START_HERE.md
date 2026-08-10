# START HERE — College FAQ Chatbot

## What you got

A **complete, ready-to-run** college FAQ chatbot with:
- Chat web app (open in browser)
- AI/ML backend (TF-IDF + NLP)
- 28 pre-loaded college FAQs
- Project report outline

---

## Run in 3 steps

### Windows

1. Install [Python 3.10+](https://www.python.org/downloads/) — check **"Add Python to PATH"** during install
2. Double-click **`run.bat`**
3. Open **http://localhost:8000** in Chrome/Edge

### Mac / Linux

```bash
cd college-faq-chatbot
chmod +x run.sh
./run.sh
```

Open **http://localhost:8000**

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

Edit this file: **`backend/data/faq_data.json`**

1. Change `"college_name"` at the top
2. Edit questions/answers under each category
3. Restart the app (`run.bat` or `run.sh`)

---

## Run automated tests (for viva/demo)

```bash
cd college-faq-chatbot/backend
pip install -r requirements.txt
python test_chatbot.py
```

You should see: **All tests passed!**

---

## Project files for college submission

| File | Use |
|------|-----|
| `README.md` | Technical documentation |
| `PROJECT_REPORT.md` | Copy into your report (fill your name/college) |
| `backend/app/chatbot.py` | ML algorithm code |
| `frontend/` | Web UI screenshots for report |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `python not found` | Install Python and add to PATH |
| `pip not found` | Run `python -m pip install -r requirements.txt` |
| Port 8000 in use | Close other apps or change port in `run.bat`/`run.sh` |
| Page not loading | Wait 5 sec after starting, then refresh browser |

---

## Need help?

Read full docs in `README.md`
