# Инструкция для Cursor (старт здесь)

Краткий ориентир для AI и человека: **что открыть первым** и **как не ошибиться**.

---

## 1. Главный сценарий деплоя (production)

| Действие | Файл |
|----------|------|
| **Пошаговый деплой на VDS (10 шагов)** | [`CURSOR-DEPLOYMENT-TASK.md`](CURSOR-DEPLOYMENT-TASK.md) |
| Конфиг контейнеров | `docker-compose.yml` |
| Шаблон секретов → скопировать в **`.env`** | `.env.controlcenter.example` |
| Nginx + SSL пути | `controlcenter-nginx.conf` |

**Образ:** `twentycrm/twenty:latest` · **Compose:** `docker compose` (v2), не путать со старым `docker-compose` 1.29.

**Секреты:** только в **`.env`** (в git не коммитить). `APP_SECRET`: `openssl rand -hex 32`.

**Данные БД:** `docker compose down` **без** `-v`. Флаг `-v` — только при полном сбросе томов.

---

## 2. Справочник всех документов

Список файлов и назначение: [`DOC-INDEX.md`](DOC-INDEX.md).

---

## 3. Промпт для чата Cursor (скопировать)

```text
Репозиторий twenty-crm: актуальный деплой — controlcenter.me.
Следуй только CURSOR-DEPLOYMENT-TASK.md и docker-compose.yml из корня.
Переменные окружения — из .env (копия с .env.controlcenter.example).
Не добавляй ?schema=public в URL PostgreSQL. Не предлагай docker compose down -v без явного запроса на сброс БД.
Команды — docker compose (v2).
```

---

## 4. Legacy (Grainee / старый сценарий)

Скрипт `deploy-twenty.sh`, `twenty-crm-nginx.conf`, старые разделы в `README.md` / `QUICK_START.md` относятся к сценарию **crm.grainee.com** и могут не совпадать с текущим **одиночным** `docker-compose.yml` под **twentycrm/twenty**. Для нового сервера опирайтесь на **`CURSOR-DEPLOYMENT-TASK.md`**.

---

*Обновлено: 2026-03-30*
