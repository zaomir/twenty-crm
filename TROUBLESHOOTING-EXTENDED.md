# 🔧 TROUBLESHOOTING-EXTENDED.md — Расширенный гайд по отладке

---

## 🐳 Container Won't Start

### Быстрая диагностика

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'DIAG'
cd /tmp/controlcenter-deploy

echo "=== Container Status ==="
docker compose ps

echo ""
echo "=== Last 100 lines of logs ==="
docker logs controlcenter-crm 2>&1 | tail -100

echo ""
echo "=== Check if ports are free ==="
netstat -tulpn 2>/dev/null | grep -E "3030|3040|5434|6381"
DIAG
```

### Проблема: Port already in use

```bash
# Узнать что занимает порт
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "lsof -i :3030 2>/dev/null || netstat -tulpn 2>/dev/null | grep 3030"

# Если это старый контейнер
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'FIX'
docker ps -a | grep controlcenter
docker rm -f <container_id>
docker compose up -d
FIX
```

### Проблема: .env file not found

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'FIX'
cd /tmp/controlcenter-deploy

if [ ! -f .env ]; then
  echo "❌ .env not found!"
  echo "✅ Creating from example..."
  cp .env.example .env
  # Или скопировать с локальной машины
  # scp .env root@213.155.28.121:/tmp/controlcenter-deploy/
else
  echo "✅ .env found"
  wc -l .env
fi
FIX
```

### Проблема: Docker daemon не запущен

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'FIX'
sudo systemctl status docker

if [ $? -ne 0 ]; then
  echo "🔄 Starting Docker..."
  sudo systemctl start docker
  sleep 3
  sudo systemctl status docker
fi

# Убедиться что сокет доступен
ls -la /var/run/docker.sock
FIX
```

---

## 🗄️ Database Connection Issues

### Проблема: "could not connect to server"

```bash
# Проверить что PostgreSQL контейнер работает
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'DIAG'
docker compose ps | grep postgres

# Проверить логи postgres
docker logs controlcenter-postgres 2>&1 | tail -30

# Проверить что процесс прослушивает
docker exec controlcenter-postgres \
  ss -tlnp | grep 5432
DIAG
```

### Проблема: Authentication failed

```bash
# Проверить пароль в .env
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'CHECK'
cd /tmp/controlcenter-deploy
grep POSTGRES_PASSWORD .env

# Проверить что этот пароль установлен в БД
docker exec controlcenter-postgres psql -U postgres -c \
  "SELECT usename FROM pg_user WHERE usename = 'controlcenter_user';"
CHECK

# Если пароль неправильный, сменить его (см. SECURITY.md)
```

### Проблема: Database doesn't exist

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'FIX'
docker exec controlcenter-postgres psql -U postgres \
  -c "CREATE DATABASE controlcenter_prod OWNER controlcenter_user;"

# Или полностью пересоздать (ВНИМАНИЕ: потеря данных!)
docker compose down -v
docker compose up -d
FIX
```

### Test connection вручную

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'TEST'
docker exec controlcenter-postgres psql \
  -U controlcenter_user \
  -d controlcenter_prod \
  -c "SELECT version();"
TEST
```

---

## 🌐 Nginx Issues

### Проблема: 502 Bad Gateway

```bash
# Шаг 1: Проверить что backend работает
curl -v http://127.0.0.1:3030/healthz

# Шаг 2: Проверить nginx конфиг
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'NGINX'
sudo nginx -t
sudo systemctl status nginx
tail -50 /var/log/nginx/error.log
NGINX

# Шаг 3: Проверить connectivity между контейнерами
docker network inspect controlcenter-network
```

### Проблема: SSL certificate error

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SSL'
# Проверить сертификат
sudo certbot certificates | grep controlcenter.me

# Если сертификат не существует, создать его
sudo certbot certonly --standalone -d controlcenter.me \
  --non-interactive --agree-tos --email admin@controlcenter.me

# Проверить пути в nginx конфиге
grep ssl_certificate /etc/nginx/sites-available/controlcenter
SSL
```

### Проблема: Timeout при подключении

