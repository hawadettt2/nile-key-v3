#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/check-env.sh

echo "[nile-key] Checking development environment..."

commands=(git curl wget python node npm bench mariadb redis-cli)

for cmd in "${commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[ok] $cmd -> $(command -v "$cmd")"
  else
    echo "[missing] $cmd"
  fi
done

if command -v python >/dev/null 2>&1; then
  python --version || true
fi

if command -v node >/dev/null 2>&1; then
  node --version || true
fi

if command -v bench >/dev/null 2>&1; then
  bench --version || true
fi

if command -v redis-cli >/dev/null 2>&1; then
  redis-cli ping || true
fi

if command -v mariadb >/dev/null 2>&1; then
  mariadb --version || true
fi

echo "[done] Review missing commands before continuing."
