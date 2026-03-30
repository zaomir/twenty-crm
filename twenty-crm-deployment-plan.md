# 📋 Twenty CRM Deployment Plan для VDS 213.155.28.121

**Дата:** 30 марта 2026  
**Статус:** В разработке  
**Администратор:** Total  

---

## 1️⃣ Сетевая архитектура (изоляция)

### Текущее состояние VDS .121
```
nginx (port 80, 443)
├── grainee.com → localhost:3000 (React SPA)
├── rovlex.com → WordPress (SFTP managed)
├── arbitr → REST API endpoints
└── [ДРУГИЕ САЙТЫ]
```

### Новая архитектура (Twenty CRM)
```
Docker Network: twenty-network (bridge)
├── twenty-postgres-prod (PostgreSQL 15)
│   └── Port: 5433 (не конфликт с системным 5432)
│   └── Volume: /docker/twenty-data/postgres
│
├── twenty-api (Node.js API)
│   └── Port: 3001 (внутри контейнера), экспортирует на :3001 хоста
│   └── ENV: NODE_ENV=production, DATABASE_URL, API_TOKEN
│
└── twenty-web (React frontend)
    └── Port: 3002 (внутри контейнера), экспортирует на :3002 хоста
```

### nginx routing (НОВЫЕ БЛОКИ)
```nginx
# /etc/nginx/sites-available/twenty-crm

upstream twenty_api {
    server localhost:3001;
}

upstream twenty_web {
    server localhost:3002;
}

server {
    listen 80;
    server_name crm.grainee.com;  # или crm.yourdomain.com
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name crm.grainee.com;
    
    ssl_certificate /etc/letsencrypt/live/crm.grainee.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/crm.grainee.com/privkey.pem;
    
    # API routes
    location /api {
        proxy_pass http://twenty_api;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Web frontend
    location / {
        proxy_pass http://twenty_web;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 2️⃣ Docker Compose структура

**Путь:** `/docker/twenty-compose/docker-compose.yml`

Файл будет содержать:
- PostgreSQL 15 (persistent volume)
- Twenty API (Node.js)
- Twenty Web (React)
- Restart policies, health checks, logging

---

## 3️⃣ Директории на хосте

```
/docker/
├── twenty-compose/
│   ├── docker-compose.yml
│   ├── .env.production
│   └── nginx-twenty.conf
│
├── twenty-data/
│   ├── postgres/              # PostgreSQL volumes
│   ├── redis/                 # (опционально, для сессий)
│   └── uploads/               # Twenty file storage
│
└── backups/
    └── twenty-db-backup-$(date).sql
```

---

## 4️⃣ Критичные переменные окружения

```env
# PostgreSQL
POSTGRES_USER=twenty_user
POSTGRES_PASSWORD=[SECURE_RANDOM_32_CHARS]
POSTGRES_DB=twenty_prod

# Twenty API
NODE_ENV=production
DATABASE_URL=postgresql://twenty_user:PASSWORD@twenty-postgres-prod:5432/twenty_prod
API_SECRET_KEY=[SECURE_RANDOM_64_CHARS]
REDIS_URL=redis://localhost:6379

# OAuth / Internal Auth
JWT_SECRET=[SECURE_RANDOM_64_CHARS]
FRONT_BASE_URL=https://crm.grainee.com
SERVER_URL=https://crm.grainee.com

# Integrations (позже настроим)
STRIPE_API_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=...

GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...

WHATSAPP_BUSINESS_ACCOUNT_ID=...
WHATSAPP_ACCESS_TOKEN=...
```

---

## 5️⃣ Инструменты управления

### SSH + Docker commands
```bash
# SSH на VDS
ssh -i ~/.ssh/id_rsa root@213.155.28.121

# Проверить статус контейнеров
docker ps -a | grep twenty

# Просмотр логов
docker logs -f twenty-api
docker logs -f twenty-postgres-prod

# Резервная копия БД
docker exec twenty-postgres-prod pg_dump -U twenty_user twenty_prod > /docker/backups/$(date +%Y%m%d_%H%M%S).sql

# Перезапуск
docker-compose -f /docker/twenty-compose/docker-compose.yml restart

# Остановить (безопасно)
docker-compose -f /docker/twenty-compose/docker-compose.yml down
```

### Health Check эндпоинты
- API: `https://crm.grainee.com/api/health` → должен вернуть 200
- Web: `https://crm.grainee.com/` → React app loads

---

## 6️⃣ Интеграции (фаза II)

### ✅ Критичные (Week 1)
- **Supabase Database** → Синхронизация контактов из GRAINEE
- **Google Sheets** → Export leads, deals, activities
- **Google Apps Script** → Webhook dispatcher для автоматизации

