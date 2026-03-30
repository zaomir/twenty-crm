# 🔗 INTEGRATIONS.md — Интеграции controlcenter.me

Это руководство для подключения controlcenter.me к:
- 📅 Google Calendar (синхронизация задач/событий)
- 📇 Google Contacts (импорт/экспорт контактов)
- ✓ Todoist (синхронизация задач)

---

## 📅 Google Calendar

### Что это делает?

**Двусторонняя синхронизация:**
- Задачи из controlcenter.me → События в Google Calendar
- События из Google Calendar → Задачи в controlcenter.me
- Изменения синхронизируются автоматически

### Как настроить? (Администратор)

#### Шаг 1: Создать Google Cloud Project

1. Перейдите на [Google Cloud Console](https://console.cloud.google.com)
2. Создайте новый проект:
   ```
   Выберите проект → Создать проект → Название: "controlcenter" → Create
   ```
3. Дождитесь создания (1-2 минуты)

#### Шаг 2: Включить Google Calendar API

1. В Google Cloud Console найдите "APIs & Services" → "Library"
2. Поиск: "Google Calendar API"
3. Нажмите "Enable"
4. Дождитесь активации

#### Шаг 3: Создать OAuth 2.0 credentials

1. "APIs & Services" → "Credentials"
2. Нажмите "+ Create Credentials" → "OAuth client ID"
3. Если просит установить consent screen — сделайте это:
   - "Consent Screen" → "External" → "Create"
   - Заполните:
     - App name: "controlcenter"
     - User support email: admin@controlcenter.me
     - Developer contact: admin@controlcenter.me
   - "Save and Continue"
4. Вернитесь к "Credentials" → "+ Create Credentials" → "OAuth client ID"
5. Выберите:
   - Application type: "Web application"
   - Name: "controlcenter-web"
   - Authorized redirect URIs: 
     ```
     https://controlcenter.me/auth/google/callback
     https://controlcenter.me/oauth/google/callback
     ```
6. Нажмите "Create"
7. Скопируйте:
   - Client ID
   - Client Secret

#### Шаг 4: Добавить credentials в controlcenter.me

1. Откройте controlcenter.me как администратор
2. Settings → Integrations → Google Calendar
3. Вставьте:
   ```
   Client ID: xxxxxxx
   Client Secret: xxxxxxx
   ```
4. Нажмите "Save" и "Connect"

#### Шаг 5: Авторизовать доступ

1. controlcenter.me перенаправит на Google
2. Выберите свой аккаунт Google
3. Дайте разрешение на доступ к календарю
4. Вернётесь в controlcenter.me
5. ✅ Готово! Синхронизация включена

---

### Как использовать? (Пользователь)

#### Создать задачу, которая синхронизируется

```
Tasks → + Add Task
├─ Название: "Позвонить клиенту"
├─ Дата: 2026-04-01 10:00
├─ Приоритет: High
└─ Синхронизировать с Google Calendar: ✅ YES
```

**Результат:** Событие автоматически появится в Google Calendar в 10:00

#### Создать событие в Google Calendar, которое появится в задачах

```
Google Calendar → Создать событие
├─ Название: "Презентация для клиента"
├─ Дата: 2026-04-05 14:00
└─ Описание: "Приготовить слайды"
```

**Результат:** Задача автоматически появится в controlcenter.me

---

## 📇 Google Contacts

### Что это делает?

**Синхронизация контактов:**
- Экспортировать контакты из controlcenter.me в Google Contacts
- Импортировать контакты из Google Contacts в controlcenter.me
- Один контакт = один email (уникальный ключ)

### Как настроить? (Администратор)

#### Шаг 1-2: Используйте те же credentials как для Calendar

Если уже сделали Google Calendar — используйте **тот же Client ID и Secret**.

#### Шаг 3: Включить Google Contacts API

1. Google Cloud Console → "APIs & Services" → "Library"
2. Поиск: "Google Contacts API"
3. Нажмите "Enable"

#### Шаг 4: Добавить в controlcenter.me

1. Settings → Integrations → Google Contacts
2. Вставьте **те же** Client ID и Secret
3. Нажмите "Save" и "Connect"
4. Дайте разрешение (как для Calendar)
5. ✅ Готово!

---

### Как использовать? (Пользователь)

#### Экспортировать контакты в Google

```
Contacts → Выберите контакты (или все) → ⋮ Menu → Export to Google Contacts
```

**Результат:** Контакты появляются в Google Contacts

#### Импортировать контакты из Google

```
Contacts → ⋮ Menu → Import from Google Contacts
```

**Результат:** Контакты из Google добавляются в controlcenter.me

#### Двусторонняя синхронизация

Если включить **автоматическую синхронизацию:**

```
Settings → Integrations → Google Contacts → Enable Auto Sync
```

**Результат:** Изменения в одном месте сразу появляются в другом.

---

## ✓ Todoist

### Что это делает?

**Синхронизация задач:**
- Задачи из controlcenter.me → Todoist
- Задачи из Todoist → controlcenter.me  
- Изменения статуса синхронизируются автоматически

### Как настроить? (Администратор)

#### Шаг 1: Получить Todoist API Token

1. Откройте [Todoist Settings](https://todoist.com/app/settings)
2. Перейдите в "Integrations" → "API token"
3. Скопируйте ваш **API Token**
4. Сохраните его в безопасном месте! (не делитесь)

#### Шаг 2: Добавить в controlcenter.me

1. controlcenter.me → Settings → Integrations → Todoist
2. Вставьте API Token:
   ```
   API Token: xxxxxxxxxxxxxxxx
   ```
3. Нажмите "Save" и "Connect"
4. Выберите какой проект в Todoist синхронизировать:
   ```
   Select Project: "Work" (или другой название)
   ```
5. ✅ Готово!

---

### Как использовать? (Пользователь)

#### Создать задачу в controlcenter.me, которая появится в Todoist

```
Tasks → + Add Task
├─ Название: "Отправить счет клиенту"
├─ Дата: 2026-04-02
├─ Приоритет: High
└─ Sync with Todoist: ✅ YES
```

**Результат:** Задача автоматически появится в Todoist → проект "Work"

#### Создать задачу в Todoist, которая появится в controlcenter.me

```
Todoist → Проект "Work" → + Add Task
├─ Название: "Подготовить договор"
└─ Due: 2026-04-03
```

**Результат:** Задача автоматически появится в controlcenter.me → Tasks

#### Отметить задачу как выполненную

```
Todoist → ✅ Отметить как выполненную
```

**Результат:** Статус синхронизируется в controlcenter.me (Completed)

---

## 🔄 Автоматическая синхронизация

### Как она работает?

**Синхронизация запускается:**
- При создании задачи/контакта/события
- При изменении статуса
- При удалении элемента
- Каждые 5 минут (фоновая синхронизация)

### Отключить синхронизацию

Если что-то синхронизируется неправильно:

```
Settings → Integrations → [Integ name] → Disable Sync
```

Повторно включить:

```
Settings → Integrations → [Integ name] → Enable Sync
```

---

## 🚨 Частые проблемы

### Проблема: Задачи не синхронизируются

**Решение:**
1. Проверьте что интеграция "Connected" (Settings → Integrations)
2. Перезагрузите браузер (Ctrl+Shift+R)
3. Попробуйте отключить и включить синхронизацию
4. Если не помогает — обратитесь к администратору

### Проблема: "Authorization failed"

**Решение:**
1. Google/Todoist credentials истекли или неправильные
2. Settings → Integrations → "Reconnect"
3. Пройдите процесс авторизации заново
4. Убедитесь что даёте все необходимые разрешения

### Проблема: Дублирование контактов/задач

**Решение:**
1. Отключите синхронизацию (Settings → Integrations)
2. Удалите дубликаты вручную
3. Включите синхронизацию заново

### Проблема: Контакт имеет несколько email'ов

**Решение:**
- controlcenter.me использует **основной email** для синхронизации
- Дополнительные email'ы не синхронизируются (ограничение Google Contacts API)

---

## 🔒 Безопасность

### Credentials

✅ **Безопасно:**
- Credentials хранятся зашифрованными на VDS
- Используется OAuth 2.0 (безопасный стандарт)
- Регулярно пересматривайте какие приложения имеют доступ

❌ **Опасно:**
- Не делитесь Client ID/Secret/API Token
- Не публикуйте их в GitHub
- Регулярно ротируйте credentials (каждые 90 дней)

### Отозвать доступ

**Google:**
```
Google Account → Security → Connected apps → 
Найти "controlcenter" → Remove Access
```

**Todoist:**
```
Todoist → Settings → Integrations → 
Найти "controlcenter" → Disconnect
```

---

## 📋 Заполненный пример: Полный workflow

### День 1: Новый клиент

```
1. Контакт создан в controlcenter.me:
   Email: ivan@example.com
   Имя: Иван Петров
   ↓
   ✅ Синхронизируется в Google Contacts

2. Добавлена задача "Позвонить Ивану" на завтра в 10:00
   ↓
   ✅ Синхронизируется в Google Calendar (событие)
   ✅ Синхронизируется в Todoist
```

### День 2: Переговоры

```
1. В Google Calendar я вижу событие "Позвонить Ивану"
2. Звоню в 10:00, обсуждаем проект
3. Добавляю задачу в controlcenter.me "Подготовить КП"
   ↓
   ✅ Она сразу появляется в Todoist
```

### День 3: Следующие шаги

```
1. В Todoist я вижу "Подготовить КП"
2. Отмечу как выполненную в Todoist
   ↓
   ✅ Статус синхронизируется в controlcenter.me
3. Создам новую задачу "Отправить КП Ивану"
   ↓
   ✅ Появится в Google Calendar и Todoist
```

---

## ✅ Что можно синхронизировать

| Элемент | controlcenter.me | Google Calendar | Google Contacts | Todoist |
|---------|---|---|---|---|
| Задачи | ✅ | ✅ Event | - | ✅ |
| События | - | ✅ | - | - |
| Контакты | ✅ | - | ✅ | - |
| Сделки | ✅ | - | - | ✅ (как задачи) |
| Примечания | ✅ | ✅ Description | ✅ Notes | ✅ Description |
| Приоритеты | ✅ | - | - | ✅ |
| Сроки | ✅ | ✅ Date | - | ✅ |
| Статус | ✅ | - | - | ✅ |

---

## 🚀 Следующие интеграции (планируются)

- 📧 **Gmail** — отправка писем из CRM, история переписки
- 📞 **Slack** — уведомления о новых сделках
- 📊 **Google Sheets** — экспорт отчётов
- 💼 **Stripe** — отслеживание платежей
- **Zapier** — любые интеграции через Zapier

---

## 📞 Помощь

Если интеграция не работает:

1. Проверьте что credentials правильные
2. Перезагрузите браузер
3. Отключите и включите синхронизацию
4. Обратитесь к администратору

---

**Версия:** 1.0  
**Дата:** 2026-03-30  
**Статус:** 🔄 В РАЗРАБОТКЕ (интеграции будут добавлены в апреле)
