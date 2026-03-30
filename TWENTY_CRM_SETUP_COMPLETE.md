# 🚀 Twenty CRM Development Guide
**Comprehensive Step-by-Step Implementation for Total**

---

## 📋 Overview

This guide will help you deploy **Twenty CRM** on your VDS (213.155.28.121) with:
- ✅ Zero downtime for GRAINEE, ROVLEX, ARBITR
- ✅ Docker isolation (separate containers)
- ✅ Full integration with Google Workspace, WhatsApp, Supabase, Stripe
- ✅ Automated sync via Google Apps Script
- ✅ Single-window experience (CRM + Sheets + GitHub)

---

## ⏱️ Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| **Phase 1: Infrastructure** | 1 hour | Today |
| **Phase 2: Basic Setup** | 30 min | Today |
| **Phase 3: Integrations** | 2-3 hours | Tomorrow |
| **Phase 4: ZAVOD Protocol** | 1-2 days | This week |

---

## 🎯 Phase 1: Infrastructure Setup

### Step 1.1: Prepare Files Locally

You now have these files ready:

```
📁 /home/claude/
├── twenty-crm-deployment-plan.md      ← Strategic plan
├── docker-compose.yml                 ← Container config
├── .env.production                    ← Environment vars
├── twenty-crm-nginx.conf              ← Nginx routing
└── deploy-twenty.sh                   ← Deployment script
```

### Step 1.2: Transfer Files to VDS

```bash
# From your local machine:
scp -i ~/.ssh/id_rsa docker-compose.yml root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa .env.production root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa twenty-crm-nginx.conf root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa deploy-twenty.sh root@213.155.28.121:/tmp/

# SSH into VDS
ssh -i ~/.ssh/id_rsa root@213.155.28.121
```

### Step 1.3: Run Deployment Script

```bash
# On VDS:
cd /tmp
bash deploy-twenty.sh
```

**What this script does:**
1. ✅ Checks Docker installation
2. ✅ Creates directory structure (`/docker/twenty-*`)
3. ✅ Generates secure passwords in `.env.production`
4. ✅ Validates docker-compose.yml
5. ✅ Pulls Docker images (PostgreSQL, Redis, Twenty)
6. ✅ Starts containers (postgres, api, web, redis)
7. ✅ Waits for health checks
8. ✅ Configures nginx routing
9. ✅ Sets up daily backup cron
10. ✅ Returns initial credentials

### Step 1.4: Verify Installation

```bash
# Check containers are running:
docker ps | grep twenty

# Check logs:
docker logs -f twenty-api
docker logs -f twenty-postgres-prod

# Test health:
curl http://localhost:3001/health
curl http://localhost:3002/

# Check nginx config:
nginx -t
systemctl status nginx
```

**Expected output:**
```
CONTAINER ID   IMAGE                    STATUS
abc123         twentyhq/twenty-backend  Up 5 minutes (healthy)
def456         postgres:15-alpine       Up 5 minutes (healthy)
ghi789         twentyhq/twenty-frontend Up 5 minutes (healthy)
jkl012         redis:7-alpine           Up 5 minutes (healthy)
```

---

## 🛠️ Phase 2: Basic CRM Setup

### Step 2.1: Access Twenty CRM

```
URL: https://crm.grainee.com
(or http://crm.grainee.com if SSL not ready)
```

### Step 2.2: Create Admin Account

1. On first access, you'll be prompted to create admin account
2. **Email:** total@grainee.com (or your email)
3. **Password:** Strong password (save it!)
4. **Workspace name:** "GRAINEE Main"

### Step 2.3: Create Workspaces

Inside Twenty CRM:
- **Settings → Workspaces**
- Create 3 workspaces:
  - `GRAINEE` - for reputation monitoring
  - `ROVLEX` - for marketplace
  - `ARBITR` - for content network

### Step 2.4: Configure Custom Fields (GRAINEE)

For each contact in GRAINEE workspace:

```
Fields to add:
- monitored_place_name (text) - название места для мониторинга
- place_id (text) - ID места (Google, Yandex)
- rating (number) - текущий рейтинг
- review_count (number) - количество отзывов
- last_check (date) - дата последней проверки
- trend (select) → options: Up, Down, Stable
```

### Step 2.5: Generate API Token

