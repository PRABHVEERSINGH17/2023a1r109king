#!/usr/bin/env bash
# Install Python deps with long timeout + mirror fallback (for slow networks)
set -euo pipefail

PIP_OPTS=(--default-timeout=300 --retries=10 --no-cache-dir)
MIRRORS=(
  "https://pypi.org/simple"
  "https://pypi.tuna.tsinghua.edu.cn/simple"
)

install_with_mirror() {
  local mirror="$1"
  echo "Trying mirror: $mirror"
  pip install "${PIP_OPTS[@]}" -i "$mirror" -r requirements.txt
}

cd "$(dirname "$0")"

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate
pip install "${PIP_OPTS[@]}" --upgrade pip

for mirror in "${MIRRORS[@]}"; do
  if install_with_mirror "$mirror"; then
    echo "Packages installed successfully."
    exit 0
  fi
  echo "Mirror failed, trying next..."
done

echo ""
echo "Installing packages one-by-one (slower but works on bad networks)..."
for pkg in fastapi "uvicorn[standard]" scikit-learn pydantic; do
  echo "Installing $pkg ..."
  pip install "${PIP_OPTS[@]}" "$pkg" || pip install "${PIP_OPTS[@]}" -i "${MIRRORS[1]}" "$pkg"
done

echo "Done."
