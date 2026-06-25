#!/bin/bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv global 3.7.17

# Remove old bench
rm -rf frappe-bench

# Initialize bench without getting apps from GitHub
bench init frappe-bench --python "$HOME/.pyenv/versions/3.7.17/bin/python" --skip-apps

# Use local frappe source from project
cd frappe-bench
ln -s /mnt/f/nilekey/nile-key-project/nile-key-v3/erpnext apps/erpnext

# Install requirements
bench setup requirements

echo "Setup complete!"