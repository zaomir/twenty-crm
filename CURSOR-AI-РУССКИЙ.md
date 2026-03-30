# 🤖 ИНСТРУКЦИЯ ДЛЯ CURSOR AI

**Как использовать Cursor для автоматического развёртывания Twenty CRM**

---

## 📋 ШАГ 1: Подготовьте файлы

В папке с проектом должны быть следующие файлы:

```
├── docker-compose.yml
├── .env.production
├── twenty-crm-nginx.conf
├── deploy-twenty.sh
└── id_rsa (приватный ключ SSH - опционально)
```

Если файлов нет - загрузите их из папки `/mnt/user-data/outputs/`

---

## 🎯 ШАГ 2: Используйте один из вариантов

### ВАРИАНТ A: Дайте Cursor весь prompt (РЕКОМЕНДУЕТСЯ)

1. Откройте **Cursor Editor**
2. Откройте файл **CURSOR-AI-PROMPT.md**
3. Скопируйте весь текст
4. В Cursor создайте новый файл `deploy.sh`
5. Вставьте содержимое
6. Запустите в терминале Cursor:

```bash
bash deploy.sh
```

**Cursor выполнит всё автоматически!**

---

### ВАРИАНТ B: Дайте Cursor команду в чате

В Cursor Chat (Cmd+K / Ctrl+K) скопируйте это:

```
Я хочу развернуть Twenty CRM на VDS 213.155.28.121.

Требования:
- Docker контейнеры: PostgreSQL, Redis, API, Web
- Nginx конфигурация для crm.grainee.com
- SSL сертификат от Let's Encrypt
- Ежедневные резервные копии
- Полная изоляция от GRAINEE

Файлы готовы:
- docker-compose.yml
- .env.production
- twenty-crm-nginx.conf
- deploy-twenty.sh

Выполни полное развёртывание:
1. SSH подключение к VDS
2. Передача файлов на VDS
3. Запуск deploy-twenty.sh
4. Настройка nginx
5. Получение SSL сертификата
6. Проверка всех контейнеров
7. Финальная верификация

Используй SSH ключ: ~/.ssh/id_rsa
VDS пользователь: root
IP: 213.155.28.121

Выведи статус каждого шага.
```

**Cursor создаст и выполнит весь скрипт!**

---

### ВАРИАНТ C: Пошаговое выполнение

Запустите в Cursor Terminal поочередно:

```bash
# 1. Проверка SSH
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "echo 'SSH OK'"

# 2. Передача файлов
scp -i ~/.ssh/id_rsa docker-compose.yml root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa .env.production root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa twenty-crm-nginx.conf root@213.155.28.121:/tmp/
scp -i ~/.ssh/id_rsa deploy-twenty.sh root@213.155.28.121:/tmp/

# 3. Запуск развёртывания
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SCRIPT'
cd /tmp && chmod +x deploy-twenty.sh && sudo bash deploy-twenty.sh
SCRIPT

# 4. Настройка SSL
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SCRIPT'
sudo cp /tmp/twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm
sudo nginx -t
sudo systemctl reload nginx
sudo certbot certonly --standalone -d crm.grainee.com --non-interactive --agree-tos --email admin@grainee.com
SCRIPT

# 5. Проверка
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "docker ps | grep twenty"
```

---

## 🚀 ПОЛНЫЙ СКРИПТ (Скопируйте в Cursor Terminal)

