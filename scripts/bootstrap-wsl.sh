#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   sudo ./scripts/bootstrap-wsl.sh

echo "[nile-key] Installing base WSL packages..."

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
  git curl wget build-essential \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  mariadb-server mariadb-client libmariadb-dev \
  redis-server redis-tools \
  wkhtmltopdf xvfb libfontconfig

echo "[ok] Base packages installed."
echo "[next] Install Python, Node.js, Yarn, and Bench manually as documented in DEVELOPMENT_SETUP.md."
