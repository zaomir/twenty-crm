# 🚀 CURSOR AI TASK: CONTROLCENTER.ME DEPLOYMENT ON VDS

**Repo:** https://github.com/zaomir/twenty-crm  
**Target:** controlcenter.me on VDS 213.155.28.121  
**Date:** 2026-03-30

---

## 📋 OBJECTIVE

Deploy controlcenter.me using updated `docker-compose.yml` from GitHub with proper `.env` configuration and minimal data loss risk.

---

## ⚠️ CRITICAL NOTES

1. **Docker Compose and `.env`:**
   - Docker Compose reads `.env` by default (NOT `.env.production`)
   - Copy `.env.controlcenter.example` → `.env` in the working directory
   - OR explicitly set `env_file: .env.production` in `docker-compose.yml` if needed

2. **Database Safety:**
   - `docker-compose down -v` deletes volumes (PostgreSQL data lost!)
   - Use `docker-compose down` (without `-v`) for config updates
   - Use `-v` ONLY if you intentionally reset the database from scratch

3. **Credentials:**
   - VDS IP: `213.155.28.121`
   - SSH Key: `~/.ssh/id_rsa`
   - User: `root`
   - Domain: `controlcenter.me`

---

## 🎯 STEPS

### Step 1: Pull Latest Changes from GitHub

```bash
cd ~/twenty-crm
git pull origin main
```

**Expected:** No conflicts (or resolve them if any). Verify `docker-compose.yml` and `controlcenter-nginx.conf` are updated.

---

### Step 2: Prepare `.env` File Locally

```bash
# Copy template to .env
cp .env.controlcenter.example .env

# Verify .env contains all required variables:
# - POSTGRES_DB=controlcenter_prod
# - POSTGRES_USER=controlcenter_user
# - POSTGRES_PASSWORD=tK7mP9nQ2rL4wX8sF1dJ5hB3cV6xY0zA
# - REDIS_PASSWORD=hJ2kL8mN5pQ7rS9tU1vW3xY5zB7cD9eF
# - APP_SECRET=7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a
```

**Expected:** `.env` file exists and contains all variables.

---

### Step 3: Copy Files to VDS

```bash
# Create working directory on VDS
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "mkdir -p /tmp/controlcenter-deploy"

# Copy files to VDS
scp -i ~/.ssh/id_rsa docker-compose.yml root@213.155.28.121:/tmp/controlcenter-deploy/
scp -i ~/.ssh/id_rsa .env root@213.155.28.121:/tmp/controlcenter-deploy/
scp -i ~/.ssh/id_rsa controlcenter-nginx.conf root@213.155.28.121:/tmp/controlcenter-deploy/
```

**Expected:** Files copied successfully.

---

### Step 4: Verify Files on VDS

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "ls -lah /tmp/controlcenter-deploy/"
```

**Expected:** All three files present:
- `docker-compose.yml`
- `.env`
- `controlcenter-nginx.conf`

---

### Step 5: Stop and Update Containers (SAFELY)

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'UPDATE'
cd /tmp/controlcenter-deploy

echo "📋 Current container status:"
docker-compose ps

echo ""
echo "🛑 Stopping containers (keeping volumes)..."
docker-compose down

echo ""
echo "✅ Containers stopped. Data preserved."
UPDATE
```

**Expected:** Containers stopped, volumes intact, data preserved.

---

### Step 6: Start Updated Containers

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'DEPLOY'
cd /tmp/controlcenter-deploy

echo "🚀 Starting controlcenter.me with new config..."
docker-compose up -d

echo ""
echo "⏳ Waiting for healthchecks (120s startup period)..."
sleep 15

echo ""
echo "📊 Container status:"
docker-compose ps

echo ""
echo "📋 Recent logs:"
docker logs controlcenter-crm 2>&1 | tail -30
DEPLOY
```

**Expected:**
- Containers running
- `controlcenter-crm` health status: `starting` or `healthy`
- Logs show: `Nest application successfully started` or similar

---

### Step 7: Verify Nginx Configuration

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'NGINX'
cd /tmp/controlcenter-deploy

echo "🔒 Configuring Nginx..."
sudo cp controlcenter-nginx.conf /etc/nginx/sites-available/controlcenter
sudo ln -sf /etc/nginx/sites-available/controlcenter /etc/nginx/sites-enabled/controlcenter

echo ""
echo "✅ Testing Nginx config:"
sudo nginx -t

echo ""
echo "🔄 Reloading Nginx:"
sudo systemctl reload nginx

echo "✅ Nginx reloaded"
NGINX
```

**Expected:** `nginx: configuration file test is successful`

---

### Step 8: Get SSL Certificate

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SSL'
echo "🔒 Getting SSL certificate for controlcenter.me..."
sudo certbot certonly --standalone -d controlcenter.me --non-interactive --agree-tos --email admin@controlcenter.me

echo ""
echo "✅ SSL certificate acquired"
SSL
```

**Expected:** Certificate obtained successfully (or already exists).

---

### Step 9: Health Checks

```bash
# Wait for application startup
sleep 10

# Check HTTP endpoint
curl -s http://127.0.0.1:3030/healthz

# Check HTTPS (self-signed ok)
curl -k https://controlcenter.me/healthz

# Check GraphQL endpoint
curl -k https://controlcenter.me/graphql
```

**Expected:**
- HTTP 200 responses
- No connection errors

---

### Step 10: Final Verification

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'FINAL'
echo "=== Docker Containers ==="
docker ps | grep controlcenter

echo ""
echo "=== Nginx Status ==="
sudo systemctl status nginx | grep Active

echo ""
echo "=== Disk Usage ==="
df -h /tmp/controlcenter-deploy

echo ""
echo "=== Logs (last 50 lines) ==="
docker logs controlcenter-crm 2>&1 | tail -50
FINAL
```

**Expected:**
- All containers running
- Nginx active
- No error logs

---

## ✅ SUCCESS CRITERIA

- [ ] Git pull completed without issues
- [ ] `.env` file created from template
- [ ] Files copied to VDS `/tmp/controlcenter-deploy/`
- [ ] `docker-compose down` executed (containers stopped, volumes preserved)
- [ ] `docker-compose up -d` executed (containers started)
- [ ] `controlcenter-crm` health status is `healthy` or `starting`
- [ ] Nginx test passes (`configuration file test is successful`)
- [ ] SSL certificate obtained
- [ ] Health endpoints respond with HTTP 200
- [ ] No error messages in logs

---

## 🔄 IF SOMETHING GOES WRONG

1. **Container won't start:**
   ```bash
   docker logs controlcenter-crm | tail -50  # Check logs
   docker-compose ps  # Check status
   ```

2. **Database connection error:**
   - Verify `.env` credentials match `docker-compose.yml`
   - Check `postgres` container is healthy: `docker ps | grep postgres`

3. **Nginx errors:**
   ```bash
   sudo nginx -t  # Test config
   sudo systemctl status nginx  # Check status
   ```

4. **Reset (use ONLY if intentional):**
   ```bash
   # DANGER: This deletes all data!
   docker-compose down -v
   docker-compose up -d
   ```

---

## 📞 NOTES FOR NEXT DEPLOYMENT

- Keep `.env` file safe (contains credentials)
- Always use `docker-compose down` without `-v` for updates
- Use `-v` flag ONLY when you intentionally reset the database
- Docker Compose reads `.env` by default — no need to specify `env_file`
- Check logs frequently: `docker logs controlcenter-crm`

---

**Status: READY FOR EXECUTION**  
**Last Updated: 2026-03-30**  
**Target System: VDS 213.155.28.121**
