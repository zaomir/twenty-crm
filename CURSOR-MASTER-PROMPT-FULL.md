# 🚀 CURSOR-MASTER-PROMPT.md — Полная реализация controlcenter.me до готовности

**Скопируйте ВЕСЬ ТЕКСТ МЕЖДУ ```...``` И ВСТАВЬТЕ В CURSOR CHAT (Cmd+K)**

---

```
GitHub: https://github.com/zaomir/twenty-crm
VDS: 213.155.28.121 (root, SSH доступ есть)
Todoist API Token: c159883cb5069d3c9dfd2ac3abc866d8ffd0dc65

ЦЕЛЬ: Довести controlcenter.me до production-ready состояния

════════════════════════════════════════════════════════════════════════════

ЭТАП 0: РАЗВЕДКА (ВЫПОЛНИТЬ ПЕРВЫМ!)
═════════════════════════════════════════════════════════════════════════════

TASK 0.1: Разведка инфраструктуры на VDS
───────────────────────────────────────────

SSH в VDS и выполнить:

1. УЗНАТЬ ЯЗЫК И ФРЕЙМВОРК:
   ssh root@213.155.28.121 << 'EOF'
   cd /root && find . -maxdepth 2 -name "package.json" -o -name "requirements.txt" -o -name "pom.xml" | head -5
   find . -maxdepth 2 -name ".git" -type d | head -5
   ls -la /root/
   EOF

2. УЗНАТЬ ПУТЬ К TWENTY:
   ssh root@213.155.28.121 << 'EOF'
   docker ps | grep twenty
   docker inspect $(docker ps | grep twenty | awk '{print $1}') | grep -E "WorkingDir|Source" | head -10
   EOF

3. УЗНАТЬ ВЕРСИИ:
   ssh root@213.155.28.121 << 'EOF'
   node --version
   npm --version
   psql --version
   docker --version
   EOF

4. УЗНАТЬ СТРУКТУРУ TWENTY:
   ssh root@213.155.28.121 << 'EOF'
   cd /root/grainee/reviews 2>/dev/null && ls -la || cd /opt/twenty 2>/dev/null && ls -la || find / -name "package.json" -path "*/twenty*" 2>/dev/null | head -3
   EOF

РЕЗУЛЬТАТ: Report по (язык, фреймворк, версии, пути)

───────────────────────────────────────────

TASK 0.2: Разведка фронтенда
──────────────────────────────

После того как узнали путь к Twenty:

1. НАЙТИ SETTINGS КОМПОНЕНТ:
   find [ПУТЬ_К_TWENTY] -name "*Settings*" -o -name "*settings*" | grep -E "\.(jsx|tsx|js|ts)$" | head -10

2. НАЙТИ ИНТЕГРАЦИИ:
   find [ПУТЬ_К_TWENTY] -type d -name "*integr*" -o -name "*oauth*" -o -name "*google*" | head -10

3. УЗНАТЬ СТРУКТУРУ ФРОНТА:
   cd [ПУТЬ_К_TWENTY] && find . -maxdepth 3 -type d -name "src" -o -name "pages" -o -name "components" | head -5

РЕЗУЛЬТАТ: Report по структуре кода

───────────────────────────────────────────

TASK 0.3: Разведка БД
──────────────────────

1. ПОСМОТРЕТЬ ТЕКУЩИЕ ТАБЛИЦЫ:
   ssh root@213.155.28.121 << 'EOF'
   docker exec controlcenter-postgres psql -U controlcenter_user -d controlcenter_prod -c "\dt" | head -30
   EOF

2. УЗНАТЬ СТРУКТУРУ USERS:
   docker exec controlcenter-postgres psql -U controlcenter_user -d controlcenter_prod -c "\d users" 2>/dev/null || echo "users таблица не найдена"

3. УЗНАТЬ ЕСТЬ ЛИ INTEGRATIONS ТАБЛИЦА:
   docker exec controlcenter-postgres psql -U controlcenter_user -d controlcenter_prod -c "\d integrations" 2>/dev/null || echo "integrations таблица не найдена"

РЕЗУЛЬТАТ: Report по структуре БД

═════════════════════════════════════════════════════════════════════════════

ПОСЛЕ РАЗВЕДКИ (КОГДА УЗНАЛИ ВСЁ):
═════════════════════════════════════════════════════════════════════════════

ЭТАП 1: ПОМЕЩЕНИЕ HELP PAGE В SETTINGS (2-4 часа)
──────────────────────────────────────────────────

После того как узнали:
- Путь к Settings компоненту
- Структуру фронта

ДЕЛАТЬ:
1. Создать компонент HelpPage (React JSX)
   - Содержимое из https://raw.githubusercontent.com/zaomir/twenty-crm/main/IN-APP-HELP-PAGE.md
   - Table of Contents с якорями
   - Мобильная версия (responsive)

2. Добавить в Settings меню:
   - Settings → Help (новый пункт)
   - При клике открывается HelpPage
   - Или добавить ? иконку в top navigation

3. Маршрут:
   - /settings/help или встроить в Settings page

4. Стили:
   - Использовать существующие стили приложения
   - Читаемый шрифт (16px+)
   - Контрастность OK

5. Тестирование:
   - Откройте https://controlcenter.me/settings
   - Settings → Help должна открываться
   - На мобильном должна быть читаемо

КРИТЕРИИ ГОТОВНОСТИ:
✅ Settings → Help открывается
✅ Все разделы IN-APP-HELP-PAGE.md видны
✅ Table of Contents работает (якоря)
✅ На мобильном читаемо
✅ Нет ошибок в консоли браузера

═════════════════════════════════════════════════════════════════════════════

ЭТАП 2: ADMIN + ТЕСТОВЫЕ ДАННЫЕ (1-2 дня)
────────────────────────────────────────────

ДЕЛАТЬ:
1. Создать администратора:
   - Email: admin@controlcenter.me
   - Password: Generate strong (openssl rand -hex 16)
   - Организация: "Test Organization"
   
   Способ создания:
   - Через UI (Settings → Users → Add)
   - Или через БД (INSERT в users таблицу)
   - Или через API

2. Заполнить тестовые данные из wa_leads:
   - Загрузить контакты из wa_leads (500+)
   - Создать 30 компаний
   - Создать 30 сделок на разных статусах
   - Создать 20+ задач
   
   Способ загрузки:
   - Экспортировать wa_leads в CSV/JSON
   - Импортировать в controlcenter.me через API или UI
   - Или прямо в БД через SQL

3. Проверить что всё работает:
   - Contacts: видны контакты
   - Companies: видны компании
   - Deals: видны сделки на разных этапах
   - Tasks: видны задачи
   - Pipeline: показывает воронку

4. Создать бэкап:
   docker exec controlcenter-postgres pg_dump -U controlcenter_user controlcenter_prod > /tmp/backup_after_data.sql

КРИТЕРИИ ГОТОВНОСТИ:
✅ Admin можно логиниться
✅ 500+ контактов видны
✅ 30 компаний видны
✅ 30 сделок видны на разных статусах
✅ 20+ задач видны
✅ Бэкап создан

═════════════════════════════════════════════════════════════════════════════

ЭТАП 3: GOOGLE CLOUD PROJECT (1 день)
──────────────────────────────────────

ДЕЛАТЬ:
1. Создать Google Cloud Project:
   - Перейти на console.cloud.google.com
   - Создать новый проект "controlcenter-twenty"
   - Включить APIs:
     * Google Calendar API
     * Google Contacts API
   - Создать OAuth 2.0 Consent Screen (External)
   - Создать OAuth 2.0 Client ID (Web application)
     Redirect URIs:
     - https://controlcenter.me/auth/google/callback
     - https://controlcenter.me/oauth/google/callback
     - http://localhost:3000/auth/google/callback (для локального тестирования)

2. Получить credentials:
   - Client ID
   - Client Secret

3. Сохранить в .env:
   GOOGLE_CALENDAR_CLIENT_ID=xxx
   GOOGLE_CALENDAR_CLIENT_SECRET=xxx

4. Проверить что OAuth flow работает:
   - Открыть Settings → Integrations → Google Calendar
   - Кнопка "Connect to Google"
   - Перенаправляется на Google OAuth
   - После разрешения → "Connected ✅"

КРИТЕРИИ ГОТОВНОСТИ:
✅ Google Cloud Project создан
✅ Calendar + Contacts APIs включены
✅ OAuth 2.0 Client ID есть
✅ Credentials в .env
✅ OAuth flow работает в браузере

═════════════════════════════════════════════════════════════════════════════

ЭТАП 4: GOOGLE CALENDAR ИНТЕГРАЦИЯ (3-5 дней)
───────────────────────────────────────────────

ДЕЛАТЬ:
1. BACKEND:
   - Создать endpoint POST /api/integrations/google-calendar/connect
   - Обменять authorization code на access token
   - Сохранить token в БД (зашифровано!)
   - Создать endpoint POST /api/integrations/google-calendar/disconnect
   - Реализовать фоновую синхронизацию (каждые 5 минут):
     * Задачи из controlcenter.me (Tasks) → Events в Google Calendar
     * Events из Google Calendar → Tasks в controlcenter.me
     * Обновления синхронизируются

2. FRONTEND:
   - Settings → Integrations → Google Calendar
   - Input для Client ID (или auto-detect из .env)
   - Кнопка "Connect to Google Calendar"
   - При клике открывается Google OAuth
   - После авторизации: "Connected ✅"
   - Кнопка "Disconnect"
   - Toggle "Enable sync"

3. СИНХРОНИЗАЦИЯ:
   Task (controlcenter.me) ↔ Event (Google Calendar)
   - task.title → event.title
   - task.dueDate → event.start
   - task.description → event.description
   - task.completed → event.transparency
   - task.priority → event.description или color

4. ТЕСТИРОВАНИЕ:
   - Settings → Integrations → Google Calendar → Connect
   - Google OAuth flow
   - "Connected ✅"
   - Создать задачу в controlcenter.me
   - Проверить что появилась в Google Calendar
   - Изменить в Google Calendar
   - Проверить что обновилось в controlcenter.me
   - Создать событие в Google → должна быть задача в CRM

КРИТЕРИИ ГОТОВНОСТИ:
✅ Google Calendar OAuth работает
✅ Tasks ↔ Events синхронизируются
✅ Обновления работают обе стороны
✅ Синхронизация каждые 5 минут
✅ Тестирование пройдено (5+ сценариев)

═════════════════════════════════════════════════════════════════════════════

ЭТАП 5: GOOGLE CONTACTS ИНТЕГРАЦИЯ (3-5 дней)
───────────────────────────────────────────────

ДЕЛАТЬ:
1. BACKEND:
   - Использовать те же Google credentials (Calendar + Contacts API)
   - Endpoint POST /api/integrations/google-contacts/export
   - Endpoint POST /api/integrations/google-contacts/import
   - Синхронизация по email (unique key)
   - Если контакт уже есть → обновить

2. FRONTEND:
   - Settings → Integrations → Google Contacts
   - Кнопка "Export to Google Contacts"
   - Кнопка "Import from Google Contacts"
   - Toggle "Enable auto-sync"

3. СИНХРОНИЗАЦИЯ:
   Contact (controlcenter.me) ↔ Contact (Google Contacts)
   - contact.name ↔ contact.name
   - contact.email ↔ contact.email (UNIQUE KEY)
   - contact.phone ↔ contact.phone
   - contact.company ↔ contact.organization

4. ТЕСТИРОВАНИЕ:
   - Export контакт → появился в Google Contacts
   - Import контакт из Google → появился в controlcenter.me
   - Обновить контакт в controlcenter.me → обновилось в Google
   - Enable auto-sync → изменения синхронизируются автоматически

КРИТЕРИИ ГОТОВНОСТИ:
✅ Google Contacts API работает
✅ Export работает
✅ Import работает
✅ Синхронизация по email работает
✅ Обновление существующих контактов работает
✅ Тестирование пройдено (5+ сценариев)

═════════════════════════════════════════════════════════════════════════════

ЭТАП 6: TODOIST ИНТЕГРАЦИЯ (3-5 дней)
────────────────────────────────────────

Todoist API Token: c159883cb5069d3c9dfd2ac3abc866d8ffd0dc65

ДЕЛАТЬ:
1. BACKEND:
   - Endpoint POST /api/integrations/todoist/connect
     (параметры: token + project_id)
   - Endpoint POST /api/integrations/todoist/disconnect
   - Фоновая синхронизация (каждые 5 минут):
     * Tasks из controlcenter.me → Todoist
     * Tasks из Todoist → controlcenter.me
     * Статусы синхронизируются

2. FRONTEND:
   - Settings → Integrations → Todoist
   - Input для API Token (скопировать с59883cb5069d3c9dfd2ac3abc866d8ffd0dc65)
   - Dropdown для выбора проекта (получить список из Todoist API)
   - Кнопка "Connect"
   - "Connected ✅"
   - Кнопка "Disconnect"
   - Toggle "Enable sync"

3. СИНХРОНИЗАЦИЯ:
   Task (controlcenter.me) ↔ Task (Todoist)
   - task.title ↔ task.content
   - task.dueDate ↔ task.due
   - task.priority (High/Medium/Low) ↔ task.priority (p1/p2/p3)
   - task.completed ↔ task.completed

4. ТЕСТИРОВАНИЕ:
   - Settings → Integrations → Todoist
   - Paste token c159883cb5069d3c9dfd2ac3abc866d8ffd0dc65
   - Select project
   - "Connected ✅"
   - Создать задачу в controlcenter.me
   - Появилась в Todoist
   - Отметить в Todoist выполненной
   - Обновилось в controlcenter.me
   - Создать задачу в Todoist
   - Появилась в controlcenter.me

КРИТЕРИИ ГОТОВНОСТИ:
✅ Todoist API token работает
✅ Tasks ↔ Todoist синхронизируются
✅ Статусы синхронизируются
✅ Приоритеты синхронизируются
✅ Синхронизация каждые 5 минут
✅ Тестирование пройдено (5+ сценариев)

═════════════════════════════════════════════════════════════════════════════

ЭТАП 7: ФИНАЛЬНЫЕ ПРОВЕРКИ (1-2 дня)
──────────────────────────────────────

1. SECURITY:
   ✅ Credentials зашифрованы в БД
   ✅ Нет паролей в логах
   ✅ Нет credentials в GitHub
   ✅ HTTPS везде (не HTTP)

2. PRODUCTION:
   ✅ Логи чистые (нет ошибок)
   ✅ Memory < 500MB
   ✅ CPU < 10%
   ✅ Диск < 50% заполнен
   ✅ Health checks 100%

3. ФУНКЦИОНАЛЬНОСТЬ:
   ✅ Help Page в Settings
   ✅ Admin работает
   ✅ Данные загружены (500+ контакты)
   ✅ Google Calendar синхронизируется
   ✅ Google Contacts синхронизируются
   ✅ Todoist синхронизируется

4. БЭКАП:
   ✅ Финальный бэкап создан
   ✅ Бэкап протестирован (восстановление)

5. DOCUMENTATION:
   ✅ README обновлён
   ✅ INTEGRATIONS.md актуален
   ✅ STATUS.md обновлён

6. DEPLOYMENT:
   ✅ Все commited в GitHub
   ✅ VDS обновлён с последней версией
   ✅ Docker контейнеры перезагружены

ИТОГ: controlcenter.me READY FOR PRODUCTION ✅

═════════════════════════════════════════════════════════════════════════════

ДЕЙСТВОВАТЬ ПО ПОРЯДКУ:

1. ⏳ ЭТАП 0 (РАЗВЕДКА) — выполнить ssh команды, report
2. ⏳ ЭТАП 1 (HELP) — 2-4 часа
3. ⏳ ЭТАП 2 (DATA) — 1-2 дня
4. ⏳ ЭТАП 3 (GOOGLE PROJECT) — 1 день
5. ⏳ ЭТАП 4 (GOOGLE CALENDAR) — 3-5 дней
6. ⏳ ЭТАП 5 (GOOGLE CONTACTS) — 3-5 дней
7. ⏳ ЭТАП 6 (TODOIST) — 3-5 дней
8. ⏳ ЭТАП 7 (FINAL) — 1-2 дня

TOTAL: ~2-3 недели до production-ready

═════════════════════════════════════════════════════════════════════════════

ЕСЛИ ЧТО-ТО НЕПОНЯТНО:
- SSH команды выполняйте на VDS (root@213.155.28.121)
- Код писать в [ПУТЬ_К_TWENTY] (узнать из ЭТАПА 0)
- После каждого этапа делать git commit
- После каждого этапа тестировать в браузере: https://controlcenter.me
- Если ошибка — проверить логи: docker logs controlcenter-crm

НАЧНИТЕ С ЭТАПА 0 РАЗВЕДКИ! 🚀
```

---

## 📋 ИНСТРУКЦИЯ КАК ИСПОЛЬЗОВАТЬ ЭТОТ ПРОМПТ

1. **Откройте Cursor Chat** (Cmd+K на Mac, Ctrl+K на Windows)

2. **Скопируйте ВСЁ между ```...```** (начиная с "GitHub: https://github.com/zaomir/twenty-crm" и кончая "НАЧНИТЕ С ЭТАПА 0")

3. **Вставьте в Cursor Chat** (Cmd+V / Ctrl+V)

4. **Нажмите ENTER**

5. **Cursor начнёт:**
   - ЭТАП 0: Разведка (SSH команды на VDS)
   - ЭТАП 1-7: Реализация всего

---

## ✅ ГОТОВО!

Cursor сам разберётся во всём, выполнит все этапы и доведёт controlcenter.me до production-ready состояния.

**Скопируйте в Cursor Chat сейчас! 🚀**