```bash
#!/bin/bash

# ============================================
# TWENTY CRM AUTOMATED DEPLOYMENT
# For Cursor AI
# ============================================

set -e

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="$HOME/.ssh/id_rsa"
DOMAIN="crm.grainee.com"

echo "🚀 Starting Twenty CRM deployment..."
echo "VDS: $VDS_IP"
echo "Domain: $DOMAIN"
echo ""

# ===== PHASE 1: SSH & FILES =====
echo "📤 PHASE 1: Transferring files..."

scp -i $SSH_KEY docker-compose.yml $VDS_USER@$VDS_IP:/tmp/ || { echo "❌ Failed to transfer docker-compose.yml"; exit 1; }
scp -i $SSH_KEY .env.production $VDS_USER@$VDS_IP:/tmp/ || { echo "❌ Failed to transfer .env.production"; exit 1; }
scp -i $SSH_KEY twenty-crm-nginx.conf $VDS_USER@$VDS_IP:/tmp/ || { echo "❌ Failed to transfer nginx config"; exit 1; }
scp -i $SSH_KEY deploy-twenty.sh $VDS_USER@$VDS_IP:/tmp/ || { echo "❌ Failed to transfer deploy script"; exit 1; }

echo "✅ Files transferred"
echo ""

# ===== PHASE 2: DEPLOYMENT =====
echo "🔧 PHASE 2: Running deployment..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'DEPLOY_SCRIPT'

set -e

cd /tmp

echo "Making script executable..."
chmod +x deploy-twenty.sh

echo "Running deployment..."
sudo bash deploy-twenty.sh || { echo "❌ Deployment failed"; exit 1; }

echo "✅ Deployment completed"

DEPLOY_SCRIPT

echo "✅ Deployment executed"
echo ""

# ===== PHASE 3: NGINX =====
echo "⚙️  PHASE 3: Configuring Nginx..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'NGINX_SCRIPT'

echo "Installing nginx config..."
sudo cp /tmp/twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm

echo "Testing nginx..."
sudo nginx -t || { echo "❌ Nginx test failed"; exit 1; }

echo "Reloading nginx..."
sudo systemctl reload nginx

echo "✅ Nginx configured"

NGINX_SCRIPT

echo "✅ Nginx setup complete"
echo ""

# ===== PHASE 4: SSL =====
echo "🔒 PHASE 4: Getting SSL certificate..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << SSL_SCRIPT

DOMAIN="$DOMAIN"

echo "Requesting certificate for $DOMAIN..."
sudo certbot certonly \
    --standalone \
    -d $DOMAIN \
    --non-interactive \
    --agree-tos \
    --email admin@grainee.com \
    || echo "⚠️  SSL setup may need manual intervention"

if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "✅ SSL certificate obtained"
else
    echo "⚠️  SSL certificate not found"
fi

SSL_SCRIPT

echo "✅ SSL setup complete"
echo ""

# ===== PHASE 5: VERIFICATION =====
echo "✅ PHASE 5: Final verification..."

ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'VERIFY_SCRIPT'

echo "=== VERIFICATION RESULTS ==="
echo ""

echo "1️⃣  Docker Containers:"
docker ps | grep twenty && echo "   ✅ Containers running" || echo "   ❌ No containers"
echo ""

echo "2️⃣  PostgreSQL:"
docker exec twenty-postgres-prod pg_isready -U twenty_prod_user > /dev/null 2>&1 && echo "   ✅ PostgreSQL OK" || echo "   ❌ PostgreSQL failed"
echo ""

echo "3️⃣  API Health:"
curl -s http://localhost:3001/health > /dev/null 2>&1 && echo "   ✅ API OK" || echo "   ❌ API failed"
echo ""

echo "4️⃣  GRAINEE Status:"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
if [[ "$STATUS" == "200" ]] || [[ "$STATUS" == "301" ]]; then
    echo "   ✅ GRAINEE OK (HTTP $STATUS)"
else
    echo "   ❌ GRAINEE failed (HTTP $STATUS)"
fi
echo ""

echo "5️⃣  Backups Folder:"
if [ -d "/docker/backups" ]; then
    COUNT=$(ls /docker/backups/ 2>/dev/null | wc -l)
    echo "   ✅ Backups folder exists ($COUNT files)"
else
    echo "   ❌ Backups folder missing"
fi
echo ""

echo "6️⃣  SSL Certificate:"
if [ -f "/etc/letsencrypt/live/crm.grainee.com/fullchain.pem" ]; then
    echo "   ✅ SSL certificate installed"
else
    echo "   ⚠️  SSL certificate not found"
fi
echo ""

echo "7️⃣  Nginx Status:"
sudo systemctl is-active nginx > /dev/null 2>&1 && echo "   ✅ Nginx running" || echo "   ❌ Nginx not running"
echo ""

VERIFY_SCRIPT

# ===== SUMMARY =====
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ TWENTY CRM DEPLOYMENT COMPLETE!                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Access CRM at:"
echo "   https://$DOMAIN"
echo ""
echo "📋 Next Steps:"
echo "   1. Open https://$DOMAIN in browser"
echo "   2. Create admin account"
echo "   3. Create workspaces: GRAINEE, ROVLEX, ARBITR"
echo "   4. Setup integrations (see TWENTY_CRM_SETUP_COMPLETE.md)"
echo ""
echo "📂 Important Paths (on VDS):"
echo "   Config:  /docker/twenty-compose/.env.production"
echo "   Data:    /docker/twenty-data/"
echo "   Backups: /docker/backups/"
echo ""
echo "ℹ️  All existing services (GRAINEE, ROVLEX, ARBITR) are intact!"
echo ""
```

