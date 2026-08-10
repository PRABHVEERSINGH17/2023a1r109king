# College FAQ Chatbot — Project Report Template

> Fill in [brackets] and submit with your minor project.

---

## 1. Title

**AI-Based College FAQ Chatbot using Natural Language Processing**

---

## 2. Student Details

| Field | Details |
|-------|---------|
| Name | [Your Name] |
| Roll No. | [Your Roll Number] |
| Branch | [CSE / IT / etc.] |
| College | [Your College Name] |
| Guide | [Faculty Name] |

---

## 3. Abstract

This project develops an intelligent FAQ chatbot for college students. The system answers common questions about admissions, fees, examinations, hostel, library, and placements. It uses **TF-IDF (Term Frequency–Inverse Document Frequency)** vectorization and **cosine similarity** to match user queries with the most relevant FAQ from a knowledge base. A web-based chat interface provides an easy-to-use experience for students.

---

## 4. Problem Statement

College administrative offices receive repetitive queries from students regarding admissions, fees, exam schedules, and hostel facilities. A chatbot can provide instant 24/7 answers, reduce staff workload, and improve student experience.

---

## 5. Objectives

1. Build a FAQ knowledge base for college-related queries
2. Implement NLP-based question matching using machine learning
3. Develop a user-friendly web chat interface
4. Evaluate accuracy with sample test queries

---

## 6. System Architecture

```
Student (Browser)
       |
       v
  Web Chat UI (HTML/CSS/JS)
       |
       v
  REST API (FastAPI)
       |
       v
  TF-IDF + Cosine Similarity Engine (scikit-learn)
       |
       v
  FAQ Knowledge Base (JSON)
```

---

## 7. Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Python 3.10+ |
| Web Framework | FastAPI |
| ML Library | scikit-learn |
| Frontend | HTML, CSS, JavaScript |
| Data Storage | JSON file |

---

## 8. Algorithm — TF-IDF + Cosine Similarity

### Step 1: Data Preparation
Each FAQ entry contains a question, answer, and keywords. These are combined into a text corpus.

### Step 2: TF-IDF Vectorization
- **TF (Term Frequency):** How often a word appears in a document
- **IDF (Inverse Document Frequency):** How rare/common a word is across all documents
- Result: Each FAQ is converted to a numerical vector

### Step 3: Query Matching
- User question is converted to the same vector space
- **Cosine similarity** measures angle between query vector and each FAQ vector
- Highest similarity score = best match

### Step 4: Response
- If confidence ≥ 25%, return matched answer
- Otherwise, return fallback message with contact details

---

## 9. Modules

| Module | File | Description |
|--------|------|-------------|
| Chatbot Engine | `backend/app/chatbot.py` | TF-IDF indexing and matching |
| API Server | `backend/app/main.py` | REST endpoints |
| FAQ Database | `backend/data/faq_data.json` | 28 FAQs in 8 categories |
| Web UI | `frontend/` | Chat interface |

---

## 10. Screenshots

[Insert screenshots here:]
1. Chat homepage
2. Sample question and answer with confidence score
3. Category sidebar
4. Test results from `python test_chatbot.py`

---

## 11. Test Results

| # | Question | Matched? | Confidence |
|---|----------|----------|------------|
| 1 | What is the tuition fee? | Yes | ~72% |
| 2 | How do I apply for admission? | Yes | ~65% |
| 3 | When are semester exams? | Yes | ~58% |
| 4 | Library timings? | Yes | ~70% |
| 5 | Random unknown query | No (fallback) | 0% |

Run `python backend/test_chatbot.py` for automated verification.

---

## 12. Advantages

- Instant answers without visiting admin office
- Available 24/7
- Easy to update FAQs via JSON file
- No paid API required
- Lightweight and fast

---

## 13. Limitations

- Works only for pre-defined FAQs
- Cannot handle complex multi-part conversations
- English language only (in current version)
- Synonym matching depends on keywords provided

---

## 14. Future Scope

1. Hindi/regional language support
2. Voice input and output
3. Admin panel to add/edit FAQs without editing JSON
4. Integration with college ERP/database
5. Large Language Model (LLM) for open-ended questions
6. Mobile app (Flutter/React Native)

---

## 15. Conclusion

The College FAQ Chatbot successfully demonstrates the application of NLP and machine learning for solving real-world problems in educational institutions. The TF-IDF approach provides accurate FAQ matching with minimal computational resources, making it suitable for deployment in college environments.

---

## 16. References

1. scikit-learn Documentation — TF-IDF Vectorizer
2. FastAPI Official Documentation
3. "Introduction to Information Retrieval" — Manning, Raghavan, Schütze

---

## 17. Appendix — How to Run

```bash
cd college-faq-chatbot
./run.sh          # Mac/Linux
# OR double-click run.bat on Windows
# Open http://localhost:8000
```
