# 🚀 CURSOR-CHAT-PROMPT.md — Готовый промпт для Cursor Chat

Скопируйте ВСЁ СОДЕРЖИМОЕ ЭТОГО ФАЙЛА И ВСТАВЬТЕ В CURSOR CHAT (Cmd+K)

---

```
GitHub репозиторий: https://github.com/zaomir/twenty-crm

ЗАДАЧА: Реализовать controlcenter.me для запуска на production

ЧТО НУЖНО СДЕЛАТЬ (3 задачи):

1️⃣ TASK 1: Встроить Help Page в Settings (2-4 часа)
────────────────────────────────────────────────
Файл: CURSOR-TASK-1-HELP-PAGE.md

СУТЬ:
- Встроить справку в Settings → Help
- Содержимое из IN-APP-HELP-PAGE.md
- Table of Contents с якорями
- Мобильная версия работает
- Поиск (Ctrl+F) работает

ТРЕБОВАНИЯ:
✅ Создать компонент HelpPage.jsx
✅ Добавить Help в Settings меню
✅ Добавить маршрут /settings/help
✅ Содержимое IN-APP-HELP-PAGE.md полное
✅ На мобильном читаемо

КРИТЕРИИ ГОТОВНОСТИ:
✅ Settings → Help открывается
✅ Все разделы видны
✅ Примеры отформатированы
✅ Таблицы читаемые
✅ Нет ошибок в консоли
✅ На мобильном хорошо выглядит

───────────────────────────────────────────────

2️⃣ TASK 2: Реализовать ROADMAP (2-4 недели по фазам)
────────────────────────────────────────────────
Файл: CURSOR-TASK-2-ROADMAP.md

СУТЬ:
Три фазы запуска controlcenter.me:

ФАЗА 1 (30 марта – 8 апреля) - КРИТИЧНО:
├─ 1.1 VDS Проверка 24/7
│   └─ docker compose ps, health checks, логи, память
├─ 1.2 Admin + тестовые данные
│   └─ admin@controlcenter.me, 500+ контакты, 30 сделок
└─ 1.3 Help Page в приложении
    └─ Settings → Help должна работать

ФАЗА 2 (8-20 апреля):
├─ 2.1 Google Calendar интеграция
├─ 2.2 Google Contacts интеграция
└─ 2.3 Todoist интеграция

ФАЗА 3 (20-27 апреля):
├─ 3.1 README + лендинг
├─ 3.2 Бета-тестеры + feedback
└─ 3.3 Официальный запуск 🎉

ТЕКУЩИЙ ПРИОРИТЕТ (ФАЗА 1):
1. Убедиться что VDS работает стабильно 24/7
   - Нет ошибок в логах
   - Memory < 500MB
   - CPU < 10%
   - Health checks 100%

2. Создать администратора:
   - Email: admin@controlcenter.me
   - Мощный пароль
   - Организация: Test

3. Заполнить тестовые данные:
   - 500+ контактов (имена, email, телефон)
   - 30 компаний
   - 30 сделок на разных статусах
   - 20+ задач

4. Встроить Help (TASK 1)

───────────────────────────────────────────────

3️⃣ TASK 3: Google Calendar, Contacts, Todoist (3-4 недели)
────────────────────────────────────────────────
Файл: CURSOR-TASK-3-INTEGRATIONS.md

СУТЬ:
Три интеграции (по очереди):

ЧАСТЬ 1: GOOGLE CALENDAR
├─ Settings → Integrations → Google Calendar
├─ Кнопка "Connect to Google Calendar"
├─ Google OAuth 2.0 flow
├─ Двусторонняя синхронизация: Tasks ↔ Google Calendar
├─ Обновления каждые 5 минут
└─ Toggle "Enable sync"

ТРЕБОВАНИЯ:
1. Google Cloud Project
   - console.cloud.google.com
   - Создать проект "controlcenter"
   - Включить Google Calendar API
   - OAuth 2.0 credentials
   - Redirect: https://controlcenter.me/auth/google/callback

2. Backend endpoints:
   - POST /api/integrations/google-calendar/connect
   - POST /api/integrations/google-calendar/disconnect
   - Background sync каждые 5 минут

3. Frontend:
   - Settings → Integrations → Google Calendar
   - "Connect" button
   - "Connected ✅" when authorized
   - "Disconnect" button
   - Toggle sync on/off

4. Синхронизация:
   - task.title ↔ event.title
   - task.dueDate ↔ event.start
   - task.priority ↔ event description/color
   - task.completed ↔ event.transparency

ТЕСТИРОВАНИЕ:
1. Connect to Google Calendar ✅
2. Создать задачу в CRM → появилась в Google ✅
3. Создать событие в Google → появилось в CRM ✅
4. Изменить дату в Google → обновилось в CRM ✅
5. Отметить задачу выполненной → обновилось в Google ✅

───

ЧАСТЬ 2: GOOGLE CONTACTS
├─ Settings → Integrations → Google Contacts
├─ Кнопка "Export to Google Contacts"
├─ Кнопка "Import from Google Contacts"
├─ Опция "Enable auto-sync"
└─ Синхронизация по email

ТРЕБОВАНИЯ:
1. Использовать те же Google credentials (Calendar + Contacts API)
2. Backend endpoints:
   - POST /api/integrations/google-contacts/export
   - POST /api/integrations/google-contacts/import
3. Frontend:
   - "Export to Google Contacts" button
   - "Import from Google Contacts" button
   - "Enable auto-sync" toggle
4. Синхронизация:
   - contact.name ↔ contact.name
   - contact.email ↔ contact.email (UNIQUE KEY)
   - contact.phone ↔ contact.phone
   - contact.company ↔ contact.organization

ТЕСТИРОВАНИЕ:
1. Export контакт → появился в Google Contacts ✅
2. Импорт контакта из Google → появился в CRM ✅
3. Изменить контакт в CRM → обновилось в Google ✅
4. Enable auto-sync → изменения синхронизируются автоматически ✅

───

ЧАСТЬ 3: TODOIST
├─ Settings → Integrations → Todoist
├─ Ввод Todoist API Token
├─ Выбор Todoist проекта
├─ Двусторонняя синхронизация: Tasks ↔ Todoist
└─ Toggle "Enable sync"

ТРЕБОВАНИЯ:
1. Получить Todoist API Token:
   - Todoist → Settings → Integrations → API token
   - Скопировать token

2. Backend endpoints:
   - POST /api/integrations/todoist/connect (с token + project_id)
   - POST /api/integrations/todoist/disconnect
   - Background sync каждые 5 минут

3. Frontend:
   - Settings → Integrations → Todoist
   - Input field для API Token
   - Dropdown для выбора проекта
   - "Connect" button
   - "Connected ✅" когда активно
   - "Disconnect" button
   - Toggle sync

4. Синхронизация:
   - task.title ↔ task.content
   - task.dueDate ↔ task.due
   - task.priority (High/Med/Low) ↔ p1/p2/p3
   - task.completed ↔ task.completed

ТЕСТИРОВАНИЕ:
1. Подключить Todoist (API token + выбрать проект) ✅
2. Создать задачу в CRM → появилась в Todoist ✅
3. Создать задачу в Todoist → появилась в CRM ✅
4. Отметить в Todoist выполненной → обновилось в CRM ✅
5. Нажать Disconnect → задачи остаются (не удаляются) ✅

═════════════════════════════════════════════

КРИТЕРИИ УСПЕХА:

✅ TASK 1:
  - Settings → Help открывается
  - Все разделы из IN-APP-HELP-PAGE.md видны
  - Table of Contents работает
  - На мобильном читаемо
  - Нет ошибок

✅ TASK 2:
  - ФАЗА 1 выполнена (VDS + admin + данные)
  - Help Page встроена в приложение
  - Фазы 2-3 в плане

✅ TASK 3:
  - ЧАСТЬ 1: Google Calendar 2-way sync работает
  - ЧАСТЬ 2: Google Contacts export/import работает
  - ЧАСТЬ 3: Todoist 2-way sync работает

═════════════════════════════════════════════

ПОРЯДОК РАБОТ:

1️⃣ СНАЧАЛА: TASK 1 (Help Page) - 2-4 часа
   └─ Проще всего, нужна базовая готовность

2️⃣ ПОТОМ: TASK 2 ФАЗА 1 (VDS + admin + данные) - несколько дней
   └─ Подготовка системы к production

3️⃣ ПОТОМ: TASK 2 ФАЗА 2-3 (раскрутка) - параллельно с TASK 3

4️⃣ ПАРАЛЛЕЛЬНО: TASK 3 (интеграции) - 3-4 недели
   ├─ ЧАСТЬ 1: Google Calendar
   ├─ ЧАСТЬ 2: Google Contacts
   └─ ЧАСТЬ 3: Todoist

═════════════════════════════════════════════

БЕЗОПАСНОСТЬ:

✅ Google Credentials:
  - .env: GOOGLE_CALENDAR_CLIENT_ID, GOOGLE_CALENDAR_CLIENT_SECRET
  - НЕ в git!
  - Зашифровано в БД

✅ Todoist Token:
  - Зашифровано в БД (AES-256)
  - НЕ в логах
  - НЕ в GitHub

✅ OAuth Flow:
  - Используйте https://
  - State parameter для защиты
  - Refresh token логика

═════════════════════════════════════════════

ДОКУМЕНТАЦИЯ:

Все требования в GitHub файлах:
- CURSOR-TASK-1-HELP-PAGE.md
- CURSOR-TASK-2-ROADMAP.md
- CURSOR-TASK-3-INTEGRATIONS.md
- INTEGRATIONS.md (инструкции для админа/пользователя)

═════════════════════════════════════════════

ГОТОВО! Начните с TASK 1.
После каждой задачи - создавайте commit с описанием.
```

