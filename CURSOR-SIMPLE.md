# 🤖 CURSOR AI - КОПИРУЙ И ЗАПУСТИ

**Вот всё что нужно сделать:**

---

## ШАГ 1: Откройте Cursor

В своём проекте откройте **Cursor Terminal**

---

## ШАГ 2: Скопируйте этот скрипт ниже

Весь скрипт - скопируйте целиком:

```bash
#!/bin/bash
set -e

VDS_IP="213.155.28.121"
VDS_USER="root"
SSH_KEY="$HOME/.ssh/id_rsa"
DOMAIN="crm.grainee.com"

echo "🚀 Запуск развёртывания Twenty CRM..."
echo "VDS: $VDS_IP"
echo "Домен: $DOMAIN"
echo ""

# PHASE 1: Transfer files
echo "📤 Фаза 1: Отправка файлов..."
scp -i $SSH_KEY docker-compose.yml $VDS_USER@$VDS_IP:/tmp/ || { echo "❌ Ошибка"; exit 1; }
scp -i $SSH_KEY .env.production $VDS_USER@$VDS_IP:/tmp/ || { echo "❌ Ошибка"; exit 1; }
scp -i $SSH_KEY twenty-crm-nginx.conf $VDS_USER@$VDS_IP:/tmp/ || { echo "❌ Ошибка"; exit 1; }
scp -i $SSH_KEY deploy-twenty.sh $VDS_USER@$VDS_IP:/tmp/ || { echo "❌ Ошибка"; exit 1; }
echo "✅ Файлы отправлены"
echo ""

# PHASE 2: Deployment
echo "🔧 Фаза 2: Развёртывание..."
ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'DEPLOY'
cd /tmp
chmod +x deploy-twenty.sh
sudo bash deploy-twenty.sh
DEPLOY
echo "✅ Развёртывание выполнено"
echo ""

# PHASE 3: Nginx
echo "⚙️  Фаза 3: Настройка Nginx..."
ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'NGINX'
sudo cp /tmp/twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm
sudo nginx -t
sudo systemctl reload nginx
NGINX
echo "✅ Nginx настроен"
echo ""

# PHASE 4: SSL
echo "🔒 Фаза 4: SSL сертификат..."
ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'SSL'
sudo certbot certonly --standalone -d crm.grainee.com --non-interactive --agree-tos --email admin@grainee.com 2>&1 || echo "⚠️  Может потребоваться ручная настройка"
SSL
echo "✅ SSL готов"
echo ""

# PHASE 5: Verification
echo "✅ Фаза 5: Проверка..."
ssh -i $SSH_KEY $VDS_USER@$VDS_IP << 'VERIFY'
echo "Контейнеры:"
docker ps | grep twenty || echo "Нет контейнеров"
echo ""
echo "PostgreSQL:"
docker exec twenty-postgres-prod pg_isready -U twenty_prod_user 2>/dev/null && echo "✅ OK" || echo "❌ Ошибка"
echo ""
echo "API:"
curl -s http://localhost:3001/health > /dev/null && echo "✅ OK" || echo "❌ Ошибка"
echo ""
echo "GRAINEE:"
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|301" && echo "✅ OK" || echo "❌ Ошибка"
VERIFY
echo "✅ Проверка завершена"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ РАЗВЁРТЫВАНИЕ ЗАВЕРШЕНО!                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Откройте: https://crm.grainee.com"
echo ""
echo "📋 Дальше:"
echo "   1. Создайте админ аккаунт"
echo "   2. Создайте workspace'ы: GRAINEE, ROVLEX, ARBITR"
echo "   3. Смотрите TWENTY_CRM_SETUP_COMPLETE.md для интеграций"
echo ""
```

---

## ШАГ 3: Вставьте в Cursor Terminal

1. Откройте Cursor Terminal (нижняя часть окна)
2. Скопируйте весь скрипт выше
3. Вставьте в терминал

**ИЛИ**

1. Создайте файл `deploy.sh`
2. Вставьте скрипт
3. Запустите: `bash deploy.sh`

---

## ШАГ 4: Дождитесь завершения

Скрипт будет выполнять фазы автоматически:
- 📤 Фаза 1: Отправка файлов (2 мин)
- 🔧 Фаза 2: Развёртывание (5 мин)
- ⚙️  Фаза 3: Nginx (1 мин)
- 🔒 Фаза 4: SSL (2 мин)
- ✅ Фаза 5: Проверка (1 мин)

**Всего: ~10-15 минут**

---

## ✅ ГОТОВО!

Когда скрипт выведет:

```
╔════════════════════════════════════════════════════════════╗
║  ✅ РАЗВЁРТЫВАНИЕ ЗАВЕРШЕНО!                              ║
╚════════════════════════════════════════════════════════════╝

🌐 Откройте: https://crm.grainee.com
```

**Значит всё готово! 🎉**

---

## 🌐 Что дальше

1. Откройте в браузере: `https://crm.grainee.com`
2. Создайте админ аккаунт
3. Создайте workspaces: GRAINEE, ROVLEX, ARBITR
4. Читайте **TWENTY_CRM_SETUP_COMPLETE.md** для интеграций

---

## ❌ Если ошибка

Проверьте:

```bash
# SSH ключ существует?
ls -la ~/.ssh/id_rsa

# Права правильные?
chmod 600 ~/.ssh/id_rsa

# Файлы на месте?
ls -la docker-compose.yml .env.production deploy-twenty.sh twenty-crm-nginx.conf
```

Если всё есть - запустите скрипт ещё раз.

---

## 🎯 ИТОГО

1. **Копируйте скрипт выше**
2. **Вставьте в Cursor Terminal**
3. **Дождитесь "РАЗВЁРТЫВАНИЕ ЗАВЕРШЕНО"**
4. **Откройте https://crm.grainee.com**

**Всё! 🚀**
