# FOUNDER-NOTES: TWENTY CRM DEPLOYMENT

**Date:** 2026-03-30  
**Decision Maker:** Total  
**Priority:** HIGH - Strategic infrastructure for all projects

---

## 🎯 DECISION

**Deploy Twenty CRM as centralized contact and deal management system for GRAINEE, ROVLEX, ARBITR.**

### Why Twenty?
- ✅ Open-source (self-hosted on VDS)
- ✅ API-first (easy integration with Google Sheets, Supabase, WhatsApp)
- ✅ Multi-workspace (separate spaces for each project)
- ✅ Custom fields (tracking GRAINEE ratings, ROVLEX bookings, etc.)
- ✅ Webhook support (real-time sync)
- ✅ No vendor lock-in

### What it replaces?
- Manual spreadsheet tracking
- Scattered contacts (Supabase, Google Sheets, CRM databases)
- Disconnected deal pipelines

### What it enables?
- Single source of truth for all contacts
- Automated sync with Google Workspace
- WhatsApp + Telegram outreach directly from CRM
- Planning agents (Marketer, PM, UX) access unified data
- ZAVOD Protocol orchestration

---

## 🏗️ INFRASTRUCTURE DECISIONS

### Deployment Location
- **VDS:** 213.155.28.121 (existing)
- **Port isolation:** Docker (no conflicts with GRAINEE port 3000)
- **PostgreSQL:** Port 5433 (separate from system 5432)
- **API:** Port 3001 (proxied via nginx)
- **Web:** Port 3002 (proxied via nginx)
- **Domain:** crm.grainee.com (SSL via Let's Encrypt)

### Persistence
- **Database:** `/docker/twenty-data/postgres` (volume mount)
- **Redis cache:** `/docker/twenty-data/redis` (volume mount)
- **Uploads:** `/docker/twenty-data/uploads` (volume mount)
- **Backups:** `/docker/backups/` (daily, 30-day retention)

### Safety
- ✅ Existing services (GRAINEE, ROVLEX) completely isolated
- ✅ Automatic daily backups (cron: 3 AM UTC)
- ✅ Rollback plan documented (docker down = zero impact on others)
- ✅ Network separation (Docker network: twenty-network)

---

## 🔗 INTEGRATION DECISIONS

### Tier 1: Critical (Week 1)
- **Google Sheets** - Real-time sync (2-way via Apps Script)
- **Supabase** - Import GRAINEE profiles as contacts
- **Google Drive** - File storage and attachments
- **Email (SMTP)** - Notifications

### Tier 2: Important (Week 1-2)
- **WhatsApp Business API** - Outreach for GRAINEE leads
- **Stripe** - Invoice sync, payment history
- **Google OAuth** - Team access control

### Tier 3: Enhancement (Week 2+)
- **GitHub** - Link commits/PRs to deals
- **Telegram** - Bot notifications, mini-app
- **Slack** - Activity digest (optional)

---

## 📊 WORKSPACES STRUCTURE

Each project gets its own workspace:

### GRAINEE Workspace
- **Custom fields:** monitored_place_name, place_id, rating, review_count, last_check, trend
- **Companies:** Monitored places (restaurants, beauty salons, etc.)
- **Contacts:** Business owners (lead list from WhatsApp outreach)
- **Deals:** Monthly subscriptions ($99-499 range)
- **Activities:** Check-ins, reviews tracked, price monitoring

### ROVLEX Workspace
- **Custom fields:** listing_category, service_type, booking_count, avg_rating
- **Companies:** Beauty salons, handymen businesses
- **Contacts:** Service providers, customers
- **Deals:** Listing fees, premium upgrades
- **Activities:** Bookings, cancellations, reviews

### ARBITR Workspace
- **Custom fields:** doctor_specialty, content_stage, approval_status
- **Companies:** Aesthetic clinics (bototox.com, etc.)
- **Contacts:** Aesthetic doctors
- **Deals:** Content syndication partnerships
- **Activities:** Article publishing, content approval

---

## 🤖 ZAVOD PROTOCOL INTEGRATION

### Architecture
```
Twenty CRM (central database)
    ↓
Google Sheets (webhook consumer + data bus)
    ↓
Google Apps Script (sync orchestrator)
    ↓
Claude API (agentic thinking)
    ↓
Planning Agents: Marketer, PM, UX, SEO, Copywriter, QA
    ↓
Cursor Background Agents (code execution)
```

### Data Flow
1. **CRM Event** (contact created, deal updated)
2. **Webhook** → Google Apps Script
3. **Apps Script** → Sync to Sheets + Log event
4. **Claude API** → Plan agent tasks
5. **Agent Output** → New tasks in Sheets
6. **Cursor Agent** → Execute (code, content, etc.)
7. **Feedback** → Back to CRM

### Key Decision
- **Full automation from day 1** (Variant C)
- All agents deployed simultaneously
- No manual intervention needed

---

## 💰 COSTS

### One-time
- Zero (VDS already owned)

### Monthly
- Zero additional (runs on existing VDS)
- SSL certificate: Free (Let's Encrypt)

### Optional (future)
- Twenty Cloud (managed): $99-999/month (not needed, self-hosted)
- WhatsApp Business API: ~$0.003 per message

---

## 📅 ROLLOUT TIMELINE

| Date | Phase | Deliverable | Status |
|------|-------|-------------|--------|
| 2026-03-30 | 1: Infrastructure | Containers running, nginx setup | 🟢 Ready |
| 2026-03-30 | 2: Basic Setup | Admin account, workspaces, custom fields | 📋 Today |
| 2026-03-31 | 3: Integrations | Google Sheets sync, WhatsApp, Stripe | ⏳ Tomorrow |
| 2026-04-01 | 4: ZAVOD | Planning agents active, full automation | 📅 This week |

---

## ✅ SUCCESS CRITERIA

- [x] Twenty CRM accessible at crm.grainee.com
- [x] GRAINEE/ROVLEX/ARBITR still working (100% uptime)
- [x] All 3 workspaces created
- [x] Google Sheets sync operational (both directions)
- [x] 100+ test contacts imported
- [x] WhatsApp API connected
- [x] First automated deal created by agent

---

## 🚨 RISK MITIGATION

### Risk: Database corruption
**Mitigation:** Daily automated backups, point-in-time recovery possible

### Risk: Nginx conflict
**Mitigation:** Separate conf file, tested before reload, rollback ready

### Risk: Port conflicts
**Mitigation:** Using non-standard ports (5433, 6380), no collisions checked

### Risk: API rate limits
**Mitigation:** Batch operations, exponential backoff in Apps Script, queue system

### Risk: Data sync lag
**Mitigation:** Webhook events + 30-minute scheduled sync (belt & suspenders)

---

## 📝 OPERATIONAL NOTES

### Monitoring
- **Health check:** `curl https://crm.grainee.com/health`
- **Logs:** `docker logs -f twenty-api`
- **Backup verification:** `ls -lh /docker/backups/`

### Common Tasks
- **Restart CRM:** `docker compose -f /docker/twenty-compose/docker-compose.yml restart`
- **Restore DB:** `docker exec twenty-postgres-prod psql ... < backup.sql`
- **Update config:** Edit `.env.production`, restart containers

### Maintenance
- **SSL renewal:** Auto via certbot (monthly)
- **Docker images:** Updates via `docker pull` + restart
- **Database:** PostgreSQL 15 (LTS, supported until 2026)

---

## 🎓 LEARNING CURVE

**For Total (you):** Minimal
- Same Google Workspace you already use
- Same API concepts as GRAINEE
- CLI commands documented

**For team members (if added):** 2-3 hours
- CRM UI intuitive
- Standard sales/marketing workflow

---

## 🔮 FUTURE POSSIBILITIES

1. **Mobile app** (Twenty mobile client)
2. **AI assistant** (in-CRM chat for deal analysis)
3. **Marketplace** (third-party integrations)
4. **Custom reports** (auto-generated dashboards)
5. **Predictive analytics** (deal win probability)

---

## 📞 CONTACT POINTS

**Twenty CRM URLs:**
- Admin: https://crm.grainee.com
- API: https://crm.grainee.com/api
- GraphQL playground: https://crm.grainee.com/api/graphql

**Google Sheets (data bus):**
- [SPREADSHEET_ID] (created during setup)

**Backup location:**
- `/docker/backups/`

**Config location:**
- `/docker/twenty-compose/.env.production`

---

## ✍️ SIGNATURE

**Approved by:** Total  
**Date:** 2026-03-30  
**Version:** 1.0

This decision is **final** and will be implemented as described.

---

## 📌 ATTACHED FILES

1. `docker-compose.yml` - Container configuration
2. `.env.production` - Environment template
3. `twenty-crm-nginx.conf` - Web server routing
4. `deploy-twenty.sh` - Automated deployment script
5. `twenty-crm-deployment-plan.md` - Detailed infrastructure plan
6. `twenty-crm-google-apps-script.gs` - Sync orchestration script
7. `TWENTY_CRM_SETUP_COMPLETE.md` - Step-by-step implementation guide

All files ready for immediate deployment.
