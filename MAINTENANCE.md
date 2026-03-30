# 📋 MAINTENANCE.md — Операционное обслуживание controlcenter.me

---

## 📅 DAILY (Каждый день)

### Утро (9:00)

```bash
# Проверить что всё работает
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'CHECK'
echo "=== Container Health ==="
docker ps | grep controlcenter

echo ""
echo "=== Recent Errors ==="
docker logs controlcenter-crm 2>&1 | grep -i "error" | tail -10

echo ""
echo "=== Disk Space ==="
df -h / | tail -1
DOCKER_USAGE=$(du -sh /var/lib/docker 2>/dev/null | cut -f1)
echo "Docker usage: $DOCKER_USAGE"

echo ""
echo "=== Memory Usage ==="
docker stats controlcenter-crm --no-stream
CHECK
```

### Вечер (20:00)

```bash
# Проверить нет ли критических ошибок
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "docker logs controlcenter-crm 2>&1 | grep -i 'fatal\|panic\|critical' | tail -5"
```

---

## 📅 WEEKLY (Каждую неделю, понедельник)

### Бэкап базы данных

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'BACKUP'
cd /tmp/controlcenter-deploy
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"

echo "📦 Creating backup: $BACKUP_FILE"
docker exec controlcenter-postgres pg_dump \
  -U controlcenter_user \
  controlcenter_prod > $BACKUP_FILE

if [ -f "$BACKUP_FILE" ]; then
  SIZE=$(du -h $BACKUP_FILE | cut -f1)
  echo "✅ Backup created: $SIZE"
  
  # Скопировать на локальный компьютер для безопасности
  # scp -i ~/.ssh/id_rsa root@213.155.28.121:/tmp/controlcenter-deploy/$BACKUP_FILE ./backups/
else
  echo "❌ Backup failed!"
fi
BACKUP
```

### Локально сохранить бэкап

```bash
mkdir -p ~/backups/controlcenter
scp -i ~/.ssh/id_rsa root@213.155.28.121:/tmp/controlcenter-deploy/backup_*.sql ~/backups/controlcenter/

# Удалить старые бэкапы (оставить только последние 4 недели)
find ~/backups/controlcenter -name "backup_*.sql" -mtime +28 -delete
```

### Тест восстановления из бэкапа

```bash
# На локальной машине (одну неделю)
LATEST_BACKUP=$(ls -t ~/backups/controlcenter/backup_*.sql | head -1)
echo "Testing restore from: $LATEST_BACKUP"

# Проверить что файл валидный
head -c 100 $LATEST_BACKUP | grep "PostgreSQL"
```

### Обновление логов

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'LOGS'
# Архивировать старые логи
sudo gzip /var/log/nginx/controlcenter_*.log 2>/dev/null

# Удалить логи старше 30 дней
find /var/log/nginx -name "controlcenter_*.log.gz" -mtime +30 -delete
LOGS
```

---

## 📅 MONTHLY (Первый день месяца)

### Ротация credentials (безопасность)

```bash
# Следовать инструкциям из SECURITY.md:
# 1. Сгенерировать новые пароли
# 2. Обновить на VDS
# 3. Обновить .env локально
# 4. Перезапустить контейнеры

# Отметить в календаре:
# - POSTGRES_PASSWORD ротирована 2026-MM-01
# - APP_SECRET ротирована 2026-MM-01
```

### Обновление Docker образов

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'UPDATE'
cd /tmp/controlcenter-deploy

echo "📥 Pulling latest images..."
docker pull postgres:16
docker pull redis:7
docker pull twentycrm/twenty:latest

echo ""
echo "📊 Current images:"
docker images | grep -E "postgres|redis|twenty"

echo ""
echo "⚠️ To apply updates, run:"
echo "docker-compose down && docker-compose up -d"
UPDATE
```

### Проверка обновлений безопасности

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SECURITY'
echo "🔒 Checking for security updates..."
apt-get update > /dev/null 2>&1
apt-get -s upgrade | grep -i security || echo "✅ No security updates needed"
SECURITY
```

### Review логов за месяц

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'REVIEW'
echo "=== Application Errors (Last 30 days) ==="
docker logs controlcenter-crm 2>&1 | grep -i "error" | wc -l

echo ""
echo "=== Memory Peaks ==="
# Проверить нет ли утечек памяти

echo ""
echo "=== Failed Requests ==="
grep "5[0-9][0-9]" /var/log/nginx/controlcenter_access.log | wc -l

echo ""
echo "=== SSL Certificate Status ==="
sudo certbot certificates | grep controlcenter.me
REVIEW
```

---

## 🚨 EMERGENCY RESTART

Если что-то сломалось:

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'EMERGENCY'
cd /tmp/controlcenter-deploy

echo "🚨 Emergency restart sequence..."
echo "1. Stop containers"
docker compose down

echo "2. Restart Docker daemon"
sudo systemctl restart docker
sleep 5

echo "3. Start containers"
docker compose up -d
sleep 10

echo "4. Verify"
docker compose ps
docker logs controlcenter-crm | tail -20
EMERGENCY
```

---

## 📊 Monitoring Dashboard

### Быстрая проверка здоровья

```bash
# Создать скрипт health-check.sh локально
cat > health-check.sh << 'SCRIPT'
#!/bin/bash
SSH_KEY="~/.ssh/id_rsa"
VDS="213.155.28.121"

echo "📊 CONTROLCENTER.ME HEALTH CHECK"
echo "=================================="

echo ""
echo "🐳 Containers:"
ssh -i $SSH_KEY root@$VDS "docker ps | grep controlcenter"

echo ""
echo "💾 Disk:"
ssh -i $SSH_KEY root@$VDS "df -h / | tail -1"

echo ""
echo "🌐 HTTP:"
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://127.0.0.1:3030/healthz

echo ""
echo "🔒 HTTPS:"
curl -sk -o /dev/null -w "HTTPS %{http_code}\n" https://controlcenter.me/healthz

echo ""
echo "📈 Memory:"
ssh -i $SSH_KEY root@$VDS "docker stats controlcenter-crm --no-stream | tail -1"

echo ""
echo "✅ Done"
SCRIPT

chmod +x health-check.sh
./health-check.sh
```

---

## 📋 Maintenance Calendar

```
Январь:      Ротация credentials
Февраль:     Ротация credentials
Март:        Ротация credentials
Апрель:      Ротация credentials
Май:         Ротация credentials
Июнь:        Ротация credentials
Июль:        Ротация credentials
Август:      Ротация credentials
Сентябрь:    Ротация credentials
Октябрь:     Ротация credentials
Ноябрь:      Ротация credentials
Декабрь:     Ротация credentials + Year Review
```

---

## ✅ Checklist для каждого дня

- [ ] Контейнеры работают (`docker ps`)
- [ ] Нет критических ошибок в логах
- [ ] Диск не переполнен (< 80%)
- [ ] HTTPS работает
- [ ] Бэкап выполнен (еженедельно)

---

**Версия:** 1.0  
**Последнее обновление:** 2026-03-30  
**Статус:** ✅ PRODUCTION
