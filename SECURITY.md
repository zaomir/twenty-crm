# 🔒 SECURITY.md — Руководство по безопасности controlcenter.me

---

## ⚠️ КРИТИЧНЫЕ ПРАВИЛА

- ❌ **НИКОГДА** не коммитьте `.env.production` в git
- ❌ **НИКОГДА** не храните реальные пароли в markdown
- ❌ **НИКОГДА** не делитесь паролями по email/чату
- ✅ Используйте `openssl rand -hex 32` для генерации паролей
- ✅ Ротируйте пароли каждые 90 дней
- ✅ Используйте HTTPS везде (не HTTP)

---

## 🔑 Rotation: PostgreSQL Password

### Шаг 1: Сгенерировать новый пароль

```bash
openssl rand -hex 32
# Пример вывода: a7b3c9d2e5f1g4h6i8j0k2l4m6n8o0p2
```

### Шаг 2: Обновить пароль на VDS

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SQL'
echo "🔄 Changing PostgreSQL password..."
docker exec controlcenter-postgres psql -U postgres -c \
  "ALTER USER controlcenter_user WITH PASSWORD 'a7b3c9d2e5f1g4h6i8j0k2l4m6n8o0p2';"
echo "✅ Password changed"
SQL
```

### Шаг 3: Обновить `.env` локально

```bash
# Отредактировать .env
nano .env

# Найти и обновить:
POSTGRES_PASSWORD=a7b3c9d2e5f1g4h6i8j0k2l4m6n8o0p2
```

### Шаг 4: Убедиться что PG_DATABASE_URL совпадает

**docker-compose.yml должен содержать:**
```yaml
environment:
  - PG_DATABASE_URL=postgresql://controlcenter_user:a7b3c9d2e5f1g4h6i8j0k2l4m6n8o0p2@postgres:5432/controlcenter_prod
```

**ВАЖНО:** Пароль в `PG_DATABASE_URL` должен совпадать с тем, что вы установили выше!

### Шаг 5: Перезапустить контейнеры на VDS

```bash
scp -i ~/.ssh/id_rsa .env root@213.155.28.121:/tmp/controlcenter-deploy/
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'RESTART'
cd /tmp/controlcenter-deploy
docker compose down
docker compose up -d
sleep 10
docker compose ps
RESTART
```

### Шаг 6: Проверить что всё работает

```bash
curl -k https://controlcenter.me/healthz
# Должен ответить HTTP 200
```

---

## 🔐 Rotation: APP_SECRET

### Шаг 1: Сгенерировать новый APP_SECRET

```bash
openssl rand -hex 32
# Пример: b8c4d1e9f3g5h7i9j1k3l5m7n9o1p3q5
```

### Шаг 2: Обновить `.env`

```bash
nano .env

# Обновить:
APP_SECRET=b8c4d1e9f3g5h7i9j1k3l5m7n9o1p3q5
```

### Шаг 3: Перезапустить контейнер

```bash
scp -i ~/.ssh/id_rsa .env root@213.155.28.121:/tmp/controlcenter-deploy/
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'RESTART'
cd /tmp/controlcenter-deploy
docker compose restart twenty
sleep 5
docker logs twenty | tail -20
RESTART
```

**РЕЗУЛЬТАТ:** Все активные сессии будут инвалидированы. Пользователи должны перелогиниться.

---

## 🛡️ SSL Certificate Rotation

### Шаг 1: Проверить срок действия

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "sudo certbot certificates | grep controlcenter.me"
```

### Шаг 2: Если сертификат истекает в течение 30 дней

```bash
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'SSL'
echo "🔒 Renewing SSL certificate..."
sudo certbot renew --force-renewal -d controlcenter.me
sudo systemctl reload nginx
echo "✅ Certificate renewed"
SSL
```

### Шаг 3: Автоматическое обновление

```bash
# Проверить что cron задача есть
ssh -i ~/.ssh/id_rsa root@213.155.28.121 \
  "sudo crontab -l | grep certbot"

# Если нет, добавить:
ssh -i ~/.ssh/id_rsa root@213.155.28.121 << 'CRON'
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/certbot renew --quiet && /usr/sbin/systemctl reload nginx") | crontab -
CRON
```

---

## 📋 Credential Rotation Schedule

| Компонент | Частота | Последняя ротация | Дата следующей |
|-----------|---------|-------------------|-----------------|
| POSTGRES_PASSWORD | 90 дней | YYYY-MM-DD | YYYY-MM-DD |
| APP_SECRET | 90 дней | YYYY-MM-DD | YYYY-MM-DD |
| SSL Certificate | 60 дней | Auto-renewal | Auto |

---

## 🚨 Если пароли попали в публичный git

### НЕМЕДЛЕННО:

1. **Создать новые пароли** (как выше)
2. **Обновить все на VDS**
3. **Force-push в git** (если нужно стереть историю):
   ```bash
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch .env.production' \
     --prune-empty --tag-name-filter cat -- --all
   git push --force --all
   ```

4. **Добавить `.env.production` в `.gitignore`:**
   ```bash
   echo ".env.production" >> .gitignore
   git add .gitignore
   git commit -m "Add .env.production to .gitignore"
   git push
   ```

---

## ✅ Audit Checklist

- [ ] `.env.production` не в git
- [ ] `.gitignore` содержит `.env*` и `*.env`
- [ ] Пароли генерируются `openssl rand -hex 32`
- [ ] Ротация пароля запланирована на календаре
- [ ] SSH ключи защищены passphrases
- [ ] Логи контейнеров не содержат паролей
- [ ] SSL сертификат действует > 30 дней
- [ ] Backup тестирован в последний месяц

---

## 📞 Контакты для инцидентов

- **Security Issue:** admin@controlcenter.me
- **Password Breach:** Немедленно ротируйте + обновите VDS
- **SSL Expiry:** Автоматически обновляется (cron)

---

**Версия:** 1.0  
**Последнее обновление:** 2026-03-30  
**Статус:** ✅ PRODUCTION
