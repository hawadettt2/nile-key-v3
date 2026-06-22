#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   sudo ./scripts/install-mariadb-redis.sh

echo "[nile-key] Installing MariaDB, Redis, and Frappe PDF dependencies..."

sudo apt update
sudo apt install -y \
  mariadb-server mariadb-client libmariadb-dev \
  redis-server redis-tools \
  wkhtmltopdf xvfb libfontconfig

sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo systemctl enable redis-server
sudo systemctl start redis-server

echo "[ok] MariaDB and Redis services enabled and started."
echo "[next] Create a MariaDB development user inside MariaDB, then run scripts/init-bench.sh."
