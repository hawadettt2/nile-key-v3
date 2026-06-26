# Nile Export v3 - Implementation Plan

## Goal
Deploy Nile Key v3 Digital Export Gateway with all 19 DocTypes, RBAC, workflows, and APIs operational.

## Current State
- **Deep Freeze:** Removed
- **Source Code:** Complete (19 DocTypes, 13 roles, 3 workflows, 7 APIs)
- **Environment:** Not started (Docker not running)

## Prerequisites
- Docker Desktop running on Windows
- Project cloned at `F:\nilekey\nile-key-project\nile-key-v3`

## Execution Steps

### Step 1: Start Environment
```powershell
cd F:\nilekey\nile-key-project\nile-key-v3
docker-compose -f pwd.yml up -d
```
**Wait for:** All 7 containers show "Up" status

### Step 2: Install App
```bash
docker exec -it backend bash
cd /home/frappe/frappe-bench
pip install -e apps/nile_export
bench --site frontend install-app nile_export
bench --site frontend export-fixtures
bench --site frontend migrate
exit
```

### Step 3: Verify
```bash
# Check DocTypes
docker exec backend bench --site frontend list-doctypes | grep Export

# Run tests
docker exec backend bench --site frontend run-tests --app nile_export

# Check web
curl http://localhost:8080
```

### Step 4: Backup & Push
```bash
git add .
git commit -m "chore: complete environment setup"
git push origin master
docker exec backend bench backup --with-files
```

## Success Criteria
- [ ] 7 Docker containers running
- [ ] nile_export in `bench list-apps`
- [ ] 19 DocTypes listed
- [ ] Tests pass (0 failures)
- [ ] http://localhost:8080 accessible

## Risks
- Docker Desktop not starting (see WSL2 alternative in plan)
- Port conflicts (8080, 3306, 6379)
- Permission issues in container

## Rollback
```bash
docker-compose -f pwd.yml down -v
# Start over from Step 1
```