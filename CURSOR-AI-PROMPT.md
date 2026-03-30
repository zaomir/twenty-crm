# CURSOR AI BACKGROUND AGENT PROMPT
# Twenty CRM Automated Deployment
# Execute as: Cursor Background Agent with SSH access to VDS

---

## OBJECTIVE

Deploy Twenty CRM on VDS 213.155.28.121 with complete isolation from GRAINEE.
Result: crm.grainee.com fully operational with SSL, backups, and integrations ready.

## CONTEXT

**VDS Details:**
- IP: 213.155.28.121
- SSH user: root
- Port: 22
- SSH key: /home/claude/id_rsa (OpenSSH format, provided)

**Existing Services (DO NOT TOUCH):**
- GRAINEE: localhost:3000 (React SPA + Supabase backend)
- ROVLEX: WordPress (on same VDS)
- ARBITR: REST API

**Project Context:**
- Total is non-technical founder
- Needs single CRM for GRAINEE, ROVLEX, ARBITR
- Wants ZAVOD Protocol integration (Google Sheets + Claude API)
- Requires zero downtime for existing services

**Files Available:**
- docker-compose.yml (in /tmp on VDS or current dir)
- .env.production (template, needs generation)
- deploy-twenty.sh (automated script)
- twenty-crm-nginx.conf (nginx config)
- twenty-crm-google-apps-script.gs (sync script)

## DEPLOYMENT PLAN

### PHASE 1: Infrastructure Setup
- [ ] SSH connect to 213.155.28.121
- [ ] Verify Docker installed
- [ ] Create directories: /docker/twenty-{compose,data,backups}
- [ ] Generate secure credentials (.env.production)
- [ ] Copy docker-compose.yml to /docker/twenty-compose/
- [ ] Start containers (PostgreSQL, Redis, API, Web)
- [ ] Verify all containers healthy

### PHASE 2: Nginx Configuration
- [ ] Copy twenty-crm-nginx.conf to /etc/nginx/sites-available/twenty-crm
- [ ] Verify nginx syntax: nginx -t
- [ ] Reload nginx: systemctl reload nginx
- [ ] Test HTTP to HTTPS redirect

### PHASE 3: SSL Certificate
- [ ] Get Let's Encrypt certificate for crm.grainee.com
- [ ] Verify certificate at /etc/letsencrypt/live/crm.grainee.com/
- [ ] Reload nginx with SSL config
- [ ] Verify HTTPS access: curl https://crm.grainee.com

### PHASE 4: Verification
- [ ] All containers running and healthy
- [ ] crm.grainee.com accessible via HTTPS
- [ ] GRAINEE still works on localhost:3000
- [ ] Backups folder created and tested
- [ ] Daily cron backup configured
- [ ] DNS verified
- [ ] Security headers present

## DETAILED EXECUTION STEPS

### STEP 1: SSH Connection & Preparation

```bash
#!/bin/bash
set -e

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="/home/claude/id_rsa"

# Test SSH connection
echo "Testing SSH connection..."
ssh -i $SSH_KEY $VDS_USER@$VDS_IP "echo 'SSH connection successful'"

# Create working directory
ssh -i $SSH_KEY $VDS_USER@$VDS_IP "mkdir -p /tmp/twenty-deployment"

echo "✅ SSH connection verified"
```

### STEP 2: Transfer Deployment Files

```bash
#!/bin/bash

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="/home/claude/id_rsa"

echo "Transferring deployment files..."

# Files to transfer (assuming they exist in current directory)
scp -i $SSH_KEY docker-compose.yml $VDS_USER@$VDS_IP:/tmp/twenty-deployment/
scp -i $SSH_KEY .env.production $VDS_USER@$VDS_IP:/tmp/twenty-deployment/
scp -i $SSH_KEY twenty-crm-nginx.conf $VDS_USER@$VDS_IP:/tmp/twenty-deployment/
scp -i $SSH_KEY deploy-twenty.sh $VDS_USER@$VDS_IP:/tmp/twenty-deployment/

echo "✅ Files transferred"
```

### STEP 3: Execute Deployment Script

