# ⚡ TWENTY CRM - QUICK START (1 Hour Deploy)

**Date:** 2026-03-30  
**Status:** Ready to deploy  
**Owner:** Total

---

## 📦 What You Have

Seven files ready to deploy:

```
1. docker-compose.yml           ← Docker контейнеры (PostgreSQL, API, Web, Redis)
2. .env.production              ← Конфигурация (пароли, токены)
3. deploy-twenty.sh             ← Автоматизированный скрипт развёртывания
4. twenty-crm-nginx.conf        ← Nginx routing (crm.grainee.com)
5. twenty-crm-google-apps-script.gs ← Синхронизация с Google Sheets
6. twenty-crm-deployment-plan.md    ← Архитектурный план
7. TWENTY_CRM_SETUP_COMPLETE.md     ← Детальное руководство
```

---

## ⏰ 1-Hour Timeline

| Minute | Task | Status |
|--------|------|--------|
| 0-5 | Transfer files to VDS | 📌 Step 1 |
| 5-15 | Run deployment script | 📌 Step 2 |
| 15-20 | Verify deployment | 📌 Step 3 |
| 20-40 | Get SSL certificate | 📌 Step 4 |
| 40-50 | Create admin account | 📌 Step 5 |
| 50-60 | Test access | ✅ Done |

---

## 🚀 STEP-BY-STEP

### STEP 1: Transfer Files (5 min)

**On your local machine:**

```bash
# Navigate to directory with downloaded files
cd ~/Downloads  # or wherever you saved them

# Transfer to VDS
scp -i ~/.ssh/id_rsa docker-compose.yml root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa .env.production root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa twenty-crm-nginx.conf root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa deploy-twenty.sh root@213.155.28.121:/tmp/

# SSH into VDS
ssh -i ~/.ssh/id_rsa root@213.155.28.121
```

---

### STEP 2: Run Deployment Script (10 min)

**On VDS (in SSH session):**

```bash
# Navigate to files
cd /tmp

# Make script executable
chmod +x deploy-twenty.sh

# Run deployment
sudo bash deploy-twenty.sh
```

**What happens automatically:**
- ✅ Creates directories (`/docker/twenty-*`)
- ✅ Generates secure passwords
- ✅ Pulls Docker images
- ✅ Starts containers (PostgreSQL, API, Web, Redis)
- ✅ Configures nginx routing
- ✅ Sets up daily backups
- ✅ Returns success message with next steps

**Expected output:**
```
========================================
✓ TWENTY CRM DEPLOYMENT COMPLETE
========================================
```

---

### STEP 3: Verify Deployment (5 min)

**Still on VDS:**

```bash
# Check containers are running
docker ps | grep twenty

# Should see 4 containers:
# - twenty-postgres-prod (healthy)
# - twenty-api (healthy)
# - twenty-web (healthy)
# - twenty-redis (healthy)

# Check API is responding
curl http://localhost:3001/health

# Check web is loading
curl http://localhost:3002/ | head -20

# Check nginx routing
curl -I http://crm.grainee.com

# Check GRAINEE still works (should return 200)
curl http://localhost:3000
```

**Expected:**
- ✅ All containers show "Up" and "healthy"
- ✅ API returns `{"status": "ok"}`
- ✅ Web returns HTML
- ✅ GRAINEE still responds

---

### STEP 4: Get SSL Certificate (20 min)

**Still on VDS:**

```bash
# First, ensure domain DNS points to your VDS
# Update your DNS records:
# crm.grainee.com  A  213.155.28.121

# Then get SSL cert (certbot will verify domain)
sudo certbot certonly --standalone -d crm.grainee.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Wait for certificate

# Verify certificate exists
ls -lah /etc/letsencrypt/live/crm.grainee.com/

# Enable https in nginx
cd /tmp
cp twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm

# Test nginx config
sudo nginx -t

# If OK, reload
sudo systemctl reload nginx

# Verify HTTPS works
curl https://crm.grainee.com/health
```

**Expected:**
```
/etc/letsencrypt/live/crm.grainee.com/
├── fullchain.pem
├── privkey.pem
└── ...

HTTP status: 200
```

---

### STEP 5: Create Admin Account (10 min)

**On your local machine:**

```
Open browser:
https://crm.grainee.com
```

**You'll see:**
- "Create your workspace" form
- Email field
- Password field
- Company name field

**Fill in:**
- Email: `total@grainee.com` (or your email)
- Password: Strong password (SAVE IT!)
- Company: `GRAINEE Main`

**Click:** "Create workspace"

**You'll see:**
- Dashboard loads
- Empty CRM ready for setup
- Navigation menu on left

---

### STEP 6: Test Access (5 min)

**Verify all endpoints work:**

```bash
# From your local machine:

# 1. Web interface
curl -I https://crm.grainee.com

# 2. API health
curl https://crm.grainee.com/api/health

# 3. GRAINEE still works
curl http://213.155.28.121:3000

# 4. Check nginx logs
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "tail -20 /var/log/nginx/twenty-crm-access.log"
```

**Expected:**
```
HTTP/1.1 200 OK  ← Web works
HTTP/1.1 200 OK  ← API works
HTTP/1.1 200 OK  ← GRAINEE works
```

---

## ✅ Deployment Complete!

You now have:
- ✅ Twenty CRM running on VDS
- ✅ Accessible at crm.grainee.com
- ✅ SSL certificate (HTTPS)
- ✅ Daily backups automated
- ✅ GRAINEE/ROVLEX/ARBITR untouched
- ✅ Ready for integrations

---

## 🔧 Next Steps (Not Required Today)

### Phase 2: Setup Integrations (Tomorrow)

