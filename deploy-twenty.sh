#!/bin/bash

# ============================================
# TWENTY CRM DEPLOYMENT SCRIPT
# File: deploy-twenty.sh
# Usage: bash deploy-twenty.sh
# ============================================

set -e  # Выход при ошибке

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VDS_IP="213.155.28.121"
CRM_DOMAIN="crm.grainee.com"
DOCKER_BASE="/docker"
DOCKER_COMPOSE_DIR="${DOCKER_BASE}/twenty-compose"
DOCKER_DATA_DIR="${DOCKER_BASE}/twenty-data"
BACKUP_DIR="${DOCKER_BASE}/backups"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Twenty CRM Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ========== CHECK: Root privileges ==========
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root${NC}"
   exit 1
fi

echo -e "${YELLOW}✓ Running as root${NC}"

# ========== CHECK: Docker installed ==========
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Install Docker: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    exit 1
fi

echo -e "${YELLOW}✓ Docker is installed${NC}"
DOCKER_VERSION=$(docker --version)
echo "  Version: $DOCKER_VERSION"

# ========== CHECK: Docker Compose installed ==========
if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo "Install Docker Compose: apt-get install docker-compose-plugin"
    exit 1
fi

echo -e "${YELLOW}✓ Docker Compose is installed${NC}"

# ========== CHECK: Port availability ==========
echo ""
echo -e "${BLUE}Checking port availability...${NC}"

for port in 3001 3002 5433 6380; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${RED}❌ Port $port is already in use${NC}"
        exit 1
    fi
done

echo -e "${YELLOW}✓ All ports available (3001, 3002, 5433, 6380)${NC}"

# ========== CREATE: Directory structure ==========
echo ""
echo -e "${BLUE}Creating directory structure...${NC}"

mkdir -p "${DOCKER_COMPOSE_DIR}"
mkdir -p "${DOCKER_DATA_DIR}/postgres"
mkdir -p "${DOCKER_DATA_DIR}/redis"
mkdir -p "${DOCKER_DATA_DIR}/uploads"
mkdir -p "${BACKUP_DIR}"

echo -e "${YELLOW}✓ Created directories:${NC}"
echo "  - ${DOCKER_COMPOSE_DIR}"
echo "  - ${DOCKER_DATA_DIR}/postgres"
echo "  - ${DOCKER_DATA_DIR}/redis"
echo "  - ${DOCKER_DATA_DIR}/uploads"
echo "  - ${BACKUP_DIR}"

# ========== PERMISSION: Set ownership ==========
chown -R 999:999 "${DOCKER_DATA_DIR}/postgres"
chown -R 999:999 "${DOCKER_DATA_DIR}/redis"
chmod 700 "${DOCKER_DATA_DIR}/postgres"
chmod 700 "${DOCKER_DATA_DIR}/redis"

echo -e "${YELLOW}✓ Set permissions${NC}"

# ========== CHECK: Existing GRAINEE ==========
echo ""
echo -e "${BLUE}Checking existing services...${NC}"

if docker ps 2>/dev/null | grep -q "grainee"; then
    echo -e "${YELLOW}✓ GRAINEE containers found (will not be affected)${NC}"
else
    echo -e "${YELLOW}⚠ No GRAINEE containers currently running${NC}"
fi

# ========== GENERATE: Environment file ==========
echo ""
echo -e "${BLUE}Generating environment configuration...${NC}"

# Generate secure passwords
PG_PASSWORD=$(openssl rand -hex 16)
REDIS_PASSWORD=$(openssl rand -hex 16)
JWT_SECRET=$(openssl rand -hex 32)
REFRESH_TOKEN_SECRET=$(openssl rand -hex 32)
API_SECRET_KEY=$(openssl rand -hex 32)

# Create .env.production
cat > "${DOCKER_COMPOSE_DIR}/.env.production" << EOF
# ============================================
# TWENTY CRM - PRODUCTION ENVIRONMENT
# Generated: $(date)
# ============================================

# DATABASE
POSTGRES_USER=twenty_prod_user
POSTGRES_PASSWORD=${PG_PASSWORD}
POSTGRES_DB=twenty_crm_prod

# SERVER
NODE_ENV=production
SERVER_URL=https://${CRM_DOMAIN}
FRONT_BASE_URL=https://${CRM_DOMAIN}
API_BASE_URL=https://${CRM_DOMAIN}/api

# SECURITY
JWT_SECRET=${JWT_SECRET}
REFRESH_TOKEN_SECRET=${REFRESH_TOKEN_SECRET}
API_SECRET_KEY=${API_SECRET_KEY}

# REDIS
REDIS_PASSWORD=${REDIS_PASSWORD}

# EMAIL (Update with your SMTP)
EMAIL_FROM=noreply@grainee.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@grainee.com
SMTP_PASSWORD=your-app-password

