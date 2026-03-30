# CURSOR-DEPLOYMENT-TASK: Twenty CRM (controlcenter.me) на VDS

Документ для копирования в Cursor: **10 шагов**, проверки после шагов, **troubleshooting**.  
**Репозиторий:** https://github.com/zaomir/twenty-crm  

---

## Критично (прочитать до команд)

1. **`.env`** — Docker Compose читает **`.env`** рядом с `docker-compose.yml` (не `.env.production`, если явно не настроено иное). Копировать: `.env.controlcenter.example` → `.env`.
2. **`down` без `-v`** — `docker compose down -v` **удаляет тома** и данные PostgreSQL. Для обновлений: **`docker compose down`** без `-v`. Флаг `-v` только при осознанном сбросе БД.
3. **`PG_DATABASE_URL`** — в строке подключения **не** использовать `?schema=public` (в репозиторном `docker-compose.yml` уже собрано без этого).
4. **Секреты** — в инструкции **нет** реальных паролей; в `.env` задайте свои (`openssl rand -hex 32` для `APP_SECRET`).

---

## Шаг 1 — Код с GitHub

На VDS или локально:

```bash
git clone https://github.com/zaomir/twenty-crm.git
cd twenty-crm
git pull origin main
```

**Проверка:** `git log -1 --oneline` — актуальный `main`.

---

## Шаг 2 — Файл `.env`

```bash
cp .env.controlcenter.example .env
nano .env   # или vim
```

Заполнить минимум: `POSTGRES_PASSWORD`, `APP_SECRET` (`openssl rand -hex 32`), при необходимости `SERVER_URL`, `POSTGRES_*`.

**Проверка:** в `.env` нет плейсхолдеров `change_me` для production.

---

## Шаг 3 — Docker и Compose v2

```bash
docker --version
docker compose version
```

**Проверка:** есть подкоманда `docker compose` (v2). Старый `docker-compose` 1.29 на хосте может давать ошибки — см. troubleshooting.

---

## Шаг 4 — Валидация compose

```bash
docker compose config
```

**Проверка:** без ошибок, переменные подставились.

---

## Шаг 5 — (Опционально) Копия на VDS с локальной машины

Если правите не на сервере, а с ноутбука:

```bash
ssh root@YOUR_VDS_IP "mkdir -p /tmp/controlcenter-deploy"
scp docker-compose.yml .env controlcenter-nginx.conf root@YOUR_VDS_IP:/tmp/controlcenter-deploy/
ssh root@YOUR_VDS_IP "ls -lah /tmp/controlcenter-deploy/"
```

**Проверка:** на VDS есть три файла (не коммитьте `.env` в git).

Дальнейшие шаги выполнять **на VDS** в каталоге с `docker-compose.yml` (например `cd /tmp/controlcenter-deploy` или `~/twenty-crm`).

---

## Шаг 6 — Перезапуск стека без потери данных

```bash
cd /path/to/compose-dir   # где лежат docker-compose.yml и .env
docker compose ps
docker compose down        # БЕЗ -v
docker compose up -d
sleep 15
docker compose ps
```

**Проверка:** контейнеры `twenty`, `postgres`, `redis` — `running` / `healthy` (у `twenty` до ~2 минут из-за `start_period`).

---

## Шаг 7 — Логи приложения

```bash
docker compose logs -f twenty
# Ctrl+C для выхода
docker logs controlcenter-crm 2>&1 | tail -40
```

**Проверка:** нет `APP_SECRET is not set`; есть признаки успешного старта приложения.

---

## Шаг 8 — HTTP с хоста VDS

```bash
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:3030/healthz
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:3030/graphql
```

**Проверка:** коды **200** (при необходимости подождать после `up`).

---

## Шаг 9 — Nginx и SSL

```bash
sudo mkdir -p /var/www/certbot
sudo cp controlcenter-nginx.conf /etc/nginx/sites-available/controlcenter
sudo ln -sf /etc/nginx/sites-available/controlcenter /etc/nginx/sites-enabled/controlcenter
sudo nginx -t && sudo systemctl reload nginx
```

Сертификат:

- **Webroot** (если порт 80 отдаёт nginx и есть `/.well-known` в конфиге):  
  `sudo certbot certonly --webroot -w /var/www/certbot -d controlcenter.me`
- **Standalone** (нужно временно остановить nginx, занять :80):  
  `sudo systemctl stop nginx && sudo certbot certonly --standalone -d controlcenter.me && sudo systemctl start nginx`

**Проверка:** `sudo nginx -t` успешен; после выпуска сертификата — `curl -sS -o /dev/null -w "%{http_code}\n" https://controlcenter.me/healthz` → **200**.

---

## Шаг 10 — Финальная проверка

```bash
docker ps | grep controlcenter
sudo systemctl is-active nginx
docker logs controlcenter-crm 2>&1 | tail -30
```

**Проверка:** контейнеры работают, nginx active, в хвосте логов нет критичных ошибок.

---

## Чеклист успеха

- [ ] `git pull` / файлы на VDS актуальны  
- [ ] `.env` из шаблона, секреты свои  
- [ ] `docker compose down` **без** `-v`, затем `up -d`  
- [ ] `docker compose ps` — сервисы подняты  
- [ ] `127.0.0.1:3030/healthz` — 200  
- [ ] Nginx: `nginx -t` OK, reload выполнен  
- [ ] HTTPS `/healthz` — 200  

---

## Troubleshooting

| Симптом | Действие |
|--------|----------|
| `APP_SECRET is not set` | Заполнить `APP_SECRET` в `.env`, затем `docker compose up -d --force-recreate twenty` |
| Ошибка `schema` / psql в логах | Не добавлять `?schema=public` в URL БД |
| `http+docker` / старый compose | Установить Compose v2, вызывать **`docker compose`** |
| Сеть / iptables у контейнеров | На хосте: `sudo systemctl restart docker`, снова `docker compose up -d` |
| Nginx 502 | `docker compose ps`, `curl 127.0.0.1:3030` и `:3040`, логи `twenty` |
| Certbot не проходит | Для webroot: блок `/.well-known/acme-challenge/` в HTTP **до** редиректа на HTTPS (см. `controlcenter-nginx.conf`) |
| Контейнер не стартует | `docker compose logs twenty`, `docker compose ps` |

---

## Файлы в репозитории

| Файл | Назначение |
|------|------------|
| `docker-compose.yml` | twenty / postgres / redis |
| `.env.controlcenter.example` | Шаблон `.env` |
| `controlcenter-nginx.conf` | Прокси :3030 / :3040, SSL пути |
| `CURSOR-DEPLOYMENT-TASK.md` | Этот документ |

*Обновлено: 2026-03-30*
