#!/bin/bash
# Nile Export v3 - WSL2 Setup Script

set -e

echo "=== Installing System Dependencies ==="
apt-get update
apt-get install -y \
  git curl wget build-essential \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  mariadb-server mariadb-client libmariadb-dev \
  redis-server redis-tools \
  wkhtmltopdf xvfb libfontconfig \
  python3-dev python3-pip python3-venv

echo "=== Installing pyenv ==="
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

echo "=== Installing Python 3.7.17 ==="
source ~/.bashrc
pyenv install 3.7.17
pyenv global 3.7.17

echo "=== Installing Node.js 10.24.1 ==="
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 10.24.1
nvm use 10.24.1
nvm alias default 10.24.1
npm install -g yarn@1.22.22

echo "=== Installing Frappe Bench ==="
pip3 install --upgrade pip setuptools wheel
pip3 install "frappe-bench==5.14.1"

echo "=== Creating Bench ==="
mkdir -p ~/frappe && cd ~/frappe
bench init --frappe-branch version-11 --python ~/.pyenv/versions/3.7.17/bin/python nile-key-bench
cd nile-key-bench

echo "=== Getting ERPNext ==="
bench get-app erpnext --branch version-11

echo "=== Setup Complete ==="
echo "Next steps:"
echo "1. Copy nile_export app to apps/"
echo "2. bench new-site nile-key.test ..."
echo "3. bench start"