# INTEGRATIONS (To be configured later)
STRIPE_API_KEY=sk_test_
STRIPE_PUBLISHABLE_KEY=pk_test_
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
WHATSAPP_BUSINESS_ACCOUNT_ID=
WHATSAPP_ACCESS_TOKEN=
TELEGRAM_BOT_TOKEN=

# FEATURES
ENABLE_WORKSPACE_SIGNUP=false
WORKSPACE_INVITATION_REQUIRED=true
LOG_LEVEL=info
CORS_ALLOWED_ORIGINS=https://${CRM_DOMAIN}

# SESSION
SESSION_COOKIE_SECURE=true
SESSION_COOKIE_SAME_SITE=Lax
SESSION_COOKIE_DOMAIN=${CRM_DOMAIN}
EOF

echo -e "${YELLOW}✓ Created .env.production${NC}"
echo "  Path: ${DOCKER_COMPOSE_DIR}/.env.production"
echo ""
echo -e "${YELLOW}⚠ IMPORTANT: Update the following in .env.production:${NC}"
echo "  - SMTP_USER and SMTP_PASSWORD (for email notifications)"
echo "  - Integration tokens (Stripe, Google, WhatsApp, Telegram) - can be done later"

# ========== CHECK: SSL Certificate ==========
echo ""
echo -e "${BLUE}Checking SSL certificate for ${CRM_DOMAIN}...${NC}"

if [ -f "/etc/letsencrypt/live/${CRM_DOMAIN}/fullchain.pem" ]; then
    echo -e "${YELLOW}✓ SSL certificate found${NC}"
else
    echo -e "${YELLOW}⚠ SSL certificate not found for ${CRM_DOMAIN}${NC}"
    echo "  You can obtain one after the setup:"
    echo "  sudo certbot certonly --standalone -d ${CRM_DOMAIN}"
    echo ""
    echo -e "${RED}  Twenty CRM will not be accessible via HTTPS until certificate is obtained${NC}"
fi

# ========== BACKUP: Existing nginx config ==========
echo ""
echo -e "${BLUE}Backing up nginx configuration...${NC}"

if [ -f "/etc/nginx/sites-available/twenty-crm" ]; then
    cp /etc/nginx/sites-available/twenty-crm /etc/nginx/sites-available/twenty-crm.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${YELLOW}✓ Existing twenty-crm config backed up${NC}"
fi

# ========== PULL: Docker images ==========
echo ""
echo -e "${BLUE}Pulling Docker images...${NC}"

docker pull postgres:15-alpine
docker pull redis:7-alpine
docker pull twentyhq/twenty-backend:latest
docker pull twentyhq/twenty-frontend:latest

echo -e "${YELLOW}✓ Docker images pulled${NC}"

# ========== DOCKER COMPOSE: Validation ==========
echo ""
echo -e "${BLUE}Validating docker-compose configuration...${NC}"

# Check if docker-compose.yml exists in current directory
if [ -f "./docker-compose.yml" ]; then
    cp ./docker-compose.yml "${DOCKER_COMPOSE_DIR}/"
    echo -e "${YELLOW}✓ Copied docker-compose.yml to ${DOCKER_COMPOSE_DIR}/${NC}"
else
    echo -e "${RED}❌ docker-compose.yml not found in current directory${NC}"
    echo "  Please run this script from directory containing docker-compose.yml"
    exit 1
fi

cd "${DOCKER_COMPOSE_DIR}"
docker compose config > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${YELLOW}✓ docker-compose.yml is valid${NC}"
else
    echo -e "${RED}❌ docker-compose.yml validation failed${NC}"
    exit 1
fi

# ========== START: Docker containers ==========
echo ""
echo -e "${BLUE}Starting Docker containers...${NC}"

docker compose up -d

echo ""
echo -e "${YELLOW}✓ Docker containers started${NC}"
docker ps | grep twenty

# ========== WAIT: Services to be healthy ==========
echo ""
echo -e "${BLUE}Waiting for services to be healthy...${NC}"

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."
for i in {1..30}; do
    if docker exec twenty-postgres-prod pg_isready -U twenty_prod_user -d twenty_crm_prod > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Wait for API
