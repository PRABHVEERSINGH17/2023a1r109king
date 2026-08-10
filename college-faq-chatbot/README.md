# College FAQ Chatbot

A full-stack **AI/ML college FAQ chatbot** for minor projects. Students can ask questions about admissions, fees, exams, hostel, placements, and more — the bot finds the best matching answer using **TF-IDF + cosine similarity** (NLP/ML).

## Features

- **Smart FAQ matching** — TF-IDF vectorization + cosine similarity (scikit-learn)
- **30+ college FAQs** across 8 categories (admissions, fees, exams, academics, hostel, library, placements, general)
- **Modern chat UI** — dark theme, category sidebar, quick questions, suggestion chips
- **Confidence score** — shows match quality for each answer
- **REST API** — FastAPI backend with `/api/chat`, `/api/college`, `/api/suggestions`
- **Easy to customize** — edit `backend/data/faq_data.json` to add your college's FAQs

## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Python 3.10+, FastAPI |
| ML/NLP | scikit-learn (TF-IDF, cosine similarity) |
| Frontend | HTML, CSS, JavaScript |
| Server | Uvicorn |

## Quick Start

**Read `START_HERE.md` first** — simplest guide for running the app.

### Windows
Double-click **`run.bat`** → open **http://localhost:8000**

### Mac / Linux
```bash
cd college-faq-chatbot
chmod +x run.sh
./run.sh
```

Then open **http://localhost:8000** in your browser.

### Verify it works
```bash
cd college-faq-chatbot/backend
python test_chatbot.py
```

### Manual setup

```bash
cd college-faq-chatbot/backend
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Project Structure

```
college-faq-chatbot/
├── backend/
│   ├── app/
│   │   ├── main.py          # FastAPI routes + static file serving
│   │   ├── chatbot.py       # TF-IDF chatbot engine
│   │   └── models.py        # Pydantic request/response models
│   ├── data/
│   │   └── faq_data.json    # FAQ knowledge base (customize this!)
│   └── requirements.txt
├── frontend/
│   ├── index.html
│   ├── css/style.css
│   └── js/app.js
├── run.sh
└── README.md
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Chat web UI |
| GET | `/api/health` | Health check |
| GET | `/api/college` | College info + all categories/FAQs |
| GET | `/api/suggestions?limit=8` | Suggested starter questions |
| POST | `/api/chat` | Send a message, get an answer |

### Example chat request

```bash
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is the tuition fee?"}'
```

## Customize for Your College

1. Open `backend/data/faq_data.json`
2. Change `college_name` to your college name
3. Edit or add categories and FAQs (each FAQ needs `question`, `answer`, and optional `keywords`)
4. Restart the server

## How the ML Works

1. Each FAQ question + keywords are combined into a text corpus
2. **TF-IDF** converts text into numerical vectors (term frequency–inverse document frequency)
3. User query is vectorized the same way
4. **Cosine similarity** finds the closest FAQ match
5. If similarity ≥ 25%, the answer is returned; otherwise a fallback message is shown

This is a standard **information retrieval** approach used in many FAQ bots and is suitable for college minor project reports.

## Sample Questions to Try

- "What are the admission eligibility criteria?"
- "How much is the annual fee?"
- "When are semester exams?"
- "How do I apply for hostel?"
- "What is the placement record?"
- "Library timings?"

## For Your Project Report

Include:
- Problem statement (reduce repetitive admin queries)
- System architecture diagram (Frontend → API → TF-IDF engine → FAQ DB)
- Algorithm explanation (TF-IDF + cosine similarity)
- Screenshots of the chat UI
- Accuracy testing with 10–15 sample queries
- Future scope (add Hindi support, voice input, admin panel, LLM integration)

## License

Educational use — College Minor Project
