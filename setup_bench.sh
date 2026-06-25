#!/bin/bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv global 3.7.17

# Remove old bench
rm -rf frappe-bench

# Initialize bench with Python 3.7
bench init frappe-bench --python "$HOME/.pyenv/versions/3.7.17/bin/python"

# Get ERPNext v11
cd frappe-bench
bench get-app erpnext --branch version-11

echo "Setup complete!"