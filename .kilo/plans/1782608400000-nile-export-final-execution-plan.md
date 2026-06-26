# Nile Export - Final Execution Plan

## Executive Summary
- **Project:** Nile Key v3 - Digital Export Gateway
- **Status:** Deep Freeze removed, ready for implementation
- **Source:** All code in GitHub repository

---

## 1. VERIFIED COMPLETED WORK

| Component | Status | Evidence |
|-----------|--------|----------|
| 19 DocTypes JSON | ✅ Fixed | `"custom": 1` removed, module = "nile_export" |
| RBAC Roles (13) | ✅ Ready | `nile_export/fixtures/role.json` |
| Workflows (3) | ✅ Ready | `nile_export/fixtures/workflow.json` |
| API Endpoints (7) | ✅ Ready | `nile_export/api/*.py` |
| Unit Tests | ✅ Ready | `nile_export/tests/test_doctypes.py` |
| Portal Skeleton | ✅ Ready | `portal/src/app/` |
| CI/CD | ✅ Ready | `.github/workflows/ci.yml` |

---

## 2. CRITICAL ISSUES TO RESOLVE

### Issue 2.1: Module Path Structure
- **Problem:** Duplicate nesting causes `ModuleNotFoundError`
- **Current:** `/apps/nile_export/nile_export/nile_export/doctype/`
- **Expected:** `/apps/nile_export/nile_export/doctype/`
- **Fix:** Reinstall app with correct path

### Issue 2.2: Python Package Installation
- **Problem:** `nile_export` module not found
- **Solution:** `pip install -e apps/nile_export` inside container

---

## 3. EXECUTION STEPS

### Phase 1: Environment Setup
```powershell
# Check Docker
docker version

# Start all services
docker-compose -f pwd.yml up -d

# Monitor startup
docker-compose -f pwd.yml logs -f
```

### Phase 2: App Installation
```bash
# Enter backend container
docker exec -it backend bash

# Install package
cd /home/frappe/frappe-bench
pip install -e apps/nile_export

# Install app in site
bench --site frontend install-app nile_export

# Export fixtures
bench --site frontend export-fixtures

# Run migrations
bench --site frontend migrate
```

### Phase 3: Verification
```bash
# List DocTypes
bench --site frontend list-doctypes | grep Export

# Run tests
bench --site frontend run-tests --app nile_export

# Check web access
curl http://localhost:8080
```

### Phase 4: Backup & Git
```bash
# Database backup
bench --site frontend backup --with-files

# Copy outside container
docker cp backend:/home/frappe/.local/share/benches/benches/0/private/* ./backups/

# Git commit/push
git add .
git commit -m "chore: complete environment setup"
git push origin master
```

---

## 4. ACCEPTANCE CRITERIA

- [ ] Docker: 7 containers "Up"
- [ ] `bench list-apps` includes "nile_export"
- [ ] `bench list-doctypes` shows 19 Export types
- [ ] `bench run-tests` passes (0 failures)
- [ ] http://localhost:8080 returns 200
- [ ] Git pushed to remote

---

## 5. DAILY WORKFLOW

```bash
# Start
git pull origin master
docker-compose -f pwd.yml up -d

# End
git add .
git commit -m "type: message"
git push origin master
bench backup --with-files
```

---

## 6. ROLLBACK PLAN

If installation fails:
1. `docker-compose -f pwd.yml down -v`
2. Remove volumes manually
3. Restart from Phase 1

---

## 7. SUCCESS INDICATORS

| Check | Command | Expected |
|-------|---------|----------|
| Containers | `docker-compose ps` | 7 "Up" |
| Apps | `bench list-apps` | nile_export present |
| DocTypes | `bench list-doctypes` | 19 types |
| Tests | `bench run-tests` | 0 failed |
| Web | `curl localhost:8080` | 200 OK |