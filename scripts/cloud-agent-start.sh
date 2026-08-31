#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/flutter/bin:${PATH}"
if [ -x /usr/local/bin/google-chrome ]; then
  export CHROME_EXECUTABLE=/usr/local/bin/google-chrome
fi

echo "Cloud Agent environment ready."
echo "  TR Tech CRM:    flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 (in tr_tech_solutions/)"
echo "  College FAQ:    uvicorn on port 8000 (see college-faq-chatbot terminal)"
