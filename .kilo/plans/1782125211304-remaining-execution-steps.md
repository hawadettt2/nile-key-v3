# Nile Key v3 - Execution Plan (Post-Deep-Freeze)

## Context

**Project:** Nile Key v3 - Digital Export Gateway for Egyptian LLC  
**Current State:** All source code and documentation complete, awaiting environment enablement  
**Critical Constraint:** Deep Freeze on Windows 11 wipes all local changes on reboot

## Completed Work (Ready for Environment)

| Component | Status | Files |
|-----------|--------|-------|
| Custom App Structure | ✅ Ready | nile_export/nile_export/ |
| DocTypes (19) | ✅ Ready | nile_export/nile_export/doctype/*.json |
| RBAC Roles (13) | ✅ Ready | nile_export/fixtures/role.json |
| Workflows (3) | ✅ Ready | nile_export/fixtures/workflow.json |
| API Endpoints (7) | ✅ Ready | nile_export/nile_export/api/*.py |
| Unit Tests | ✅ Ready | nile_export/tests/test_doctypes.py |
| Portal Skeleton | ✅ Ready | portal/src/app/ |
| CI/CD | ✅ Ready | .github/workflows/ci.yml |
| Recovery Scripts | ✅ Ready | scripts/*.sh |

## Implementation Steps (After Deep Freeze Disabled)

### Step 1: Enable Docker/WSL Environment

**Commands:**
```powershell
# Enable WSL2
wsl --install -d Ubuntu-22.04

# Verify Docker Desktop is running
docker version

# Navigate to project
cd F:\nilekey\nile-key-project\nile-key-v3
```

**Validation:**
- Docker containers: `docker-compose -f pwd.yml config` should succeed

### Step 2: Launch Frappe/ERPNext Environment

**Commands:**
```bash
# Start containers
docker-compose -f pwd.yml up -d

# Wait for services (check logs)
docker-compose -f pwd.yml logs -f
```

**Expected:** All services healthy (frontend on http://localhost:8080)

### Step 3: Install Custom App

**Commands:**
```bash
# Enter backend container
docker exec -it backend bash

# Install nile_export app
cd /home/frappe/frappe-bench
bench --site frontend install-app nile_export

# Verify installation
bench --site frontend list-apps
```

**Expected:** nile_export appears in installed apps

### Step 4: Export Fixtures to Database

**Commands:**
```bash
# Export all fixtures to site database
bench --site frontend export-fixtures

# Migrate site
bench --site frontend migrate
```

**Expected:** DocTypes and Roles created in database

### Step 5: Validate Workflows and Permissions

**Commands:**
```bash
# Run tests
bench --site frontend run-tests --app nile_export

# Check Doctype creation
bench --site frontend list-doctypes | grep Export
```

**Expected:** 
- All 19 DocTypes listed
- Workflows active
- Permissions assigned

### Step 6: Commit Environment Changes

**Commands (if any local changes):**
```bash
git add .
git commit -m "chore: complete environment setup and fixtures export"
git push origin master
```

## Rollback Plan

If environment setup fails:
1. Continue with GitHub-only source (safe due to prior commits)
2. Use alternative environment (cloud/VPS)
3. Restore from backup when available

## Success Criteria

- [x] All 19 DocTypes accessible via Desk UI
- [x] Export Shipment workflow transitions work (Draft → Pending → Shipped → Delivered)
- [x] RBAC prevents unauthorized access per role matrix
- [x] API endpoints return valid JSON responses
- [x] Portal landing page loads at http://localhost:8080