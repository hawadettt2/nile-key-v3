#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   SITE_NAME=nile-key.test BENCH_DIR=~/frappe/nile-key-bench ./scripts/sanity-check.sh

SITE_NAME="${SITE_NAME:-nile-key.test}"
BENCH_DIR="${BENCH_DIR:-$HOME/frappe/nile-key-bench}"
RUN_MIGRATE="${RUN_MIGRATE:-0}"

if [ ! -d "$BENCH_DIR" ]; then
  echo "[error] Bench directory not found: $BENCH_DIR" >&2
  exit 1
fi

cd "$BENCH_DIR"

echo "[nile-key] Sanity check for site: $SITE_NAME"

if [ ! -d "sites/$SITE_NAME" ]; then
  echo "[error] Site directory not found: sites/$SITE_NAME" >&2
  exit 1
fi

if command -v redis-cli >/dev/null 2>&1; then
  redis-cli ping || true
else
  echo "[warn] redis-cli not found."
fi

if command -v mariadb >/dev/null 2>&1; then
  mariadb --version || true
else
  echo "[warn] mariadb client not found."
fi

bench doctor || true
bench --site "$SITE_NAME" clear-cache

if [ "$RUN_MIGRATE" = "1" ]; then
  bench --site "$SITE_NAME" migrate --rebuild-website
else
  echo "[skip] migrate skipped. Set RUN_MIGRATE=1 to run migration."
fi

echo "[ok] Sanity check completed."
echo "[next] Run: bench start"