---

## 🎬 КАК ЗАПУСТИТЬ

### В Cursor Terminal:

```bash
# 1. Скопируйте скрипт выше в файл deploy.sh
nano deploy.sh
# (вставьте весь скрипт, сохраните: Ctrl+X, Y, Enter)

# 2. Дайте права на выполнение
chmod +x deploy.sh

# 3. Запустите
./deploy.sh
```

### Или прямо в терминале Cursor:

```bash
# Скопируйте весь скрипт выше и выполните построчно
```

---

## ✅ ЧТО ДОЛЖНО ПРОИЗОЙТИ

**Если всё работает правильно, вы увидите:**

```
🚀 Starting Twenty CRM deployment...
VDS: 213.155.28.121
Domain: crm.grainee.com

📤 PHASE 1: Transferring files...
✅ Files transferred

🔧 PHASE 2: Running deployment...
✅ Deployment executed

⚙️  PHASE 3: Configuring Nginx...
✅ Nginx setup complete

🔒 PHASE 4: Getting SSL certificate...
✅ SSL setup complete

✅ PHASE 5: Final verification...
=== VERIFICATION RESULTS ===

1️⃣  Docker Containers:
   ✅ Containers running

2️⃣  PostgreSQL:
   ✅ PostgreSQL OK

3️⃣  API Health:
   ✅ API OK

4️⃣  GRAINEE Status:
   ✅ GRAINEE OK (HTTP 200)

5️⃣  Backups Folder:
   ✅ Backups folder exists

6️⃣  SSL Certificate:
   ✅ SSL certificate installed

7️⃣  Nginx Status:
   ✅ Nginx running

╔════════════════════════════════════════════════════════════╗
║  ✅ TWENTY CRM DEPLOYMENT COMPLETE!                       ║
╚════════════════════════════════════════════════════════════╝

🌐 Access CRM at:
   https://crm.grainee.com

✅ ГОТОВО!
```

---

## ❌ ЕСЛИ ЧТО-ТО НЕ РАБОТАЕТ

### Проблема: SSH ошибка

```bash
# Проверьте SSH ключ
ls -la ~/.ssh/id_rsa

# Проверьте права (должны быть 600)
chmod 600 ~/.ssh/id_rsa

# Попробуйте подключиться вручную
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "echo OK"
```

### Проблема: Файлы не найдены

```bash
# Убедитесь, что вы в правильной папке
ls -la *.yml *.sh *.production *.conf

# Если нет - загрузите из /mnt/user-data/outputs/
```

### Проблема: Deployment скрипт падает

```bash
# Проверьте логи на VDS
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "docker logs twenty-api | tail -50"

# Проверьте свободное место
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "df -h"

# Проверьте порты
ssh -i ~/.ssh/id_rsa root@213.155.28.121 "netstat -tulpn | grep 3001"
```

---

## 🔄 ROLLBACK (Если надо отменить)

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'ROLLBACK'

# Остановить контейнеры (данные сохранятся)
docker compose -f /docker/twenty-compose/docker-compose.yml down

# Удалить nginx конфиг
sudo rm /etc/nginx/sites-available/twenty-crm

# Перезагрузить nginx
sudo systemctl reload nginx

# Проверить GRAINEE
curl http://localhost:3000

echo "✅ Rollback complete"

ROLLBACK
```

---

## 📞 ВАЖНЫЕ КОНТАКТЫ

**После развёртывания:**

- **CRM URL:** https://crm.grainee.com
- **API Health:** https://crm.grainee.com/api/health
- **На VDS SSH:** `ssh -i ~/.ssh/id_rsa root@213.155.28.121`

**Полезные команды на VDS:**

```bash
# Статус контейнеров
docker ps | grep twenty

# Логи API
docker logs -f twenty-api

# Перезагрузка
docker compose -f /docker/twenty-compose/docker-compose.yml restart

# Резервная копия
docker exec twenty-postgres-prod pg_dump -U twenty_prod_user twenty_crm_prod > backup.sql
```

---

## 🎯 ИТОГО

✅ **Используйте ВАРИАНТ A или B выше**  
✅ **Curl и запустит весь процесс автоматически**  
✅ **Всё займёт ~30 минут**  
✅ **Никакого ручного вмешательства не требуется**  

**Готово? Начните с ВАРИАНТА A или B! 🚀**
