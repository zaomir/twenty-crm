# 📌 CURSOR-TASK-3.md — Подключить Google Calendar, Contacts, Todoist

**Приоритет:** 🔴 HIGH  
**Сложность:** ⭐⭐⭐⭐⭐ ОЧЕНЬ ВЫСОКАЯ  
**Время:** 3-4 недели (по частям)  
**Статус:** 🔄 READY FOR IMPLEMENTATION

---

## 🎯 Задача

Реализовать интеграции controlcenter.me с:
1. **Google Calendar** — синхронизация задач ↔ события
2. **Google Contacts** — импорт/экспорт контактов
3. **Todoist** — синхронизация задач

---

## 📋 ТРИ ЧАСТИ

### ЧАСТЬ 1: Google Calendar
### ЧАСТЬ 2: Google Contacts  
### ЧАСТЬ 3: Todoist

---

## ЧАСТЬ 1: Google Calendar Integration

### Что это делает?

**Двусторонняя синхронизация:**
- Задачи из controlcenter.me (Tasks) ↔ События в Google Calendar
- Пользователь создаёт задачу → она появляется в Google Calendar
- Пользователь создаёт событие в Google → появляется как задача в CRM

### Требования

✅ **Backend:**
- [ ] Получить Google OAuth 2.0 credentials (Client ID + Secret)
- [ ] Создать endpoint `/api/integrations/google-calendar/connect`
- [ ] Создать endpoint `/api/integrations/google-calendar/disconnect`
- [ ] Реализовать двусторонней синхронизацией (webhook или polling каждые 5 минут)
- [ ] Хранить Google Calendar ID в БД пользователя
- [ ] Хранить Google OAuth token (зашифрованный) в БД

✅ **Frontend:**
- [ ] Создать Settings → Integrations → Google Calendar раздел
- [ ] Кнопка "Connect to Google Calendar"
- [ ] При клике открывается Google OAuth consent screen
- [ ] После авторизации показать "Connected ✅"
- [ ] Кнопка "Disconnect"
- [ ] Toggle "Enable sync"

✅ **Синхронизация:**
- [ ] При создании задачи в CRM → создать событие в Google Calendar
- [ ] При изменении задачи (название, дата) → обновить в Google Calendar
- [ ] При удалении задачи → удалить в Google Calendar
- [ ] При создании события в Google → создать задачу в CRM
- [ ] Обновления синхронизируются каждые 5 минут (или webhook)

✅ **Данные:**
```
Task (controlcenter.me) ↔ Event (Google Calendar)
- task.title → event.title
- task.dueDate → event.start
- task.priority → event.description (или color)
- task.description → event.description
- task.completed → event.transparency (opaque/transparent)
```

### Инструкции для администратора (из INTEGRATIONS.md)

1. **Google Cloud Project:**
   ```
   console.cloud.google.com
   → Создать проект "controlcenter"
   → Включить Google Calendar API
   → Credentials → OAuth 2.0 Client ID
   → Redirect URI: https://controlcenter.me/auth/google/callback
   ```

2. **Сохранить credentials:**
   ```env
   GOOGLE_CALENDAR_CLIENT_ID=xxx
   GOOGLE_CALENDAR_CLIENT_SECRET=xxx
   ```

### Тестирование

```
1. Settings → Integrations → Google Calendar
2. Нажать "Connect to Google Calendar"
3. Выполнить Google OAuth
4. Должно быть "Connected ✅"

5. Создать задачу:
   Tasks → + Add Task
   Название: "Test task"
   Дата: 2026-04-05 10:00
   ✓ Sync with Google Calendar

6. Проверить в Google Calendar:
   → Событие "Test task" появилось на 2026-04-05 10:00

7. Изменить в Google Calendar:
   → Переместить событие на 14:00
   → Через 5 минут в CRM задача обновилась на 14:00

8. Нажать Disconnect
   → События НЕ удаляются из Google Calendar
```

---

