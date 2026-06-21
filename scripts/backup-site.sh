#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   SITE_NAME=nile-key.test BENCH_DIR=~/frappe/nile-key-bench BACKUP_DIR=~/nile-key-backups ./scripts/backup-site.sh

SITE_NAME="${SITE_NAME:-nile-key.test}"
BENCH_DIR="${BENCH_DIR:-$HOME/frappe/nile-key-bench}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/nile-key-backups/$SITE_NAME}"

if [ ! -d "$BENCH_DIR" ]; then
  echo "[error] Bench directory not found: $BENCH_DIR" >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR"
cd "$BENCH_DIR"

echo "[nile-key] Creating backup for site: $SITE_NAME"
bench --site "$SITE_NAME" backup --with-files

FRAPPE_BACKUP_DIR="sites/$SITE_NAME/private/backups"

if [ ! -d "$FRAPPE_BACKUP_DIR" ]; then
  echo "[error] Backup directory not found: $FRAPPE_BACKUP_DIR" >&2
  exit 1
fi

cp -n "$FRAPPE_BACKUP_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true

echo "[ok] Backup files copied to: $BACKUP_DIR"
echo "[next] Move this backup to external encrypted storage outside Deep Freeze."
