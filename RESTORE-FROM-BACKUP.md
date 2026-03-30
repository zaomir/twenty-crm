# 🔄 RESTORE-FROM-BACKUP.md — Восстановление из бэкапа

---

## ⚠️ КРИТИЧНЫЕ МОМЕНТЫ

- **Когда бэкапировать?** Еженедельно (см. MAINTENANCE.md)
- **Где хранить бэкапы?** На локальной машине + облако (S3, Drive и т.д.)
- **Как часто тестировать?** Минимум раз в месяц
- **Время восстановления?** 5-15 минут (зависит от размера БД)

---

## 📦 Prerequisites

Перед началом убедитесь что:

- [ ] Есть файл бэкапа: `backup_YYYYMMDD.sql`
- [ ] SSH доступ к VDS работает
- [ ] controlcenter.me развёрнут на VDS
- [ ] Достаточно свободного места на диске

---

## 🔄 Простое восстановление (без потери конфигов)

Используйте этот метод если нужно восстановить только данные БД.

### Шаг 1: Скопировать бэкап на VDS

```bash
scp -i ~/.ssh/id_rsa backup_20260330.sql \
  root@213.155.28.121:/tmp/controlcenter-deploy/
```

### Шаг 2: Остановить контейнер Twenty

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'STOP'
cd /tmp/controlcenter-deploy
docker compose down
sleep 5
STOP
```

### Шаг 3: Запустить только PostgreSQL

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'DB'
cd /tmp/controlcenter-deploy
docker compose up -d postgres
sleep 10

# Убедиться что БД работает
docker exec controlcenter-postgres psql -U postgres -c "SELECT 1;"
DB
```

### Шаг 4: Восстановить бэкап

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'RESTORE'
cd /tmp/controlcenter-deploy

echo "📥 Restoring database from backup..."
docker exec -i controlcenter-postgres psql \
  -U controlcenter_user \
  controlcenter_prod < backup_20260330.sql

echo ""
echo "✅ Restore complete"
RESTORE
```

### Шаг 5: Проверить восстановленные данные

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'VERIFY'
docker exec controlcenter-postgres psql \
  -U controlcenter_user \
  controlcenter_prod \
  -c "SELECT COUNT(*) FROM information_schema.tables;"

# Должно быть > 0 таблиц
VERIFY
```

### Шаг 6: Запустить весь стек

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'START'
cd /tmp/controlcenter-deploy
docker compose up -d
sleep 15

echo "📊 Container status:"
docker compose ps

echo ""
echo "📋 Recent logs:"
docker logs controlcenter-crm 2>&1 | tail -30
START
```

### Шаг 7: Проверить что всё работает

```bash
# Локально
curl -k https://controlcenter.me/healthz
curl -k https://controlcenter.me/graphql
```

---

## 💥 Полное восстановление (с удалением всех данных)

Используйте этот метод если нужна полная "чистая" переустановка.

### Шаг 1: Скопировать бэкап на VDS

```bash
scp -i ~/.ssh/id_rsa backup_20260330.sql \
  root@213.155.28.121:/tmp/controlcenter-deploy/
```

### Шаг 2: Остановить и удалить всё

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'FULL_STOP'
cd /tmp/controlcenter-deploy

echo "⚠️ Removing all containers and volumes..."
docker compose down -v
sleep 5

echo "🗑️ Cleaning up Docker system..."
docker system prune -a -f

echo "✅ Full cleanup complete"
FULL_STOP
```

### Шаг 3-7: Следовать инструкции "Простое восстановление" выше

(Начиная со "Шаг 3: Запустить только PostgreSQL")

---

## 🧪 Тест восстановления (еженедельно!)

### Локальный тест бэкапа

```bash
# На локальной машине
BACKUP_FILE="backup_20260330.sql"

# Проверить что файл не пустой
wc -l $BACKUP_FILE

# Проверить что он содержит SQL команды
head -50 $BACKUP_FILE | grep "CREATE\|INSERT"

# Проверить что в конце есть коммит
tail -10 $BACKUP_FILE | grep "COMMIT"
```

### Тест на временной БД (если есть)

