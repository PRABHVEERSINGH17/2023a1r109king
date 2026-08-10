#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/backend"

if ! python3 -m venv --help >/dev/null 2>&1; then
  echo ""
  echo "  ERROR: python3-venv is not installed."
  echo "  Run: sudo apt update && sudo apt install -y python3-venv python3-pip"
  echo ""
  exit 1
fi

chmod +x install_deps.sh
./install_deps.sh

source .venv/bin/activate

echo ""
echo "  College FAQ Chatbot is starting..."
echo "  Open http://localhost:8000 in your browser"
echo "  Press Ctrl+C to stop"
echo ""

python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
