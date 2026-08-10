"""Run: python test_chatbot.py — verifies chatbot works for project demo/viva."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from app.chatbot import CollegeFaqChatbot

TESTS = [
    ("What is the tuition fee?", "annual tuition fee"),
    ("How do I apply for admission?", "admissions.abcit.edu.in"),
    ("When are semester exams?", "November"),
    ("library timings", "8:00 AM"),
    ("placement record", "placement"),
    ("hello", "Welcome"),
    ("xyz random unknown query 12345", "couldn't find"),
]


def run_tests() -> bool:
    bot = CollegeFaqChatbot()
    passed = 0
    failed = 0

    print(f"\nCollege FAQ Chatbot — Test Suite")
    print(f"FAQs loaded: {len(bot.entries)}\n")
    print("-" * 50)

    for question, expected_fragment in TESTS:
        result = bot.chat(question)
        answer = result["answer"].lower()
        ok = expected_fragment.lower() in answer

        status = "PASS" if ok else "FAIL"
        print(f"[{status}] Q: {question[:45]}")
        if ok:
            passed += 1
            if result.get("confidence"):
                print(f"       Confidence: {result['confidence']}")
        else:
            failed += 1
            print(f"       Expected fragment: {expected_fragment}")
            print(f"       Got: {result['answer'][:80]}...")

    print("-" * 50)
    print(f"Results: {passed} passed, {failed} failed\n")

    if failed == 0:
        print("All tests passed! Chatbot is ready for demo.\n")
        return True

    print("Some tests failed. Check faq_data.json or chatbot.py\n")
    return False


if __name__ == "__main__":
    success = run_tests()
    sys.exit(0 if success else 1)
