# 📦 UPGRADE.md — Обновление Twenty CRM на новую версию

---

## ⚠️ ПЕРЕД ОБНОВЛЕНИЕМ

- [ ] Есть свежий бэкап (см. MAINTENANCE.md)
- [ ] Бэкап протестирован
- [ ] Никто не работает в системе
- [ ] Запланировано в нерабочее время
- [ ] Есть план отката (ROLLBACK)

---

## 📝 Что обновляется

```
✅ Twenty CRM приложение (twentycrm/twenty Docker образ)
✅ Миграции БД (если нужны)
✅ Frontend и Backend

❌ PostgreSQL (обновляется отдельно, редко)
❌ Redis (обновляется отдельно, редко)
❌ Nginx (обновляется отдельно)
```

---

## 🔍 Шаг 0: Проверить текущую версию

```bash
# На VDS
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'VERSION'
cd /tmp/controlcenter-deploy

echo "Current image:"
docker inspect controlcenter-crm | grep Image

echo ""
echo "Compose version:"
docker compose version
VERSION

# Или локально
docker inspect $(docker ps | grep controlcenter | awk '{print $1}') | grep "Image"
```

---

## 🚀 Стандартное обновление (безопасное)

### Шаг 1: Создать бэкап

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'BACKUP'
cd /tmp/controlcenter-deploy

echo "📦 Creating backup before upgrade..."
docker exec controlcenter-postgres pg_dump \
  -U controlcenter_user \
  controlcenter_prod > backup_before_upgrade_$(date +%Y%m%d_%H%M%S).sql

if [ $? -eq 0 ]; then
  echo "✅ Backup created"
  ls -lh backup_before_upgrade_*.sql | tail -1
else
  echo "❌ Backup failed! Aborting upgrade..."
  exit 1
fi
BACKUP
```

### Шаг 2: Обновить docker-compose.yml локально

```bash
# Редактировать docker-compose.yml
nano docker-compose.yml

# Изменить:
# FROM:
#   image: twentycrm/twenty:latest
# TO:
#   image: twentycrm/twenty:v0.11.0  # или какая-то конкретная версия

# ИЛИ оставить 'latest' и просто пулить новый образ

git add docker-compose.yml
git commit -m "Upgrade: Twenty CRM to v0.11.0"
git push origin main
```

### Шаг 3: Проверить конфиг локально

```bash
# На локальной машине
docker-compose config > /tmp/config.yml

# Должно быть без ошибок
cat /tmp/config.yml | grep -E "image:|version:"
```

### Шаг 4: Скопировать на VDS

```bash
scp -i ~/.ssh/id_rsa docker-compose.yml \
  root@213.155.28.121:/tmp/controlcenter-deploy/
```

### Шаг 5: Пулить новый образ

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'PULL'
cd /tmp/controlcenter-deploy

echo "📥 Pulling new Twenty CRM image..."
docker pull twentycrm/twenty:v0.11.0  # или latest

echo ""
echo "✅ New image pulled"
docker images | grep twenty
PULL
```

### Шаг 6: Остановить контейнеры (БЕЗ -v!)

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'STOP'
cd /tmp/controlcenter-deploy

echo "🛑 Stopping containers (keeping data)..."
docker compose down

sleep 5

echo "✅ Containers stopped"
docker ps | grep controlcenter || echo "No containers running"
STOP
```

### Шаг 7: Запустить новую версию

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'UPGRADE'
cd /tmp/controlcenter-deploy

echo "🚀 Starting upgraded application..."
docker compose up -d

# Дождаться запуска (до 120 секунд)
sleep 30

echo ""
echo "📊 Container status:"
docker compose ps

echo ""
echo "📋 Checking logs for errors..."
docker logs controlcenter-crm 2>&1 | tail -50
UPGRADE
```

### Шаг 8: Дождаться завершения миграций

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'WAIT'
cd /tmp/controlcenter-deploy

echo "⏳ Waiting for migrations..."
TIMEOUT=300
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
  if docker logs controlcenter-crm 2>&1 | grep -i "successfully\|migration.*complete"; then
    echo "✅ Migrations complete!"
    break
  fi
  
  sleep 5
  ELAPSED=$((ELAPSED + 5))
  echo "⏳ Waiting... ($ELAPSED/$TIMEOUT seconds)"
done

if [ $ELAPSED -ge $TIMEOUT ]; then
  echo "⚠️ Timeout waiting for migrations"
  echo "Check logs: docker logs controlcenter-crm"