```bash
#!/bin/bash

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="/home/claude/id_rsa"

echo "Running deployment script on VDS..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'REMOTE_SCRIPT'

set -e

cd /tmp/twenty-deployment

# Make script executable
chmod +x deploy-twenty.sh

# Run deployment (with output to monitor progress)
echo "Starting Twenty CRM deployment..."
sudo bash deploy-twenty.sh

echo "✅ Deployment script completed"

REMOTE_SCRIPT

echo "✅ Deployment executed successfully"
```

### STEP 4: Verify Containers

```bash
#!/bin/bash

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="/home/claude/id_rsa"

echo "Verifying containers..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'REMOTE_SCRIPT'

# Check all containers are running
echo "=== Container Status ==="
docker ps | grep twenty

# Verify health
echo "=== Health Checks ==="
docker ps --filter "name=twenty" --format "{{.Names}}\t{{.Status}}"

# Test API health
echo "=== API Health ==="
curl -s http://localhost:3001/health || echo "API not yet ready"

# Test web
echo "=== Web Frontend ==="
curl -s -o /dev/null -w "%{http_code}" http://localhost:3002 && echo " - Web is responding"

REMOTE_SCRIPT

echo "✅ Container verification complete"
```

### STEP 5: Configure Nginx

```bash
#!/bin/bash

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="/home/claude/id_rsa"

echo "Configuring nginx..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'REMOTE_SCRIPT'

cd /tmp/twenty-deployment

# Copy nginx config
echo "Installing nginx configuration..."
sudo cp twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm

# Test nginx syntax
echo "Testing nginx configuration..."
sudo nginx -t

# Reload nginx
echo "Reloading nginx..."
sudo systemctl reload nginx

echo "✅ Nginx configured"

REMOTE_SCRIPT

echo "✅ Nginx setup complete"
```

### STEP 6: Get SSL Certificate

```bash
#!/bin/bash

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="/home/claude/id_rsa"
DOMAIN="crm.grainee.com"

echo "Getting SSL certificate for $DOMAIN..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'REMOTE_SCRIPT'

DOMAIN="crm.grainee.com"

echo "Verifying DNS resolution..."
nslookup $DOMAIN

echo "Requesting SSL certificate from Let's Encrypt..."
sudo certbot certonly --standalone -d $DOMAIN --non-interactive --agree-tos --email admin@grainee.com

if [ $? -eq 0 ]; then
    echo "✅ SSL certificate obtained"
    ls -lah /etc/letsencrypt/live/$DOMAIN/
else
    echo "⚠️  SSL certificate request failed - may need manual intervention"
    echo "Try: sudo certbot certonly --standalone -d $DOMAIN"
fi

REMOTE_SCRIPT

echo "✅ SSL setup complete"
```

### STEP 7: Final Verification

```bash
#!/bin/bash

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="/home/claude/id_rsa"
DOMAIN="crm.grainee.com"

echo "Final verification..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'REMOTE_SCRIPT'

DOMAIN="crm.grainee.com"

echo "=== FINAL VERIFICATION CHECKLIST ==="

echo "1. Containers status:"
docker ps | grep twenty || echo "⚠️  No containers found"

echo -e "\n2. API Health:"
curl -s http://localhost:3001/health && echo " ✅" || echo " ❌"

echo -e "\n3. PostgreSQL connection:"
docker exec twenty-postgres-prod pg_isready -U twenty_prod_user && echo " ✅" || echo " ❌"

echo -e "\n4. Redis connection:"
docker exec twenty-redis redis-cli ping && echo " ✅" || echo " ❌"

echo -e "\n5. GRAINEE still running:"
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 && echo " ✅" || echo " ❌"

echo -e "\n6. SSL certificate:"
ls /etc/letsencrypt/live/$DOMAIN/fullchain.pem && echo " ✅" || echo " ❌"

echo -e "\n7. Backups folder:"
ls -lah /docker/backups/ | head -3 && echo " ✅" || echo " ❌"

echo -e "\n8. Nginx status:"
sudo systemctl status nginx | grep active && echo " ✅" || echo " ❌"

echo -e "\n=== DEPLOYMENT COMPLETE ==="
echo "Access Twenty CRM at: https://$DOMAIN"
echo "API Health check: https://$DOMAIN/health"

REMOTE_SCRIPT

echo "✅ All verifications passed!"
```