## ЧАСТЬ 2: Google Contacts Integration

### Что это делает?

**Импорт/экспорт контактов:**
- Экспортировать контакты из CRM в Google Contacts
- Импортировать контакты из Google Contacts в CRM
- Один контакт = один email (уникальный ключ)

### Требования

✅ **Backend:**
- [ ] Получить Google API credentials (используйте те же как для Calendar)
- [ ] Создать endpoint `/api/integrations/google-contacts/export`
- [ ] Создать endpoint `/api/integrations/google-contacts/import`
- [ ] Реализовать сопоставление по email (деликт)
- [ ] Опционально: автоматическая синхронизация

✅ **Frontend:**
- [ ] Settings → Integrations → Google Contacts
- [ ] Кнопка "Connect to Google Contacts"
- [ ] Google OAuth
- [ ] Кнопка "Export to Google Contacts" (все или выбранные)
- [ ] Кнопка "Import from Google Contacts"
- [ ] Toggle "Enable auto-sync" (опционально)

✅ **Синхронизация:**
- [ ] При экспорте контакта → добавить в Google Contacts
- [ ] При импорте → добавить в CRM
- [ ] По email (unique key)
- [ ] Если контакт уже есть → обновить

✅ **Данные:**
```
Contact (controlcenter.me) ↔ Contact (Google Contacts)
- contact.name → contact.name
- contact.email → contact.email
- contact.phone → contact.phone
- contact.company → contact.organization
- contact.jobTitle → contact.jobTitle
```

### Тестирование

```
1. Settings → Integrations → Google Contacts
2. Нажать "Connect to Google"
3. Google OAuth
4. Должно быть "Connected ✅"

5. Создать контакт:
   Contacts → + Add Contact
   Имя: "Ivan Petrov"
   Email: ivan@example.com
   Телефон: +7 999 888 7777
   Компания: "ООО Рога и копыта"

6. Нажать "Export to Google Contacts"
   → Контакт появился в Google Contacts

7. В Google Contacts создать контакт:
   Имя: "Maria Smirnova"
   Email: maria@example.com

8. В CRM нажать "Import from Google Contacts"
   → Контакт Maria появился в CRM

9. В CRM изменить контакт Ivan:
   Email: ivan.petrov@example.com
   Нажать "Export"
   → В Google обновился email Ivan

10. Если enable auto-sync:
    → Изменения синхронизируются автоматически
```

---

## ЧАСТЬ 3: Todoist Integration

### Что это делает?

**Синхронизация задач:**
- Задачи из controlcenter.me → Todoist проект
- Задачи из Todoist → controlcenter.me
- Двусторонняя синхронизация статусов

### Требования

✅ **Backend:**
- [ ] Получить Todoist API token (от администратора)
- [ ] Создать endpoint `/api/integrations/todoist/connect`
- [ ] Создать endpoint `/api/integrations/todoist/disconnect`
- [ ] Реализовать двусторонней синхронизацией
- [ ] Хранить Todoist token (зашифрованный) в БД
- [ ] Синхронизация каждые 5 минут (webhook или polling)

✅ **Frontend:**
- [ ] Settings → Integrations → Todoist
- [ ] Поле для ввода Todoist API Token
- [ ] Выбрать Todoist проект (dropdown)
- [ ] Кнопка "Connect"
- [ ] После подключения: "Connected ✅"
- [ ] Кнопка "Disconnect"
- [ ] Toggle "Enable sync"

✅ **Синхронизация:**
- [ ] При создании задачи в CRM → создать в Todoist
- [ ] При изменении задачи → обновить в Todoist
- [ ] При завершении задачи в CRM → отметить в Todoist
- [ ] При завершении в Todoist → обновить в CRM
- [ ] При удалении → удалить в обоих местах

✅ **Данные:**
```
Task (controlcenter.me) ↔ Task (Todoist)
- task.title → task.content
- task.dueDate → task.due
- task.priority (High/Medium/Low) → task.priority (p1/p2/p3)
- task.description → task.description
- task.completed → task.completed
```

