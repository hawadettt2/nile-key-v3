#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   SITE_NAME=nile-key.test \
#   DATABASE=/path/to/database.sql.gz \
#   PUBLIC_FILES=/path/to/public-files.tar \
#   PRIVATE_FILES=/path/to/private-files.tar \
#   BENCH_DIR=~/frappe/nile-key-bench \
#   ./scripts/restore-site.sh

SITE_NAME="${SITE_NAME:-nile-key.test}"
BENCH_DIR="${BENCH_DIR:-$HOME/frappe/nile-key-bench}"
DATABASE="${DATABASE:-}"
PUBLIC_FILES="${PUBLIC_FILES:-}"
PRIVATE_FILES="${PRIVATE_FILES:-}"

if [ -z "$DATABASE" ]; then
  echo "[error] DATABASE path is required." >&2
  exit 1
fi

if [ ! -d "$BENCH_DIR" ]; then
  echo "[error] Bench directory not found: $BENCH_DIR" >&2
  exit 1
fi

cd "$BENCH_DIR"

echo "[nile-key] Restoring site: $SITE_NAME"

if [ -n "$PUBLIC_FILES" ] && [ -n "$PRIVATE_FILES" ]; then
  bench --site "$SITE_NAME" --force restore "$DATABASE" \
    --with-public-files "$PUBLIC_FILES" \
    --with-private-files "$PRIVATE_FILES"
else
  bench --site "$SITE_NAME" --force restore "$DATABASE"
fi

bench --site "$SITE_NAME" migrate
bench --site "$SITE_NAME" clear-cache
bench build

echo "[ok] Restore completed. Start with: bench start"