```bash
# На отдельной системе или контейнере
docker run -d \
  --name test-postgres \
  -e POSTGRES_DB=test_db \
  -e POSTGRES_USER=test_user \
  -e POSTGRES_PASSWORD=test_pass \
  postgres:16

sleep 10

# Восстановить бэкап в тестовую БД
docker exec -i test-postgres psql \
  -U test_user \
  -d test_db < backup_20260330.sql

# Проверить
docker exec test-postgres psql \
  -U test_user -d test_db \
  -c "SELECT COUNT(*) FROM information_schema.tables;"

# Удалить тестовый контейнер
docker stop test-postgres
docker rm test-postgres
```

---

## 🔐 Шифрование и безопасность бэкапов

### Зашифровать бэкап

```bash
# Перед отправкой на облако
openssl enc -aes-256-cbc -salt -in backup_20260330.sql \
  -out backup_20260330.sql.enc

# Удалить оригинал (если уверены)
rm backup_20260330.sql

# Размер зашифрованного файла
ls -lh backup_20260330.sql.enc
```

### Расшифровать бэкап

```bash
openssl enc -aes-256-cbc -d -in backup_20260330.sql.enc \
  -out backup_20260330.sql

# Использовать для восстановления как обычно
```

---

## ☁️ Backup в облако (AWS S3)

### Загрузить в S3

```bash
# Требует AWS CLI и credentials
aws s3 cp backup_20260330.sql \
  s3://my-controlcenter-backups/backups/

# Проверить
aws s3 ls s3://my-controlcenter-backups/backups/
```

### Скачать из S3

```bash
aws s3 cp s3://my-controlcenter-backups/backups/backup_20260330.sql .

# Использовать для восстановления
```

---

## 📋 Checklist восстановления

### Перед началом
- [ ] Есть свежий бэкап
- [ ] SSH доступ работает
- [ ] Свободное место на диске (> 2GB)
- [ ] Никто не работает в системе

### Во время восстановления
- [ ] Скопировали бэкап на VDS
- [ ] Остановили контейнеры
- [ ] Запустили только PostgreSQL
- [ ] Восстановили БД из бэкапа
- [ ] Проверили восстановленные данные
- [ ] Запустили весь стек

### После восстановления
- [ ] Проверили что приложение работает
- [ ] Проверили что данные восстановились корректно
- [ ] Документировали процесс
- [ ] Уведомили пользователей (если нужно)

---

## 🆘 Если восстановление не удалось

### Не паниковать! Шаги восстановления:

1. **Проверить логи:**
   ```bash
   docker logs controlcenter-postgres 2>&1 | grep -i error
   docker logs controlcenter-crm 2>&1 | grep -i error
   ```

2. **Проверить файл бэкапа:**
   ```bash
   # Может быть файл повреждён или неправильный формат
   file backup_20260330.sql
   grep "PostgreSQL" backup_20260330.sql | head -1
   ```

3. **Попробовать другой бэкап:**
   ```bash
   # Если есть предыдущий бэкап
   docker exec -i controlcenter-postgres psql \
     -U controlcenter_user controlcenter_prod < backup_20260321.sql
   ```

4. **Полный reset и начать заново:**
   ```bash
   docker compose down -v
   docker system prune -a -f
   docker compose up -d
   # Затем восстановить
   ```

---

## 📊 Monitoring восстановления

### Во время восстановления

```bash
# В отдельном терминале мониторить прогресс
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "watch -n 5 'du -sh /var/lib/docker/volumes/controlcenter_postgres_data'"

# Смотреть логи в реальном времени
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "docker logs -f controlcenter-postgres"
```

---

## 📞 Сценарии восстановления

| Сценарий | Метод | Время | Данные |
|----------|-------|-------|--------|
| Случайное удаление данных | Простое восстановление | 5-10 мин | Полностью |
| Коррупция БД | Простое восстановление | 5-10 мин | Полностью |
| Атака/взлом | Полное восстановление | 15-20 мин | Полностью |
| Потеря конфигурации | Вручную + бэкап | 20+ мин | Частично |

---

**Версия:** 1.0  
**Последнее обновление:** 2026-03-30  
**Статус:** ✅ PRODUCTION  
**Протестировано:** 2026-03-30
