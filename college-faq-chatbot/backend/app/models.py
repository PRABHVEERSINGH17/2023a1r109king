from pydantic import BaseModel, Field


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=500)


class ChatResponse(BaseModel):
    answer: str
    matched_question: str | None = None
    category: str | None = None
    confidence: float
    suggestions: list[str] = []


class FaqItem(BaseModel):
    id: str
    question: str
    answer: str
    keywords: list[str] = []


class CategoryResponse(BaseModel):
    id: str
    name: str
    icon: str
    faqs: list[FaqItem]


class CollegeInfo(BaseModel):
    college_name: str
    categories: list[CategoryResponse]