```bash
# Увеличить proxy timeouts в nginx
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'FIX'
# Отредактировать /etc/nginx/sites-available/controlcenter
# Добавить:
# proxy_connect_timeout 60s;
# proxy_send_timeout 60s;
# proxy_read_timeout 60s;

sudo nginx -t && sudo systemctl reload nginx
FIX
```

---

## 💾 Memory & Disk Issues

### Проблема: Container использует слишком много памяти

```bash
# Мониторить в реальном времени
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "docker stats controlcenter-crm"

# Если > 2GB, перезапустить
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'RESTART'
docker restart controlcenter-crm
sleep 10
docker stats controlcenter-crm --no-stream
RESTART
```

### Проблема: Disk full

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'CLEANUP'
echo "=== Disk Usage ==="
df -h /

echo ""
echo "=== Docker Usage ==="
docker system df

echo ""
echo "=== Cleaning up ==="
# Удалить неиспользуемые образы
docker image prune -a -f

# Удалить неиспользуемые томы
docker volume prune -f

# Удалить неиспользуемые сети
docker network prune -f

echo ""
echo "=== After cleanup ==="
df -h /
docker system df
CLEANUP
```

---

## 🔍 Application Errors

### Проблема: "Migration failed"

```bash
# Проверить полные логи миграции
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "docker logs controlcenter-crm 2>&1 | grep -i migration"

# Если миграция застряла, может потребоваться полный reset
# (смотрите раздел Database Reset ниже)
```

### Проблема: "Nest application failed to start"

```bash
# Проверить конфигурацию
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'CHECK'
docker logs controlcenter-crm 2>&1 | grep -i "error\|fatal" | head -20

# Проверить что все переменные окружения установлены
docker exec controlcenter-crm env | grep -E "APP_SECRET|PG_DATABASE_URL|REDIS"
CHECK
```

### Проблема: "GraphQL endpoint not responding"

```bash
# Проверить что endpoint доступен
curl -v http://127.0.0.1:3030/graphql

# Если 404, возможно неправильный путь в nginx
curl -v https://controlcenter.me/graphql
```

---

## 🔄 Database Reset (ОПАСНО!)

**⚠️ ЭТО УДАЛИТ ВСЕ ДАННЫЕ! Используйте только если понимаете что делаете!**

### Полный reset

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'RESET'
cd /tmp/controlcenter-deploy

echo "⚠️ WARNING: This will delete ALL data!"
read -p "Type 'YES' to continue: " confirm

if [ "$confirm" = "YES" ]; then
  echo "💥 Removing everything..."
  docker compose down -v
  sleep 5
  
  echo "🚀 Starting fresh..."
  docker compose up -d
  sleep 30
  
  echo "✅ Reset complete"
  docker compose ps
  docker logs controlcenter-crm | tail -50
else
  echo "❌ Cancelled"
fi
RESET
```

---

## 📊 Debugging Commands Reference

```bash
# Смотреть логи в реальном времени
docker logs -f controlcenter-crm

# Смотреть последние 100 строк
docker logs controlcenter-crm --tail 100

# Смотреть только ошибки
docker logs controlcenter-crm 2>&1 | grep -i error

# Заходить в контейнер
docker exec -it controlcenter-crm /bin/bash

# Выполнить команду в контейнере
docker exec controlcenter-crm ps aux

# Проверить сеть между контейнерами
docker network inspect controlcenter-network

# Мониторить использование ресурсов
docker stats controlcenter-crm

# Проверить конфигурацию
docker inspect controlcenter-crm | grep -A 20 "Env"
```

---

## 🆘 Если ничего не помогает

1. **Сохранить бэкап данных:**
   ```bash
   docker exec controlcenter-postgres pg_dump -U controlcenter_user \
     controlcenter_prod > backup_emergency.sql
   ```

2. **Полностью пересоздать стек:**
   ```bash
   docker compose down -v
   docker system prune -a -f
   docker compose up -d
   ```

3. **Связаться с поддержкой** с этой информацией:
   ```bash
   # Собрать всю диагностику
   docker compose ps
   docker logs controlcenter-crm 2>&1 | tail -100
   docker system df
   df -h /
   ```

---

**Версия:** 1.0  
**Последнее обновление:** 2026-03-30  
**Статус:** ✅ PRODUCTION