### ⏳ Важные (Week 2-3)
- **WhatsApp Business API** → Send follow-ups, track delivery
- **Stripe** → Invoice integration, payment history
- **GitHub** → Link commits/PRs to deals/contacts

### 🔮 Будущее (Week 4+)
- **Telegram Bot** → Notifications, mini-CRM commands
- **Email (Gmail)** → Conversation threading
- **Slack** → Activity digest

---

## 7️⃣ Процесс развёртывания (пошагово)

### Phase 1: Infrastructure (сегодня)
1. ✅ Купить SSL cert для crm.grainee.com (или создать на существующем)
2. ✅ Создать `/docker/twenty-*` директории
3. ✅ Написать docker-compose.yml с PostgreSQL + API + Web
4. ✅ Настроить nginx routing (не затронув существующие сайты)
5. ✅ Запустить контейнеры, проверить health checks

### Phase 2: Basic Setup (завтра)
1. ✅ Первый запуск Twenty CRM (создать admin account)
2. ✅ Настроить Custom fields (для GRAINEE: monitored_place_name, rating)
3. ✅ Создать рабочие пространства (Workspaces) для каждого проекта
4. ✅ Импортировать существующие контакты (Supabase → Twenty)

### Phase 3: Integrations (неделя 1-2)
1. ✅ API token + Webhook setup
2. ✅ Google Sheets sync (Apps Script)
3. ✅ WhatsApp Business API (для GRAINEE outreach)
4. ✅ Stripe integration (платежи)

### Phase 4: ZAVOD Protocol (неделя 2-3)
1. ✅ Claude API → Planning agents (Marketer, PM, UX)
2. ✅ Google Sheets as data bus
3. ✅ Twenty CRM API calls из Cursor Background Agents
4. ✅ Документирование в FOUNDER-NOTES

---

## 8️⃣ Rollback план (на случай проблем)

```bash
# Если Twenty сломалась и нужно вернуться:

# 1. Остановить контейнеры (не удаляя волюмы)
docker-compose -f /docker/twenty-compose/docker-compose.yml down

# 2. Убрать nginx блок для twenty-crm
# sudo nano /etc/nginx/sites-enabled/twenty-crm
# sudo rm /etc/nginx/sites-enabled/twenty-crm
sudo systemctl reload nginx

# 3. Остальные сайты продолжают работать нормально
# GRAINEE: localhost:3000
# ROVLEX: WordPress
# и т.д.

# 4. Если нужны данные - восстановить из backup
docker exec twenty-postgres-prod psql -U twenty_user twenty_prod < /docker/backups/YYYY-MM-DD_HHMMSS.sql
```

---

## 9️⃣ Мониторинг

### Логирование
```bash
# Все контейнеры twenty в один файл
docker-compose -f /docker/twenty-compose/docker-compose.yml logs --follow --tail 100
```

### Автоматическая резервная копия (cron)
```bash
0 3 * * * cd /docker && docker-compose -f twenty-compose/docker-compose.yml exec -T twenty-postgres-prod pg_dump -U twenty_user twenty_prod | gzip > /docker/backups/twenty_$(date +\%Y\%m\%d).sql.gz && find /docker/backups -name "twenty_*.sql.gz" -mtime +30 -delete
```

---

## 🔟 Контрольный список перед запуском

- [ ] SSL сертификат готов (Let's Encrypt для crm.grainee.com)
- [ ] Директории созданы: `/docker/twenty-compose/`, `/docker/twenty-data/`, `/docker/backups/`
- [ ] docker-compose.yml написан и протестирован (dry-run)
- [ ] nginx конфиг добавлен и синтаксис проверен (`nginx -t`)
- [ ] GRAINEE, ROVLEX, другие сайты протестированы (всё ещё работает)
- [ ] PostgreSQL порт 5433 не конфликтует (`netstat -tulpn | grep 5433`)
- [ ] Готова база окружений (.env.production)
- [ ] Backup script настроен

---

## 📞 Следующие шаги

1. Вы подтверждаете план? Если нет — что менять?
2. Какой домен для CRM? (`crm.grainee.com`? или что-то другое?)
3. Какой SMTP сервер для email нотификаций Twenty?
4. Готовы ли вы к кратким даунтайму GRAINEE во время переконфигурации nginx?

**Я подготовлю:**
- ✅ Полный docker-compose.yml (production-ready)
- ✅ nginx конфиг для безопасного routing
- ✅ .env.production шаблон
- ✅ Скрипт развёртывания (bash)
- ✅ Интеграционные скрипты (Google Apps Script + Supabase)