---

## 📋 Как использовать этот промпт

### Шаг 1: Скопировать весь текст между ```...```

### Шаг 2: Открыть Cursor Chat

- Cmd+K (Mac)
- Ctrl+K (Windows/Linux)

### Шаг 3: Вставить промпт

Ctrl+V / Cmd+V

### Шаг 4: Нажать ENTER

Cursor начнёт работать на каждой задаче!

---

## 🎯 Алгоритм работы

**Cursor будет:**

1. Читать CURSOR-TASK-1-HELP-PAGE.md
2. Создавать файлы HelpPage.jsx, маршруты и т.д.
3. Встраивать IN-APP-HELP-PAGE.md контент
4. Тестировать в браузере
5. Создавать commit

**Затем:**

6. Читать CURSOR-TASK-2-ROADMAP.md
7. Создавать admin, заполнять тестовые данные
8. Проверять VDS стабильность
9. Создавать commit

**Затем:**

10. Читать CURSOR-TASK-3-INTEGRATIONS.md
11. Реализовать Google Calendar синхронизацию
12. Реализовать Google Contacts синхронизацию
13. Реализовать Todoist синхронизацию
14. Создавать commits на каждой части

---

## ✅ После завершения

```bash
# Проверить что всё на GitHub
git log --oneline | head -10

# Должны быть commits:
# ✅ Help Page встроена
# ✅ Admin создан, тестовые данные заполнены
# ✅ Google Calendar интеграция готова
# ✅ Google Contacts интеграция готова
# ✅ Todoist интеграция готова
```

---

**Готово! Скопируйте промпт в Cursor Chat и начните работу! 🚀**
