"""TF-IDF based FAQ chatbot engine for college queries."""

from __future__ import annotations

import json
import re
from pathlib import Path

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

DATA_PATH = Path(__file__).resolve().parent.parent / "data" / "faq_data.json"
CONFIDENCE_THRESHOLD = 0.25

FALLBACK_RESPONSE = (
    "I'm sorry, I couldn't find a specific answer to that question. "
    "Please try rephrasing, pick a suggested question below, or contact "
    "the college office at info@abcit.edu.in or call +91-20-12345678."
)


def _normalize(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^\w\s]", " ", text)
    return re.sub(r"\s+", " ", text)


class CollegeFaqChatbot:
    def __init__(self, data_path: Path = DATA_PATH) -> None:
        self.data_path = data_path
        self.college_name = ""
        self.categories: list[dict] = []
        self.entries: list[dict] = []
        self.vectorizer: TfidfVectorizer | None = None
        self.tfidf_matrix = None
        self._load_data()
        self._build_index()

    def _load_data(self) -> None:
        with open(self.data_path, encoding="utf-8") as f:
            data = json.load(f)

        self.college_name = data.get("college_name", "College")
        self.categories = data.get("categories", [])
        self.entries = []

        for category in self.categories:
            for faq in category.get("faqs", []):
                keywords = " ".join(faq.get("keywords", []))
                corpus_text = f"{faq['question']} {keywords}"
                self.entries.append(
                    {
                        "id": faq["id"],
                        "question": faq["question"],
                        "answer": faq["answer"],
                        "category_id": category["id"],
                        "category_name": category["name"],
                        "corpus_text": _normalize(corpus_text),
                    }
                )

    def _build_index(self) -> None:
        if not self.entries:
            return

        corpus = [entry["corpus_text"] for entry in self.entries]
        self.vectorizer = TfidfVectorizer(
            ngram_range=(1, 2),
            stop_words="english",
            min_df=1,
        )
        self.tfidf_matrix = self.vectorizer.fit_transform(corpus)

    def get_college_info(self) -> dict:
        return {
            "college_name": self.college_name,
            "categories": self.categories,
        }

    def get_suggested_questions(self, limit: int = 8) -> list[str]:
        questions = [entry["question"] for entry in self.entries]
        return questions[:limit]

    def get_questions_by_category(self, category_id: str) -> list[str]:
        return [
            entry["question"]
            for entry in self.entries
            if entry["category_id"] == category_id
        ]

    def chat(self, user_message: str) -> dict:
        normalized = _normalize(user_message)

        if not normalized:
            return self._fallback()

        greetings = {
            "hi",
            "hello",
            "hey",
            "good morning",
            "good afternoon",
            "good evening",
            "namaste",
        }
        if normalized in greetings or normalized.startswith(
            ("hi ", "hello ", "hey ")
        ):
            return {
                "answer": (
                    f"Hello! Welcome to {self.college_name} FAQ Assistant. "
                    "I can help you with admissions, fees, exams, hostel, "
                    "placements, and more. What would you like to know?"
                ),
                "matched_question": None,
                "category": None,
                "confidence": 1.0,
                "suggestions": self.get_suggested_questions(5),
            }

        if self.vectorizer is None or self.tfidf_matrix is None:
            return self._fallback()

        query_vector = self.vectorizer.transform([normalized])
        similarities = cosine_similarity(query_vector, self.tfidf_matrix)[0]
        best_idx = int(similarities.argmax())
        best_score = float(similarities[best_idx])

        if best_score < CONFIDENCE_THRESHOLD:
            return self._fallback()

        match = self.entries[best_idx]
        top_indices = similarities.argsort()[-4:][::-1]
        suggestions = [
            self.entries[i]["question"]
            for i in top_indices
            if i != best_idx and similarities[i] >= CONFIDENCE_THRESHOLD * 0.5
        ][:3]

        return {
            "answer": match["answer"],
            "matched_question": match["question"],
            "category": match["category_name"],
            "confidence": round(best_score, 3),
            "suggestions": suggestions,
        }

    def _fallback(self) -> dict:
        return {
            "answer": FALLBACK_RESPONSE,
            "matched_question": None,
            "category": None,
            "confidence": 0.0,
            "suggestions": self.get_suggested_questions(5),
        }
