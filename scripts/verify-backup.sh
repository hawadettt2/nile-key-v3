#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${1:-${BACKUP_DIR:-}}"

if [ -z "$BACKUP_DIR" ]; then
  echo "[error] BACKUP_DIR is required." >&2
  echo "[usage] BACKUP_DIR=/path/to/backup ./scripts/verify-backup.sh" >&2
  exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
  echo "[error] Backup directory not found: $BACKUP_DIR" >&2
  exit 1
fi

db_count=$(find "$BACKUP_DIR" -maxdepth 1 -type f \( -name '*.sql.gz' -o -name '*.sql' \) -size +0c | wc -l | tr -d ' ')
public_count=$(find "$BACKUP_DIR" -maxdepth 1 -type f \( -name 'public-files.tar' -o -name 'public-files.tar.gz' \) -size +0c | wc -l | tr -d ' ')
private_count=$(find "$BACKUP_DIR" -maxdepth 1 -type f \( -name 'private-files.tar' -o -name 'private-files.tar.gz' \) -size +0c | wc -l | tr -d ' ')

if [ "$db_count" -eq 0 ]; then
  echo "[error] No non-empty database backup found in $BACKUP_DIR" >&2
  exit 1
fi

echo "[nile-key] Backup verification for: $BACKUP_DIR"
echo "[ok] Database backup files: $db_count"
echo "[ok] Public files backup files: $public_count"
echo "[ok] Private files backup files: $private_count"

while IFS= read -r file; do
  gzip -t "$file"
  echo "[ok] gzip verified: $(basename "$file")"
done < <(find "$BACKUP_DIR" -maxdepth 1 -type f \( -name '*.sql.gz' -o -name 'public-files.tar.gz' -o -name 'private-files.tar.gz' \) -size +0c | sort)

while IFS= read -r file; do
  tar -tf "$file" >/dev/null
  echo "[ok] tar verified: $(basename "$file")"
done < <(find "$BACKUP_DIR" -maxdepth 1 -type f \( -name '*.tar' \) -size +0c | sort)

find "$BACKUP_DIR" -maxdepth 1 -type f -printf '%f %s bytes\n' | sort

echo "[ok] Backup verification completed."
