#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   BENCH_DIR=~/frappe/nile-key-bench \
#   PYTHON_BIN="$HOME/.pyenv/versions/3.7.17/bin/python" \
#   REPO_DIR=~/projects/nile-key-v3 \
#   FORCE_REPLACE_ERPNEXT=1 \
#   ./scripts/init-bench.sh

BENCH_DIR="${BENCH_DIR:-$HOME/frappe/nile-key-bench}"
FRAPPE_BRANCH="${FRAPPE_BRANCH:-version-11}"
ERPNEXT_BRANCH="${ERPNEXT_BRANCH:-version-11}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
FORCE_REPLACE_ERPNEXT="${FORCE_REPLACE_ERPNEXT:-0}"

if [ ! -d "$REPO_DIR" ]; then
  echo "[error] Repository directory not found: $REPO_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$BENCH_DIR")"

if [ ! -d "$BENCH_DIR" ]; then
  echo "[nile-key] Initializing bench at: $BENCH_DIR"
  bench init \
    --frappe-branch "$FRAPPE_BRANCH" \
    --python "$PYTHON_BIN" \
    "$BENCH_DIR"
else
  echo "[ok] Bench directory already exists: $BENCH_DIR"
fi

cd "$BENCH_DIR"

if [ ! -d apps/frappe ]; then
  echo "[error] Frappe app not found inside $BENCH_DIR/apps." >&2
  echo "[error] Run bench init first or fix BENCH_DIR." >&2
  exit 1
fi

if [ ! -d apps/erpnext ]; then
  echo "[nile-key] Getting ERPNext branch: $ERPNEXT_BRANCH"
  bench get-app erpnext --branch "$ERPNEXT_BRANCH"
fi

if [ -d apps/erpnext ]; then
  if [ "$FORCE_REPLACE_ERPNEXT" = "1" ]; then
    echo "[nile-key] Replacing apps/erpnext with local repository copy."
    rsync -a --delete --exclude='.git' "$REPO_DIR/" apps/erpnext/
  else
    echo "[warn] apps/erpnext already exists. Set FORCE_REPLACE_ERPNEXT=1 to replace it with this repository."
  fi
else
  echo "[error] apps/erpnext not found after bench get-app." >&2
  exit 1
fi

echo "[nile-key] Installing Python and Node requirements..."
bench setup requirements
bench build

echo "[ok] Bench initialized."
echo "[next] Create a site with bench new-site, then restore a backup if available."