In Twenty CRM:
- **Settings → API Tokens**
- **Create new token** for Google Apps Script integration
- Copy token: `twenty_api_xxx...` (you'll need this later)

---

## 🔗 Phase 3: Integrations

### 3.1: Google Workspace Integration

#### Create Google Sheets for CRM Data Bus

```
Create new Spreadsheet with sheets:
- Contacts (columns: ID, Name, Email, Phone, Company, LastActivity, Created, Synced)
- Deals (columns: ID, Name, Stage, Amount, ExpectedClose, Owner, Account, Synced)
- Activities (columns: ID, Type, Title, Description, ContactID, DealID, CreatedAt, Synced)
- SyncLog (columns: Timestamp, Event, Message, Status)
```

Save the **Spreadsheet ID** from URL:
```
https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/edit
```

#### Deploy Google Apps Script

1. **Open** your Google Sheet
2. **Extensions → Apps Script**
3. **Delete default code**, paste the content from:
   - `twenty-crm-google-apps-script.gs`
4. **Update constants** at top of script:
   ```javascript
   const CONFIG = {
     TWENTY_API_TOKEN: 'twenty_api_xxx...', // from step 2.5
     SPREADSHEET_ID: 'YOUR_SPREADSHEET_ID',
     // ... other config
   };
   ```
5. **Deploy as Web App**:
   - Click "Deploy"
   - Select "New deployment"
   - Type: "Web app"
   - Execute as: (your email)
   - Who has access: "Anyone"
   - Click "Deploy"
   - Copy deployment URL

#### Test Google Apps Script

```bash
# Run test function
function syncAll() { /* test */ }

# Check console for logs
```

#### Set Up Triggers

In Apps Script:
- **Triggers** (left sidebar)
- **Create new trigger**:
  - Function: `syncAll`
  - Deployment: Head
  - Event source: Time-driven
  - Type: Minutes timer
  - Interval: Every 30 minutes

### 3.2: WhatsApp Business Integration (GRAINEE)

#### Get WhatsApp Credentials

1. Go to [Meta for Business](https://business.facebook.com)
2. Create/access Business Account
3. Navigate to WhatsApp → Business Accounts
4. Create WhatsApp Business Account
5. Get credentials:
   - `WHATSAPP_BUSINESS_ACCOUNT_ID`
   - `WHATSAPP_ACCESS_TOKEN`
   - `WHATSAPP_PHONE_NUMBER_ID`

#### Update Environment

```bash
# On VDS:
nano /docker/twenty-compose/.env.production
```

Update:
```env
WHATSAPP_BUSINESS_ACCOUNT_ID=123456789000000
WHATSAPP_ACCESS_TOKEN=EAABs...
WHATSAPP_PHONE_NUMBER_ID=123456789000000
WHATSAPP_WEBHOOK_VERIFY_TOKEN=verify_token_here
```

#### Restart Containers

```bash
cd /docker/twenty-compose
docker compose restart twenty-api

# Verify webhook is ready
docker logs twenty-api | grep whatsapp
```

#### Configure Webhook in Meta

In Meta Developer App:
- **Products → WhatsApp → Configuration**
- **Webhook URL**: `https://crm.grainee.com/webhooks/whatsapp`
- **Verify token**: `verify_token_here`
- **Subscribe to fields**: messages, message_status, message_template_status_update

### 3.3: Stripe Integration

#### Get Stripe Keys

1. Go to [Stripe Dashboard](https://dashboard.stripe.com)
2. Navigate to **Developers → API Keys**
3. Copy:
   - `Secret Key` (sk_test_...)
   - `Publishable Key` (pk_test_...)

#### Get Webhook Secret

1. **Developers → Webhooks**
2. **Add endpoint**: `https://crm.grainee.com/webhooks/stripe`
3. **Select events**: customer.created, invoice.created, charge.succeeded
4. Copy **Signing secret** (whsec_...)

#### Update Configuration

```bash
nano /docker/twenty-compose/.env.production
```

Update:
```env
STRIPE_API_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

Restart:
```bash
docker compose restart twenty-api
```

### 3.4: Google OAuth Integration

#### Create Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. **Create new project**: "Twenty CRM"
3. **APIs & Services → Credentials**
4. **Create OAuth 2.0 Client**:
   - Type: Web application
   - Authorized redirect URIs:
     - `https://crm.grainee.com/api/auth/google/callback`
5. Copy:
   - `Client ID`
   - `Client Secret`

#### Update Configuration

```bash
nano /docker/twenty-compose/.env.production
```

Update:
```env
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
```

Restart:
```bash
docker compose restart twenty-api
```

### 3.5: GitHub Integration

#### Create GitHub App

1. Go to **Settings → Developer settings → GitHub Apps**
2. **New GitHub App**:
   - Name: "Twenty CRM"
   - Homepage URL: `https://crm.grainee.com`
   - Webhook URL: `https://crm.grainee.com/webhooks/github`
   - Permissions:
     - Contents: Read & write
     - Pull requests: Read & write
     - Issues: Read & write
     - Workflows: Read & write

3. After creation:
   - Copy `App ID`
   - Generate & copy `Private key`
   - Copy `Webhook secret`

#### Update Configuration

```bash
nano /docker/twenty-compose/.env.production
```

Update:
```env
GITHUB_APP_ID=123456
GITHUB_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
GITHUB_WEBHOOK_SECRET=your_secret
```

Restart:
```bash
docker compose restart twenty-api
```

---

## 🤖 Phase 4: ZAVOD Protocol Integration

### 4.1: Architecture

```
Twenty CRM API
    ↓
Google Apps Script (webhook handler)
    ↓
Google Sheets (data bus)
    ↓
Claude API (planning agents)
    ↓
[Marketer, PM, UX, SEO, Copywriter, QA agents]
    ↓
Cursor Background Agents (code execution)
```

### 4.2: Create ZAVOD Coordinator Sheet

New Google Sheet with:

```
Columns:
- AgentID (Marketer, PM, UX, SEO, Copywriter, QA)
- ProjectID (GRAINEE, ROVLEX, ARBITR)
- TaskID
- TaskDescription
- Status (Pending, In Progress, Completed, Failed)
- AssignedAt
- CompletedAt
- Output
- Error
```

### 4.3: Create Planning Agent Prompts

In Google Drive (`/ZAVOD_PROTOCOL/`):

**File: CRM_AGENT_PROMPTS.md**

```markdown
# ZAVOD CRM Coordination Prompts

## Marketer Agent
You are a marketing strategist for [PROJECT_NAME].
Your role: Analyze CRM contacts, identify outreach opportunities, 
create campaign tasks, update deal stages based on engagement.

Input: CRM Contacts sheet
Output: New campaigns, contact segments, task queue

## PM Agent
You are a product manager for [PROJECT_NAME].
Your role: Manage product roadmap, track customer feedback from CRM,
create feature requests, link issues to customer needs.

Input: CRM Deals sheet, customer feedback
Output: Feature backlog, priority updates

## UX Agent
You are a UX researcher for [PROJECT_NAME].
Your role: Identify UX pain points from CRM interactions,
design interview questions, create user journey maps.

Input: CRM Activities, customer contacts
Output: UX research plan, journey maps

[... more agents ...]
```

### 4.4: Test Workflow

```bash
# 1. Manually trigger sync from Google Sheets
# 2. Check that CRM data appears in Sheets
# 3. Run planning agent on sample contact
# 4. Verify agent outputs appear in ZAVOD task queue
# 5. Link agent output back to CRM deal
```

---

## 📊 FOUNDER-NOTES Documentation

Add to your project's FOUNDER-NOTES document:

```markdown
# TWENTY CRM SETUP

## Infrastructure
- VDS: 213.155.28.121
- Domain: crm.grainee.com
- Docker: /docker/twenty-compose/
- Data: /docker/twenty-data/
- Backups: /docker/backups/ (daily at 3 AM)

## Credentials (ENCRYPTED)
- API Token: twenty_api_[...]
- DB Password: [generated in .env.production]
- JWT Secret: [generated in .env.production]

## Workspaces
- GRAINEE (leads, ratings, reviews)
- ROVLEX (bookings, listings, orders)
- ARBITR (doctor contacts, content)

## Integrations Active
- ✅ Google Sheets (real-time sync)
- ✅ Google Drive (file storage)
- ✅ WhatsApp Business API (outreach)
- ✅ Stripe (payments)
- ✅ GitHub (code linking)
- ✅ Google OAuth (team access)

## Sync Frequency
- Contacts/Deals: Every 30 minutes
- Activities: Real-time (webhooks)
- Daily backup: 3 AM UTC

## Key Contacts
- Total (admin): total@grainee.com
- CRM API: https://crm.grainee.com/api
- Sheets data bus: [SPREADSHEET_ID]
- Apps Script webhook: [DEPLOYMENT_URL]
```

---

## ✅ Verification Checklist

After each phase, verify:

### Phase 1 ✓
- [ ] Containers running (`docker ps`)
- [ ] PostgreSQL healthy
- [ ] API responding to `/health`
- [ ] Web frontend loading
- [ ] GRAINEE still working (`localhost:3000`)
- [ ] nginx reloaded successfully

### Phase 2 ✓
- [ ] Admin account created
- [ ] All 3 workspaces exist
- [ ] Custom fields visible in GRAINEE workspace
- [ ] API token generated

### Phase 3 ✓
- [ ] Google Sheets created and synced
- [ ] Apps Script deployed as web app
- [ ] Google Apps Script sync test passed
- [ ] WhatsApp webhook configured
- [ ] Stripe webhook receiving events
- [ ] Google OAuth login works
- [ ] GitHub app created and connected

### Phase 4 ✓
- [ ] ZAVOD coordinator sheet created
- [ ] Agent prompts documented
- [ ] Test workflow completed
- [ ] FOUNDER-NOTES updated

---

## 🐛 Troubleshooting

### Problem: "crm.grainee.com not accessible"

```bash
# 1. Check nginx is running
systemctl status nginx

# 2. Check nginx config
nginx -t

# 3. Check containers
docker ps | grep twenty

# 4. Check logs
docker logs twenty-api
docker logs twenty-web
```

### Problem: "GRAINEE stopped working"

```bash
# Twenty CRM should NOT affect GRAINEE
# GRAINEE runs on localhost:3000 (direct)
# Twenty runs on :3001, :3002 (Docker, proxied through nginx)

# Verify GRAINEE:
curl http://localhost:3000

# If GRAINEE broken, it's not from Twenty CRM
# Check GRAINEE logs separately
```

### Problem: "Database connection error"

```bash
# Check PostgreSQL is healthy
docker exec twenty-postgres-prod pg_isready -U twenty_prod_user

# Check connection string in .env.production
docker exec twenty-api env | grep DATABASE_URL

# Verify network connectivity
docker network inspect twenty-network
```

### Problem: "Google Apps Script not syncing"

```bash
# 1. Check Apps Script logs
# In Google Sheets → Extensions → Apps Script → Executions tab

# 2. Verify API token
# echo $CONFIG.TWENTY_API_TOKEN in Apps Script

# 3. Check Twenty API is accessible
curl -H "Authorization: Bearer YOUR_TOKEN" https://crm.grainee.com/api/health

# 4. Run test function manually
# In Apps Script: Run → syncAll
```

---

## 📈 Monitoring & Maintenance

### Daily
- [ ] Check backup completed: `ls -lh /docker/backups/`
- [ ] Review sync logs: Google Sheets → SyncLog tab
- [ ] Monitor disk space: `df -h /docker`

### Weekly
- [ ] Review CRM activity
- [ ] Check for any failed syncs in logs
- [ ] Update integrations if needed

### Monthly
- [ ] Clean up old backups (auto-deleted after 30 days)
- [ ] Review PostgreSQL performance
- [ ] Audit API token usage

---

## 🎯 Next Steps (After Deployment)

1. **Import existing GRAINEE data**
   - Run migration script: `npx supabase db query --linked` → Export profiles to CSV → Import to Twenty

2. **Setup ROVLEX integration**
   - Connect WordPress → Twenty via REST API
   - Sync bookings and customer data

3. **Setup ARBITR integration**
   - Export doctor contacts from existing system
   - Create ARBITR workspace with custom fields

4. **Train team (if needed)**
   - Create Twenty CRM tutorial videos
   - Document standard workflows
   - Setup team workspace permissions

5. **ZAVOD Protocol rollout**
   - Start with one planning agent (e.g., Marketer)
   - Test full workflow
   - Add remaining agents
   - Monitor quality of AI decisions

---

## 💬 Questions?

This setup is complete for one person (you). If you need to add team members:

1. In Twenty CRM: **Settings → Team → Invite**
2. Each member gets separate login
3. All see same CRM data
4. Permissions configurable per workspace

---

## 📝 Version History

| Date | Version | Changes |
|------|---------|---------|
| 2026-03-30 | 1.0 | Initial deployment guide |

---

**Document created: 2026-03-30**  
**Last updated: [auto-update]**  
**Owner: Total**
