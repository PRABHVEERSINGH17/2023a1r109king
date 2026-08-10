#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/backend"
export PATH="$HOME/.local/bin:$PATH"

if python3 -m venv .venv 2>/dev/null; then
  source .venv/bin/activate
  pip install -q -r requirements.txt
else
  echo "Note: python3-venv not available, using system/user Python packages."
  pip install -q -r requirements.txt
fi

echo ""
echo "  College FAQ Chatbot is starting..."
echo "  Open http://localhost:8000 in your browser"
echo ""

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