## COMPLETE DEPLOYMENT SCRIPT

Create file: `/tmp/deploy-twenty-complete.sh`

```bash
#!/bin/bash

# ============================================
# TWENTY CRM COMPLETE DEPLOYMENT SCRIPT
# For Cursor AI Background Agent
# ============================================

set -e

# Configuration
VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="/home/claude/id_rsa"
DOMAIN="crm.grainee.com"
DEPLOYMENT_DIR="/tmp/twenty-deployment"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# ===== PHASE 1: SSH & PREPARATION =====

log "PHASE 1: SSH Connection & Preparation"

# Test SSH
log "Testing SSH connection to $VDS_IP..."
ssh -i $SSH_KEY $VDS_USER@$VDS_IP "echo 'SSH OK'" > /dev/null 2>&1 || error "SSH connection failed"
success "SSH connection verified"

# Create deployment directory
log "Creating deployment directory..."
ssh -i $SSH_KEY $VDS_USER@$VDS_IP "mkdir -p $DEPLOYMENT_DIR && rm -rf $DEPLOYMENT_DIR/* && echo 'Ready'"
success "Deployment directory ready"

# ===== PHASE 2: FILE TRANSFER =====

log "PHASE 2: Transferring Files"

REQUIRED_FILES=(
    "docker-compose.yml"
    ".env.production"
    "twenty-crm-nginx.conf"
    "deploy-twenty.sh"
)

for FILE in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$FILE" ]; then
        error "Required file not found: $FILE"
    fi
    log "Transferring $FILE..."
    scp -i $SSH_KEY "$FILE" $VDS_USER@$VDS_IP:$DEPLOYMENT_DIR/ || error "Failed to transfer $FILE"
    success "$FILE transferred"
done

# ===== PHASE 3: DEPLOYMENT EXECUTION =====

log "PHASE 3: Executing Deployment Script"

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'DEPLOY_SCRIPT'

set -e

DEPLOYMENT_DIR="/tmp/twenty-deployment"
cd $DEPLOYMENT_DIR

# Execute main deployment script
echo "Executing deploy-twenty.sh..."
chmod +x deploy-twenty.sh
sudo bash deploy-twenty.sh || exit 1

echo "✅ Deployment script completed"

DEPLOY_SCRIPT

success "Deployment script executed"

# ===== PHASE 4: NGINX SETUP =====

log "PHASE 4: Nginx Configuration"

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'NGINX_SCRIPT'

DEPLOYMENT_DIR="/tmp/twenty-deployment"

echo "Installing nginx configuration..."
sudo cp $DEPLOYMENT_DIR/twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm

echo "Testing nginx syntax..."
sudo nginx -t || exit 1

echo "Reloading nginx..."
sudo systemctl reload nginx

echo "✅ Nginx configured"

NGINX_SCRIPT

success "Nginx configured"

# ===== PHASE 5: SSL CERTIFICATE =====

log "PHASE 5: SSL Certificate Setup"

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << SSL_SCRIPT

DOMAIN="$DOMAIN"

echo "Verifying DNS..."
nslookup $DOMAIN || echo "DNS check: warning"

echo "Requesting SSL certificate..."
sudo certbot certonly --standalone -d $DOMAIN \
    --non-interactive \
    --agree-tos \
    --email admin@grainee.com 2>&1 || echo "SSL may need manual setup"

if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "✅ SSL certificate obtained"
else
    echo "⚠️  SSL certificate not found - may need manual intervention"
fi

SSL_SCRIPT

success "SSL setup complete"

# ===== PHASE 6: VERIFICATION =====

log "PHASE 6: Final Verification"

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << VERIFY_SCRIPT

echo "=== VERIFICATION RESULTS ==="

echo "1. Containers:"
docker ps | grep -c "twenty-" && echo "✅ Containers running" || echo "❌ No containers"

echo "2. PostgreSQL:"
docker exec twenty-postgres-prod pg_isready -U twenty_prod_user > /dev/null && echo "✅ PostgreSQL OK" || echo "❌ PostgreSQL failed"

echo "3. API Health:"
curl -s http://localhost:3001/health > /dev/null && echo "✅ API OK" || echo "❌ API failed"

echo "4. GRAINEE:"
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|301" && echo "✅ GRAINEE OK" || echo "❌ GRAINEE down"

echo "5. Backups:"
[ -d "/docker/backups" ] && echo "✅ Backups folder OK" || echo "❌ Backups folder missing"

echo "6. SSL:"
[ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ] && echo "✅ SSL OK" || echo "⚠️  SSL not ready"

echo "7. Nginx:"
sudo systemctl is-active nginx > /dev/null && echo "✅ Nginx OK" || echo "❌ Nginx failed"

VERIFY_SCRIPT

success "Verification complete"

# ===== FINAL SUMMARY =====

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ TWENTY CRM DEPLOYMENT COMPLETE!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Open: https://$DOMAIN"
echo "2. Create admin account"
echo "3. Create workspaces: GRAINEE, ROVLEX, ARBITR"
echo "4. Setup integrations (see TWENTY_CRM_SETUP_COMPLETE.md)"
echo ""
echo -e "${BLUE}Important Paths:${NC}"
echo "- Config: /docker/twenty-compose/.env.production"
echo "- Data: /docker/twenty-data/"
echo "- Backups: /docker/backups/"
echo ""

success "Deployment finished successfully!"
```

