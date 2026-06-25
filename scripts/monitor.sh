#!/bin/bash
# Monitoring and health check script for Nile Export Gateway

# Health check function
health_check() {
    echo "Checking Nile Export Gateway health..."
    
    # Check Docker containers
    if ! docker-compose -f /opt/nile-export/pwd.yml ps | grep -q "healthy"; then
        echo "ERROR: Docker containers not healthy"
        return 1
    fi
    
    # Check HTTP endpoint
    if ! curl -sf http://localhost:8080/api/method/ping > /dev/null; then
        echo "ERROR: HTTP endpoint not responding"
        return 1
    fi
    
    # Check database connection
    if ! docker exec db mariadb-admin ping > /dev/null 2>&1; then
        echo "ERROR: Database not responding"
        return 1
    fi
    
    echo "Health check passed"
    return 0
}

# Backup check
backup_check() {
    BACKUP_DIR="/opt/backups"
    LATEST_BACKUP=$(ls -t $BACKUP_DIR/*.sql.gz 2>/dev/null | head -1)
    
    if [ -z "$LATEST_BACKUP" ]; then
        echo "WARNING: No backups found"
        return 1
    fi
    
    BACKUP_AGE=$(( ( $(date +%s) - $(stat -c %Y "$LATEST_BACKUP") ) / 86400 ))
    
    if [ $BACKUP_AGE -gt 7 ]; then
        echo "WARNING: Latest backup is $BACKUP_AGE days old"
        return 1
    fi
    
    echo "Backup check passed (latest: $BACKUP_AGE days ago)"
    return 0
}

# Main
case "$1" in
    health)
        health_check
        ;;
    backup)
        backup_check
        ;;
    all)
        health_check
        backup_check
        ;;
    *)
        echo "Usage: $0 {health|backup|all}"
        exit 1
        ;;
esac