echo "Waiting for Twenty API..."
for i in {1..30}; do
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Twenty API is ready${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Wait for Web
echo "Waiting for Twenty Web..."
for i in {1..30}; do
    if curl -s http://localhost:3002/ > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Twenty Web is ready${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# ========== NGINX: Setup ==========
echo ""
echo -e "${BLUE}Setting up nginx routing...${NC}"

if [ -f "./twenty-crm-nginx.conf" ]; then
    cp ./twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm
    echo -e "${YELLOW}✓ Copied nginx config${NC}"
else
    echo -e "${YELLOW}⚠ twenty-crm-nginx.conf not found, skipping nginx setup${NC}"
    echo "  You can manually copy it later from your prepared files"
fi

# Test nginx config
if nginx -t 2>&1 | grep -q "successful"; then
    systemctl reload nginx
    echo -e "${YELLOW}✓ nginx reloaded${NC}"
else
    echo -e "${RED}❌ nginx config test failed${NC}"
    echo "Please check /etc/nginx/sites-available/twenty-crm"
fi

# ========== SETUP: Backup cron job ==========
echo ""
echo -e "${BLUE}Setting up automatic backups...${NC}"

CRON_JOB="0 3 * * * cd ${DOCKER_COMPOSE_DIR} && docker compose exec -T twenty-postgres-prod pg_dump -U twenty_prod_user twenty_crm_prod | gzip > ${BACKUP_DIR}/twenty_\$(date +\\%Y\\%m\\%d).sql.gz && find ${BACKUP_DIR} -name \"twenty_*.sql.gz\" -mtime +30 -delete"

if ! crontab -l 2>/dev/null | grep -q "pg_dump"; then
    echo "$CRON_JOB" | crontab -
    echo -e "${YELLOW}✓ Backup cron job added (daily at 3 AM)${NC}"
else
    echo -e "${YELLOW}✓ Backup cron job already exists${NC}"
fi

# ========== FINAL SUMMARY ==========
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ TWENTY CRM DEPLOYMENT COMPLETE${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${BLUE}📋 NEXT STEPS:${NC}"
echo ""
echo "1. ⚙️  Update environment variables:"
echo "   nano ${DOCKER_COMPOSE_DIR}/.env.production"
echo "   (SMTP credentials, integrations)"
echo ""
echo "2. 🔒 Obtain SSL certificate (if not already done):"
echo "   sudo certbot certonly --standalone -d ${CRM_DOMAIN}"
echo ""
echo "3. 🌐 Access Twenty CRM:"
if [ -f "/etc/letsencrypt/live/${CRM_DOMAIN}/fullchain.pem" ]; then
    echo "   https://${CRM_DOMAIN}"
    echo ""
    echo "   Login with admin account (created on first access)"
else
    echo "   http://${CRM_DOMAIN} (HTTP only, until SSL is set up)"
fi
echo ""
echo "4. 📝 Create workspace and import contacts:"
echo "   - Settings → Workspaces"
echo "   - Create workspace for each project (GRAINEE, ROVLEX, ARBITR)"
echo "   - Import existing contacts from Supabase"
echo ""
echo "5. 🔗 Configure integrations:"
echo "   - WhatsApp Business API"
echo "   - Stripe"
echo "   - Google Workspace"
echo "   - GitHub"
echo ""
echo "6. 📊 Setup Google Apps Script synchronization:"
echo "   - Create Google Sheets for contacts/deals"
echo "   - Deploy Apps Script webhook handler"
echo "   - Test sync with sample data"
echo ""

echo -e "${BLUE}📚 USEFUL COMMANDS:${NC}"
echo ""
echo "  # Check container status:"
echo "  docker ps | grep twenty"
echo ""
echo "  # View logs:"
echo "  docker compose -f ${DOCKER_COMPOSE_DIR}/docker-compose.yml logs -f twenty-api"
echo "  docker compose -f ${DOCKER_COMPOSE_DIR}/docker-compose.yml logs -f twenty-postgres-prod"
echo ""
echo "  # Restart services:"
echo "  docker compose -f ${DOCKER_COMPOSE_DIR}/docker-compose.yml restart"
echo ""
echo "  # Backup database:"
echo "  docker compose -f ${DOCKER_COMPOSE_DIR}/docker-compose.yml exec twenty-postgres-prod pg_dump -U twenty_prod_user twenty_crm_prod > ${BACKUP_DIR}/manual_$(date +%Y%m%d_%H%M%S).sql"
echo ""
echo "  # Check disk usage:"
echo "  du -sh ${DOCKER_BASE}/*"
echo ""

echo -e "${YELLOW}⚠️  IMPORTANT NOTES:${NC}"
echo ""
echo "  ✓ GRAINEE (port 3000) is NOT affected"
echo "  ✓ ROVLEX WordPress is NOT affected"
echo "  ✓ ARBITR services are NOT affected"
echo ""
echo "  📍 Twenty CRM Data:"
echo "  - Database: /docker/twenty-data/postgres"
echo "  - Redis: /docker/twenty-data/redis"
echo "  - Uploads: /docker/twenty-data/uploads"
echo "  - Backups: /docker/backups (automatic daily at 3 AM)"
echo ""
echo "  🔐 Credentials saved in: ${DOCKER_COMPOSE_DIR}/.env.production"
echo "  Keep this file safe and never commit to git!"
echo ""

echo -e "${BLUE}========================================${NC}"
echo "Deployment completed at $(date)"
echo -e "${BLUE}========================================${NC}"
