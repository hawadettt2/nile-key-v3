#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   SITE_NAME=nile-key.test BENCH_DIR=~/frappe/nile-key-bench ./scripts/run-dev.sh

SITE_NAME="${SITE_NAME:-nile-key.test}"
BENCH_DIR="${BENCH_DIR:-$HOME/frappe/nile-key-bench}"

if [ ! -d "$BENCH_DIR" ]; then
  echo "[error] Bench directory not found: $BENCH_DIR" >&2
  exit 1
fi

cd "$BENCH_DIR"

echo "[nile-key] Starting development server for site: $SITE_NAME"
bench use "$SITE_NAME"
bench start