### Инструкции (из INTEGRATIONS.md)

1. **Получить Todoist API Token:**
   ```
   Todoist → Settings → Integrations → API token
   Скопировать token
   ```

2. **Добавить в controlcenter.me:**
   ```
   Settings → Integrations → Todoist
   Paste API Token
   Select Project: "Work" (или другой)
   Click "Connect"
   ```

### Тестирование

```
1. Settings → Integrations → Todoist
2. Paste Todoist API Token
3. Select project "Work"
4. Click "Connect"
5. Должно быть "Connected ✅"

6. В CRM создать задачу:
   Tasks → + Add Task
   Название: "Prepare presentation"
   Дата: 2026-04-10
   Приоритет: High
   ✓ Sync with Todoist

7. Проверить в Todoist:
   → Задача появилась в проекте "Work"
   → Priority: p1 (High)

8. В Todoist отметить задачу как выполненную
   → Через 5 минут в CRM статус обновился

9. В CRM создать новую задачу
   → Она появилась в Todoist

10. Нажать Disconnect
    → Задачи НЕ удаляются из Todoist
```

---

## 🔐 Безопасность

### Credentials Хранение

✅ **Правильно:**
```
# .env (не в git!)
GOOGLE_CALENDAR_CLIENT_SECRET=xxx
TODOIST_API_TOKEN=xxx (хранить в БД, зашифровано)

# БД хранить зашифровано:
users.google_oauth_token = encrypt(token)
users.todoist_token = encrypt(token)
```

❌ **Неправильно:**
```
# Не публиковать в GitHub
# Не отправлять по email
# Не показывать в логах
```

### OAuth 2.0 Flow

```
1. Frontend: Пользователь кликает "Connect"
2. Frontend: Перенаправляется на Google/Todoist OAuth
3. User: Авторизуется на Google/Todoist
4. Google/Todoist: Перенаправляет на /auth/google/callback с code
5. Backend: Обменивает code на access_token
6. Backend: Сохраняет token в БД (зашифрованный)
7. Frontend: Показывает "Connected ✅"
```

---

## 📦 Структура кода

```
src/
├── api/
│   └── integrations/
│       ├── google-calendar/
│       │   ├── connect.ts
│       │   ├── disconnect.ts
│       │   ├── sync.ts (каждые 5 минут)
│       │   └── types.ts
│       ├── google-contacts/
│       │   ├── connect.ts
│       │   ├── export.ts
│       │   ├── import.ts
│       │   └── types.ts
│       └── todoist/
│           ├── connect.ts
│           ├── disconnect.ts
│           ├── sync.ts
│           └── types.ts
├── components/
│   └── settings/
│       └── integrations/
│           ├── GoogleCalendarIntegration.jsx
│           ├── GoogleContactsIntegration.jsx
│           └── TodoistIntegration.jsx
└── hooks/
    └── useIntegration.ts (для синхронизации)
```

---

## 📋 Чек-лист (ЧАСТЬ 1: Google Calendar)

```
GOOGLE CALENDAR:
[ ] Google Cloud Project создан
[ ] Google Calendar API включён
[ ] OAuth 2.0 credentials получены
[ ] Client ID и Secret сохранены в .env
[ ] Endpoint /api/integrations/google-calendar/connect работает
[ ] Endpoint /api/integrations/google-calendar/disconnect работает
[ ] Google OAuth flow реализован
[ ] Settings → Integrations → Google Calendar видна
[ ] Кнопка "Connect" работает
[ ] После OAuth показать "Connected ✅"
[ ] Синхронизация задач работает (обе стороны)
[ ] Задачи обновляются каждые 5 минут
[ ] Тестирование пройдено (6 сценариев)
```

---

## 📋 Чек-лист (ЧАСТЬ 2: Google Contacts)

