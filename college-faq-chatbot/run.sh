#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/backend"

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate
pip install -q -r requirements.txt

echo ""
echo "  College FAQ Chatbot is starting..."
echo "  Open http://localhost:8000 in your browser"
echo ""

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