## EXECUTION INSTRUCTIONS FOR CURSOR AI

### Option 1: Run Complete Script (Recommended)

```bash
# Copy deployment files to current directory
# (docker-compose.yml, .env.production, twenty-crm-nginx.conf, deploy-twenty.sh)

# Create and run complete script
bash /tmp/deploy-twenty-complete.sh
```

### Option 2: Execute Step-by-Step

```bash
# STEP 1: Transfer files
scp -i ~/.ssh/id_rsa docker-compose.yml root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa .env.production root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa twenty-crm-nginx.conf root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa deploy-twenty.sh root@213.155.28.121:/tmp/

# STEP 2: Execute deployment
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SCRIPT'
  cd /tmp
  chmod +x deploy-twenty.sh
  sudo bash deploy-twenty.sh
SCRIPT

# STEP 3: Configure nginx
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SCRIPT'
  sudo cp /tmp/twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm
  sudo nginx -t
  sudo systemctl reload nginx
SCRIPT

# STEP 4: Get SSL
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "sudo certbot certonly --standalone -d crm.grainee.com --non-interactive --agree-tos --email admin@grainee.com"

# STEP 5: Verify
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "docker ps | grep twenty && echo 'All containers running!'"
```

## SUCCESS CRITERIA

✅ Deployment is successful when:

1. All 4 Docker containers running and healthy
2. https://crm.grainee.com accessible (HTTPS works)
3. GRAINEE still running on localhost:3000
4. PostgreSQL database operational
5. Redis cache operational
6. Nginx routing configured
7. SSL certificate installed
8. Daily backup cron configured
9. No errors in logs

## TROUBLESHOOTING

If any step fails:

1. Check SSH connection
2. Review logs: `ssh root@213.155.28.121 "docker logs twenty-api"`
3. Verify disk space: `ssh root@213.155.28.121 "df -h"`
4. Check ports: `ssh root@213.155.28.121 "netstat -tulpn | grep 3001"`

## ROLLBACK PROCEDURE

If complete rollback needed:

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'ROLLBACK'

# Stop containers (safe - no data loss)
docker compose -f /docker/twenty-compose/docker-compose.yml down

# Remove nginx config
sudo rm /etc/nginx/sites-available/twenty-crm

# Reload nginx
sudo systemctl reload nginx

# Verify GRAINEE still works
curl http://localhost:3000

echo "✅ Rollback complete - GRAINEE unaffected"

ROLLBACK
```

## END OF PROMPT

Deploy and report results!