```
GOOGLE CONTACTS:
[ ] Google Contacts API включена
[ ] Использованы те же credentials как для Calendar
[ ] Endpoint /api/integrations/google-contacts/export работает
[ ] Endpoint /api/integrations/google-contacts/import работает
[ ] Settings → Integrations → Google Contacts видна
[ ] Кнопка "Connect" работает
[ ] Кнопка "Export to Google Contacts" работает
[ ] Кнопка "Import from Google Contacts" работает
[ ] Синхронизация по email работает
[ ] Обновление существующих контактов работает
[ ] Тестирование пройдено (5 сценариев)
```

---

## 📋 Чек-лист (ЧАСТЬ 3: Todoist)

```
TODOIST:
[ ] Todoist API token получен
[ ] Endpoint /api/integrations/todoist/connect работает
[ ] Endpoint /api/integrations/todoist/disconnect работает
[ ] Settings → Integrations → Todoist видна
[ ] Поле ввода API Token работает
[ ] Выбор проекта (dropdown) работает
[ ] Кнопка "Connect" работает
[ ] После подключения: "Connected ✅"
[ ] Синхронизация задач работает (обе стороны)
[ ] Синхронизация статусов работает
[ ] Синхронизация приоритетов работает
[ ] Обновления каждые 5 минут
[ ] Тестирование пройдено (5 сценариев)
```

---

## 🚀 Prompt для Cursor Chat

```
GitHub: https://github.com/zaomir/twenty-crm

Подключить Google Calendar, Contacts, Todoist к controlcenter.me

ЧАСТЬ 1: Google Calendar
────────────────────────
1. Получить Google OAuth credentials (Client ID + Secret)
2. Реализовать OAuth flow (Settings → Integrations → Google Calendar)
3. Синхронизация: Tasks ↔ Google Calendar events
4. Двусторонняя синхронизация (обновления каждые 5 минут)
5. Тестирование (создать задачу → появилась в Google Calendar и наоборот)

ЧАСТЬ 2: Google Contacts
────────────────────────
1. Использовать те же Google credentials (Calendar + Contacts API)
2. Buttons: Export, Import, Auto-sync
3. Синхронизация по email (unique key)
4. Обновление существующих контактов
5. Тестирование (экспорт и импорт работает)

ЧАСТЬ 3: Todoist
────────────────
1. Получить Todoist API token
2. Settings → Integrations → Todoist (ввод token)
3. Выбрать Todoist проект
4. Синхронизация: Tasks ↔ Todoist
5. Синхронизация статусов и приоритетов
6. Тестирование (двусторонняя синхронизация работает)

Безопасность:
- Credentials в .env (не в git)
- OAuth tokens зашифрованы в БД
- Использовать https://

Инструкции в INTEGRATIONS.md:
- Как администратору настроить
- Как пользователю подключить
- FAQ и решение проблем

После завершения:
✅ Все 3 интеграции работают
✅ Тестирование пройдено
✅ Документация обновлена
✅ Security review пройден
```

---

## 📞 Вопросы?

**Q: Как реализовать фоновую синхронизацию?**  
A: Используйте Celery (Python) или Bull (Node.js) для задач каждые 5 минут

**Q: Как хранить OAuth token безопасно?**  
A: Зашифруйте в БД используя AES-256

**Q: Что если Google API лимит исчерпан?**  
A: Добавьте обработку ошибок и retry logic с exponential backoff

**Q: Можно ли синхронизировать только выбранные задачи?**  
A: Да, добавьте флаг `sync_to_google` на каждой задаче

---

## 📚 Документация

- **Для админа:** INTEGRATIONS.md (как настроить credentials)
- **Для пользователя:** INTEGRATIONS.md (как подключить)
- **Для разработчика:** Комментарии в коде + эта задача

---

**Статус:** 🟡 PLANNING  
**Последнее обновление:** 2026-03-30  
**Фаза:** ROADMAP Фаза 2 (8-20 апреля)
