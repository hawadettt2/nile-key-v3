# Nile Key v3 - Development Commands

## Environment Setup (Windows PowerShell)

```powershell
# Navigate to project
cd F:\nilekey\nile-key-project\nile-key-v3

# Start containers
docker-compose -f pwd.yml up -d

# Check services
docker-compose -f pwd.yml logs -f
```

## App Installation

```bash
# Enter backend container
docker exec -it nile-key-v3-backend-1 bash

# Install nile_export app
cd /home/frappe/frappe-bench
bench --site frontend install-app nile_export

# Verify installation
bench --site frontend list-apps
```

## Fixtures & Migration

```bash
# Export fixtures to database (run inside container)
cd /home/frappe/frappe-bench
bench --site frontend export-fixtures

# Migrate site
bench --site frontend migrate
```

## Testing

```bash
# Enable tests
bench --site frontend set-config allow_tests true

# Run tests
bench --site frontend run-tests --app nile_export
```

## File Synchronization (Windows Host to Container)

```powershell
# Copy updated files to container
docker cp F:\nilekey\nile-key-project\nile-key-v3\nile_export\nile_export\ nile-key-v3-backend-1:/home/frappe/frappe-bench/apps/nile_export/nile_export/

# Sync doctypes
docker exec nile-key-v3-backend-1 python -c "
import frappe
import os
os.chdir('/home/frappe/frappe-bench/sites')
frappe.init(site='frontend', sites_path='/home/frappe/frappe-bench/sites')
frappe.connect()
from frappe.model.sync import sync_for
sync_for('nile_export', force=True)
frappe.destroy()
"
```

## Verification

```bash
# Check all nile_export doctypes
docker exec nile-key-v3-backend-1 python -c "
import frappe
frappe.init(site='frontend', sites_path='/home/frappe/frappe-bench/sites')
frappe.connect()
print('Doctypes:', frappe.db.count('DocType', {'module': 'nile_export'}))
print('Workflows:', len(frappe.db.get_all('Workflow', fields=['name'])))
frappe.destroy()
"
```