# Инструкция для Cursor (старт здесь)

Краткий ориентир для AI и человека: **что открыть первым** и **как не ошибиться**.

**Прогресс проекта (фазы, сроки, чеклисты):** [`STATUS.md`](STATUS.md)

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

## 2.1 Задачи продукта (Help, ROADMAP, интеграции)

| Задача | Документ |
|--------|----------|
| Help в Settings → Help | [`CURSOR-TASK-1-HELP-PAGE.md`](CURSOR-TASK-1-HELP-PAGE.md) |
| Реализация ROADMAP | [`CURSOR-TASK-2-ROADMAP.md`](CURSOR-TASK-2-ROADMAP.md) |
| Google Calendar, Contacts, Todoist | [`CURSOR-TASK-3-INTEGRATIONS.md`](CURSOR-TASK-3-INTEGRATIONS.md) |
| **Все три — один промпт** | [`CURSOR-CHAT-PROMPT.md`](CURSOR-CHAT-PROMPT.md) |
| **Полный промпт с реальной архитектурой Twenty (v2)** | [`CURSOR-FINAL-PROMPT-v2-ACTUAL-TWENTY-ARCH.md`](CURSOR-FINAL-PROMPT-v2-ACTUAL-TWENTY-ARCH.md) |
| Альтернатива / полный мастер-промпт | [`CURSOR-MASTER-PROMPT-FULL.md`](CURSOR-MASTER-PROMPT-FULL.md) |

Справочные материалы: [`IN-APP-HELP-PAGE.md`](IN-APP-HELP-PAGE.md), [`ROADMAP.md`](ROADMAP.md), [`INTEGRATIONS.md`](INTEGRATIONS.md), [`HOW-TO-USE.md`](HOW-TO-USE.md), [`USER-GUIDE.md`](USER-GUIDE.md).

Для разработки в форке **`twentyhq/twenty`** используйте в первую очередь **`CURSOR-FINAL-PROMPT-v2-ACTUAL-TWENTY-ARCH.md`** (Yarn 4, `SettingsPath`, `MessageQueue`, `TaskWorkspaceEntity`, `SecretEncryptionService`).

---

## 3. Промпт для чата Cursor (короткий — деплой)

```text
Репозиторий twenty-crm: актуальный деплой — controlcenter.me.
Следуй только CURSOR-DEPLOYMENT-TASK.md и docker-compose.yml из корня.
Переменные окружения — из .env (копия с .env.controlcenter.example).
Не добавляй ?schema=public в URL PostgreSQL. Не предлагай docker compose down -v без явного запроса на сброс БД.
Команды — docker compose (v2).
```

Для **Help + ROADMAP + интеграции** используйте полный текст из [`CURSOR-CHAT-PROMPT.md`](CURSOR-CHAT-PROMPT.md).

---

## 4. Legacy (Grainee / старый сценарий)

Скрипт `deploy-twenty.sh`, `twenty-crm-nginx.conf`, старые разделы в `README.md` / `QUICK_START.md` относятся к сценарию **crm.grainee.com** и могут не совпадать с текущим **одиночным** `docker-compose.yml` под **twentycrm/twenty**. Для нового сервера опирайтесь на **`CURSOR-DEPLOYMENT-TASK.md`**.

---

*Обновлено: 2026-03-30*