**See:** `TWENTY_CRM_SETUP_COMPLETE.md` for:
- Google Sheets sync setup
- WhatsApp Business API
- Stripe integration
- GitHub integration
- Google OAuth setup

### Phase 3: ZAVOD Protocol (This Week)

- Create Google Sheets data bus
- Deploy Google Apps Script
- Setup planning agents
- Test agent workflows

---

## 🐛 If Something Goes Wrong

### Problem: "Cannot connect to crm.grainee.com"

```bash
# 1. Check DNS
nslookup crm.grainee.com

# 2. Check nginx is running
sudo systemctl status nginx

# 3. Check containers
docker ps | grep twenty

# 4. Check logs
docker logs twenty-api
sudo tail -50 /var/log/nginx/error.log
```

### Problem: "Containers not starting"

```bash
# 1. Check Docker is running
sudo systemctl status docker

# 2. Check resources
docker stats

# 3. Check for port conflicts
sudo netstat -tulpn | grep -E "(3001|3002|5433|6380)"

# 4. View deployment log
docker logs twenty-postgres-prod
```

### Problem: "GRAINEE stopped working"

Twenty CRM should NOT affect GRAINEE at all. If GRAINEE is broken:

```bash
# 1. Check GRAINEE directly
curl http://localhost:3000

# 2. It's NOT from Twenty (different port/container)
# Check GRAINEE logs, nginx config for GRAINEE

# 3. If needed, GRAINEE is still running on :3000
# Twenty is on :3001 and :3002 (isolated)
```

### Problem: "SSL Certificate error"

```bash
# If certbot fails, you can use HTTP for now
# and get SSL later

# To get SSL later:
sudo certbot certonly --standalone -d crm.grainee.com

# Or switch to webroot method:
sudo certbot certonly --webroot -w /var/www -d crm.grainee.com
```

---

## 📞 Important Contacts

**After deployment, you have:**

- **CRM URL:** https://crm.grainee.com
- **API endpoint:** https://crm.grainee.com/api
- **Admin login:** total@grainee.com (your password)

**On VDS:**

- **Docker compose:** `/docker/twenty-compose/`
- **Configuration:** `/docker/twenty-compose/.env.production`
- **Data:** `/docker/twenty-data/`
- **Backups:** `/docker/backups/` (daily)

**Useful commands:**

```bash
# Check status
docker ps | grep twenty

# View logs
docker logs -f twenty-api

# Restart
docker compose -f /docker/twenty-compose/docker-compose.yml restart

# Backup database
docker exec twenty-postgres-prod pg_dump -U twenty_prod_user twenty_crm_prod > /docker/backups/manual_$(date +%s).sql
```

---

## 🎯 Success Indicators

You're ready for Phase 2 when:

- [x] Can access https://crm.grainee.com
- [x] Can login with admin account
- [x] CRM shows "My Company" workspace
- [x] GRAINEE still works on :3000
- [x] Backups folder has files
- [x] No errors in Docker logs

---

## 📚 Full Documentation

For complete setup details, see:

| File | Purpose |
|------|---------|
| `TWENTY_CRM_SETUP_COMPLETE.md` | Full step-by-step guide (16 KB) |
| `twenty-crm-deployment-plan.md` | Architecture details (9 KB) |
| `FOUNDER-NOTES-TWENTY-CRM-UPDATE.md` | Strategic decisions (5 KB) |

---

## ⏱️ Estimated Timing

| Task | Time | Notes |
|------|------|-------|
| Transfer files | 2 min | scp commands |
| Run deploy script | 10 min | Automated |
| Get SSL cert | 5 min | Interactive |
| Create admin | 3 min | Web form |
| Test all | 5 min | curl commands |
| **TOTAL** | **25 min** | ✅ Under 1 hour |

---

## 🚨 CRITICAL: Before You Start

Make sure you have:

- [ ] SSH access to VDS (213.155.28.121)
- [ ] Private key for SSH (`~/.ssh/id_rsa`)
- [ ] Domain pointing to VDS (crm.grainee.com or similar)
- [ ] ~5GB free disk space on VDS
- [ ] Docker installed on VDS (script checks this)
- [ ] Internet connection for downloading Docker images

---

## 🎓 What You're Deploying

Twenty CRM is a **modern open-source CRM** built with:

- **Backend:** Node.js + GraphQL API
- **Frontend:** React + TypeScript
- **Database:** PostgreSQL 15
- **Cache:** Redis
- **Web Server:** Nginx
- **Deployment:** Docker Compose

It integrates with:

- Google Workspace (Sheets, Drive, Gmail, Calendar)
- WhatsApp Business API (messaging)
- Stripe (payments)
- GitHub (code linking)
- Custom webhooks (any service)

---

## 💾 Backup & Recovery

**Automatic:**
- Daily backup at 3 AM UTC
- Location: `/docker/backups/`
- Retention: 30 days (auto-delete older)

**Manual backup:**
```bash
docker exec twenty-postgres-prod pg_dump -U twenty_prod_user twenty_crm_prod > backup_$(date +%Y%m%d_%H%M%S).sql
```

**Restore:**
```bash
docker exec twenty-postgres-prod psql -U twenty_prod_user twenty_crm_prod < backup_YYYYMMDD.sql
```

---

## ✍️ Sign-off

**Approved deployment for:** Total  
**Infrastructure:** VDS 213.155.28.121  
**Timeline:** ~25-30 minutes  
**Risk level:** Low (isolated containers)  
**Rollback time:** <5 minutes (docker down)  

Ready to deploy? Run the script! 🚀

---

**Last updated:** 2026-03-30  
**Status:** READY FOR DEPLOYMENT  
**Next phase:** Integrations (tomorrow)