fi
WAIT
```

### Шаг 9: Проверить что приложение работает

```bash
# Локально или на VDS
curl -v http://127.0.0.1:3030/healthz
curl -v https://controlcenter.me/healthz

# Проверить GraphQL
curl -v https://controlcenter.me/graphql
```

### Шаг 10: Документировать обновление

```bash
# На локальной машине, в коммент в git
git log --oneline | head -5

# Или в файл CHANGELOG.md
cat >> CHANGELOG.md << 'EOF'

## [0.11.0] - 2026-03-30
- Upgraded Twenty CRM to v0.11.0
- Database migrations successful
- All systems operational
- Backup: backup_before_upgrade_20260330_123456.sql

EOF

git add CHANGELOG.md
git commit -m "docs: Update changelog after successful upgrade to v0.11.0"
git push origin main
```

---

## 🔄 Rollback (если что-то сломалось)

### Шаг 1: Остановить текущую версию

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'STOP'
cd /tmp/controlcenter-deploy
docker compose down
STOP
```

### Шаг 2: Удалить том (если БД повреждена)

```bash
# ОСТОРОЖНО! Это удалит данные!
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'CLEAN'
docker volume rm controlcenter_postgres_data
CLEAN
```

### Шаг 3: Вернуть старую версию в docker-compose.yml

```bash
# Локально
git checkout docker-compose.yml  # или отредактировать вручную

# Скопировать на VDS
scp -i ~/.ssh/id_rsa docker-compose.yml \
  root@213.155.28.121:/tmp/controlcenter-deploy/
```

### Шаг 4: Восстановить из бэкапа (если удалили том)

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'RESTORE'
cd /tmp/controlcenter-deploy

# Запустить только PostgreSQL
docker compose up -d postgres
sleep 10

# Восстановить бэкап
docker exec -i controlcenter-postgres psql \
  -U controlcenter_user \
  controlcenter_prod < backup_before_upgrade_*.sql

echo "✅ Restored from backup"
RESTORE
```

### Шаг 5: Запустить старую версию

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'ROLLBACK'
cd /tmp/controlcenter-deploy

echo "🔄 Rolling back to previous version..."
docker compose up -d
sleep 15

docker compose ps
docker logs controlcenter-crm 2>&1 | tail -20
ROLLBACK
```

### Шаг 6: Убедиться что всё работает

```bash
curl -k https://controlcenter.me/healthz
```

---

## 📋 Процесс обновления: Шпаргалка

```bash
# Одна команда для быстрого запуска всего:
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'UPGRADE_FULL'
cd /tmp/controlcenter-deploy

# Backup
docker exec controlcenter-postgres pg_dump -U controlcenter_user controlcenter_prod > backup_$(date +%s).sql

# Pull new image
docker pull twentycrm/twenty:latest

# Restart
docker compose down
docker compose up -d
sleep 30

# Verify
docker compose ps
docker logs controlcenter-crm | tail -50
UPGRADE_FULL
```

---

## ⚠️ Частые проблемы при обновлении

### Проблема: Migration takes too long

```bash
# Проверить что происходит
docker logs -f controlcenter-crm | grep -i migration

# Если зависла, перезапустить
docker compose down
docker compose up -d
```

### Проблема: Old image still running

```bash
# Убедиться что новый образ пулился
docker images | grep twenty

# Удалить старый
docker rmi <old_image_id>

# Перезапустить
docker compose down
docker compose up -d
```

### Проблема: Database incompatibility

```bash
# Откатиться (см. раздел ROLLBACK выше)
# Затем:
# 1. Проверить requirements в документации Twenty
# 2. Может потребоваться обновить PostgreSQL версию
```

---

## 📊 Таблица совместимости

| Twenty Version | PostgreSQL | Redis | Node |
|---|---|---|---|
| v0.10.x | 14+ | 6+ | 18+ |
| v0.11.x | 15+ | 7+ | 18+ |
| v0.12.x | 16+ | 7+ | 20+ |

---

## 🔔 Рекомендации

- **Обновляйте регулярно** — раз в месяц проверяйте обновления
- **Тестируйте сначала** — обновляйте на тестовой системе
- **Читайте release notes** — в них могут быть Breaking Changes
- **Документируйте** — записывайте когда обновили и что изменилось

---

**Версия:** 1.0  
**Последнее обновление:** 2026-03-30  
**Статус:** ✅ PRODUCTION
