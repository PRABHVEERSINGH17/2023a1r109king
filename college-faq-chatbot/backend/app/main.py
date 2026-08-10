"""College FAQ Chatbot — FastAPI backend."""

from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from app.chatbot import CollegeFaqChatbot
from app.models import ChatRequest, ChatResponse, CollegeInfo

FRONTEND_DIR = Path(__file__).resolve().parent.parent.parent / "frontend"

app = FastAPI(
    title="College FAQ Chatbot",
    description="AI-powered FAQ assistant for college students",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

chatbot = CollegeFaqChatbot()


@app.get("/api/health")
def health():
    return {"status": "ok", "faqs_loaded": len(chatbot.entries)}


@app.get("/api/college", response_model=CollegeInfo)
def get_college_info():
    return chatbot.get_college_info()


@app.get("/api/suggestions")
def get_suggestions(limit: int = 8):
    return {"suggestions": chatbot.get_suggested_questions(limit)}


@app.post("/api/chat", response_model=ChatResponse)
def chat(request: ChatRequest):
    result = chatbot.chat(request.message)
    return ChatResponse(**result)


if FRONTEND_DIR.exists():
    app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

    @app.get("/")
    def serve_frontend():
        return FileResponse(FRONTEND_DIR / "index.html")
