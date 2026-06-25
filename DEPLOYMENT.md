# Production Deployment Checklist

## Prerequisites
- [ ] Ubuntu 22.04/24.04 server
- [ ] Domain name pointing to server
- [ ] SSL certificate ready
- [ ] Database backup available

## Steps

### 1. Server Setup
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Pull latest code
```bash
git clone https://github.com/hawadettt2/nile-key-v3.git
cd nile-key-v3
git checkout master
```

### 3. Deploy
```bash
docker-compose -f pwd.yml up -d
```

### 4. Verify
```bash
docker ps
curl http://localhost:8080
```

### 5. Create site
```bash
docker exec -it backend bench new-site --db-name nile-key-prod
docker exec -it backend bench --site nile-key-prod install-app nile_export
docker exec -it backend bench --site nile-key-prod migrate
```

### 6. Configure HTTPS
- Add nginx reverse proxy
- Configure SSL with certbot
- Set up automatic renewal

### 7. Monitoring
- [ ] Set up log aggregation
- [ ] Configure health checks
- [ ] Set up backup cron job