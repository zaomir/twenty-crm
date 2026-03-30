# 🚀 CURSOR-FINAL-PROMPT — Полная реализация Help + Google Calendar/Contacts + Todoist

**СКОПИРУЙТЕ ВСЁ МЕЖДУ ЛИНИЯМИ И ВСТАВЬТЕ В CURSOR CHAT (Cmd+K)**

---

```
GitHub upstream: https://github.com/twentyhq/twenty
Форк: ваш-fork/twenty, ветка: feature/help-page-google-todoist
VDS: 213.155.28.121, docker-compose в /tmp/controlcenter-deploy/
Docker registry: TBD (Docker Hub / GitLab / GHCR)
Todoist API token: только .env на VDS, НЕ в чате

════════════════════════════════════════════════════════════════════════════════

КРАТКАЯ АРХИТЕКТУРА Twenty (из разведки upstream)
═════════════════════════════════════════════════════════════════════════════

Менеджер: Yarn 4 (в корне package.json "packageManager": "yarn@4.13.0")
Frontend:
  - packages/twenty-front/src/modules/app/components/SettingsRoutes.tsx
  - Enum SettingsPath в packages/twenty-shared/src/types/SettingsPath.ts
  - Пункты меню в packages/twenty-front/src/modules/settings/hooks/useSettingsNavigationItems.tsx
  - Страницы: packages/twenty-front/src/pages/settings/...
  
Backend:
  - Task: TaskWorkspaceEntity (не просто core.task)
  - Очередь: MessageQueue в packages/twenty-server/src/engine/core-modules/message-queue/
  - Миграции: packages/twenty-server/src/database/typeorm/core/migrations/
  - Шифрование: SecretEncryptionService в packages/twenty-server/src/engine/core-modules/secret-encryption/
  
Запуск: yarn start (поднимает twenty-server + twenty-front через Nx)

════════════════════════════════════════════════════════════════════════════════

ЭТАП 0: ПОДГОТОВКА ФОРКА И РАЗВЕДКА (1 день)
═════════════════════════════════════════════════════════════════════════════

1. Форкнуть и клонировать:
   git clone https://github.com/ваш-fork/twenty.git ~/twenty-fork
   cd ~/twenty-fork
   git checkout -b feature/help-page-google-todoist

2. Установить зависимости:
   yarn install

3. РАЗВЕДКА ФРОНТА (Settings):

   a) Убедиться что SettingsPath существует и какой там enum:
      cat packages/twenty-shared/src/types/SettingsPath.ts | head -30
      
   b) Найти SettingsRoutes:
      cat packages/twenty-front/src/modules/app/components/SettingsRoutes.tsx | head -50
      
   c) Найти навигацию:
      cat packages/twenty-front/src/modules/settings/hooks/useSettingsNavigationItems.tsx | grep -A5 "Integrations\|Help" | head -20

4. РАЗВЕДКА БЭКА (очереди и задачи):

   a) Найти очередь Message Queue:
      ls packages/twenty-server/src/engine/core-modules/message-queue/
      cat packages/twenty-server/src/engine/core-modules/message-queue/message-queue.constants.ts | grep Queue | head -20
      
   b) Найти Task сущность:
      find packages/twenty-server/src -name "*task*" -path "*/workspace-entity*" | head -5
      cat packages/twenty-server/src/modules/task/standard-objects/task.workspace-entity.ts | head -30
      
   c) Найти примеры jobs:
      find packages/twenty-server/src -path "*jobs*" -name "*.job.ts" | head -5
      ls -la packages/twenty-server/src/engine/core-modules/message-queue/jobs/

5. РАЗВЕДКА БД (миграции):

   a) Найти миграции:
      ls -la packages/twenty-server/src/database/typeorm/core/migrations/ | tail -20
      
   b) Посмотреть последнюю миграцию как шаблон:
      ls -t packages/twenty-server/src/database/typeorm/core/migrations/*.ts | head -1 | xargs cat | head -50

6. РАЗВЕДКА ШИФРОВАНИЯ:

   a) Найти SecretEncryptionService:
      find packages/twenty-server/src -name "*secret*" -path "*encryption*" | head -5
      cat packages/twenty-server/src/engine/core-modules/secret-encryption/secret-encryption.service.ts | grep -A10 "encrypt\|decrypt" | head -20

7. Результат разведки → краткий report:
   - SettingsPath enum: какие пути уже есть
   - SettingsRoutes: как добавить новый маршрут
   - useSettingsNavigationItems: как добавить пункт меню
   - MessageQueue: какие очереди есть, паттерн именования
   - Task сущность: поля (title, dueAt, status, и т.д.)
   - Миграции: стиль TypeORM в Twenty
   - SecretEncryption: как зашифровать токен

════════════════════════════════════════════════════════════════════════════════

ЭТАП 1: HELP PAGE В SETTINGS (2 дня)
═════════════════════════════════════════════════════════════════════════════

На основе разведки:

1. Добавить Help в SettingsPath enum:
   packages/twenty-shared/src/types/SettingsPath.ts
   Добавить: Help = 'help',

2. Создать компонент HelpPage:
   packages/twenty-front/src/pages/settings/SettingsHelp.tsx
   - Контент из https://raw.githubusercontent.com/zaomir/twenty-crm/main/IN-APP-HELP-PAGE.md
   - Рендер Markdown (существующий компонент или react-markdown)
   - Table of Contents с якорями
   - Мобильная версия (responsive)

3. Добавить маршрут в SettingsRoutes.tsx:
   <Route path={getSettingsPath(SettingsPath.Help)} element={<SettingsHelp />} />

4. Добавить пункт меню в useSettingsNavigationItems.tsx:
   {
     label: 'Help',
     icon: HelpIcon,
     path: getSettingsPath(SettingsPath.Help),
   }

5. Тестирование локально:
   yarn start
   Открыть http://localhost:3001/settings/help
   - Help открывается ✅
   - Якоры работают ✅
   - На мобильном читаемо ✅
   - Нет ошибок в консоли ✅

6. Commit:
   git add packages/twenty-front packages/twenty-shared
   git commit -m "feat(settings): add Help page with IN-APP-HELP-PAGE content"

════════════════════════════════════════════════════════════════════════════════

ЭТАП 2: ИНТЕГРАЦИИ В SETTINGS (1 день)
═════════════════════════════════════════════════════════════════════════════

Вероятно, SettingsPath.Integrations уже в enum, но страница закомментирована.

1. Раскомментировать SettingsIntegrations в SettingsRoutes.tsx

2. Создать или обновить SettingsIntegrations страницу:
   packages/twenty-front/src/pages/settings/SettingsIntegrations.tsx
   
   Содержать подразделы:
   - Google Calendar (Connect button, Connected status, Disconnect button)
   - Google Contacts (Export, Import buttons)
   - Todoist (Connect button, project selector, status)

3. Добавить пункт меню (если не добавлен):
   useSettingsNavigationItems.tsx → Integrations

4. Тестирование:
   yarn start
   Открыть http://localhost:3001/settings/integrations
   - Страница загружается ✅
   - Видны заглушки для Google Calendar, Contacts, Todoist ✅

════════════════════════════════════════════════════════════════════════════════

ЭТАП 3: МИГРАЦИЯ БД ДЛЯ ИНТЕГРАЦИЙ (1 день)
═════════════════════════════════════════════════════════════════════════════

В packages/twenty-server/src/database/typeorm/core/migrations/:

1. Создать миграцию:
   {timestamp}-create-integration-table.ts
   
   Таблица core.integration:
   - id (UUID primary key)
   - user_id (FK на core."user")
   - integration_type (VARCHAR: 'google_calendar', 'google_contacts', 'todoist')
   - access_token (VARCHAR, зашифрован)
   - refresh_token (VARCHAR, optional, зашифрован)
   - is_connected (BOOLEAN, default false)
   - settings (JSONB, для project_id Todoist и т.д.)
   - created_at, updated_at
   
2. Или: если уже есть credentials/connected_accounts, расширить существующую

3. Стиль миграции:
   - TypeORM QueryRunner
   - Смотреть последнюю миграцию как шаблон (найдена в разведке)
   - Все таблицы с префиксом core.

4. Тестирование миграции локально (не обязательно):
   Миграции пройдут при старте контейнера на VDS

════════════════════════════════════════════════════════════════════════════════

ЭТАП 4: СЕРВИС ШИФРОВАНИЯ ДЛЯ ТОКЕНОВ (1 день)
═════════════════════════════════════════════════════════════════════════════

В packages/twenty-server/src:

1. Использовать существующий SecretEncryptionService:
   packages/twenty-server/src/engine/core-modules/secret-encryption/secret-encryption.service.ts
   
2. При сохранении токена интеграции:
   const encrypted = await this.secretEncryptionService.encrypt(access_token);
   Сохранить encrypted в БД

3. При чтении:
   const decrypted = await this.secretEncryptionService.decrypt(encrypted);
   Использовать для API запросов

4. ВАЖНО:
   - Никогда не логировать открытые токены
   - Только зашифрованно в БД
   - Env переменные из .env на VDS (ENCRYPTION_KEY уже может быть)

════════════════════════════════════════════════════════════════════════════════

ЭТАП 5: GOOGLE CALENDAR — BACKEND (3 дня)
═════════════════════════════════════════════════════════════════════════════

В packages/twenty-server/src/modules/:

1. Создать модуль integration-google-calendar:
   integration-google-calendar/
   ├── controllers/
   │   └── integration-google-calendar.controller.ts
   ├── services/
   │   └── integration-google-calendar.service.ts
   └── integration-google-calendar.module.ts

2. Endpoints:
   POST /api/integrations/google-calendar/connect
     { code: "authorization_code" }
     → обменять на access_token, сохранить в core.integration
     ← { success: true }
   
   POST /api/integrations/google-calendar/disconnect
     ← { success: true }
   
   GET /api/integrations/google-calendar/status
     ← { is_connected: boolean, email?: string }

3. Фоновая синхронизация:
   - Использовать MessageQueue из разведки
   - Создать job: packages/twenty-server/src/engine/core-modules/message-queue/jobs/sync-google-calendar.job.ts
   - Регистрация в message-queue.module.ts
   - Логика:
     * Получить Tasks из workspace (через service, не SQL прямо!)
     * Создать/обновить Events в Google Calendar
     * Получить Events из Google Calendar
     * Создать/обновить Tasks в workspace

4. Маппинг:
   task.title ↔ event.title
   task.dueAt ↔ event.start
   task.completed ↔ event.transparency

5. Тестирование:
   yarn dev (twenty-server)
   Вызвать POST /api/integrations/google-calendar/connect с code
   Проверить что токен в БД (зашифрован)
   Job должен синхронизировать Tasks

════════════════════════════════════════════════════════════════════════════════

ЭТАП 6: GOOGLE CALENDAR — FRONTEND (2 дня)
═════════════════════════════════════════════════════════════════════════════

В packages/twenty-front/src в SettingsIntegrations:

1. Компонент для Google Calendar:
   SettingsIntegrationGoogleCalendar.tsx
   
2. Логика:
   - Если is_connected=false → кнопка "Connect to Google Calendar"
   - Если is_connected=true → "Connected ✅" + кнопка "Disconnect"
   - Toggle "Enable sync"

3. OAuth flow при клике Connect:
   window.location.href = `https://accounts.google.com/o/oauth2/v2/auth?
     client_id=${GOOGLE_CALENDAR_CLIENT_ID}
     &redirect_uri=https://controlcenter.me/auth/google/callback
     &scope=https://www.googleapis.com/auth/calendar
     &response_type=code
   `
   
   На callback странице (pages/auth/GoogleCallback.tsx или existing):
   - Парсить code из URL
   - POST /api/integrations/google-calendar/connect { code }
   - Сохранить статус в state
   - Redirect обратно на /settings/integrations

4. Тестирование:
   yarn dev (twenty-front)
   Settings → Integrations → Google Calendar
   - Кнопка "Connect" видна ✅
   - Клик → OAuth ✅
   - "Connected ✅" после разрешения ✅

════════════════════════════════════════════════════════════════════════════════

ЭТАП 7: GOOGLE CONTACTS (2 дня backend + 1 день frontend)
═════════════════════════════════════════════════════════════════════════════

Backend:
1. Модуль integration-google-contacts
2. Endpoints:
   POST /api/integrations/google-contacts/export { contact_ids?: string[] }
   POST /api/integrations/google-contacts/import
   GET /api/integrations/google-contacts/status

3. Логика:
   - Export: загрузить Contact записи из workspace, создать в Google Contacts API
   - Import: получить из Google Contacts, создать/обновить в workspace
   - Unique key: email

4. Optional job для синхронизации

Frontend:
1. Компонент SettingsIntegrationGoogleContacts.tsx
2. Кнопки: Export, Import
3. Toggle "Enable auto-sync"

════════════════════════════════════════════════════════════════════════════════

ЭТАП 8: TODOIST (2 дня backend + 1 день frontend)
═════════════════════════════════════════════════════════════════════════════

API Token: из env TODOIST_API_TOKEN (НЕ из чата! Выпустить заново!)

Backend:
1. Модуль integration-todoist
2. Endpoints:
   POST /api/integrations/todoist/connect { project_id: string }
   GET /api/integrations/todoist/projects (получить список)
   POST /api/integrations/todoist/disconnect
   GET /api/integrations/todoist/status

3. Фоновая синхронизация (Message Queue job):
   - Push: Tasks в Todoist (POST /rest/v2/tasks)
   - Pull: Tasks из Todoist (GET /rest/v2/tasks?project_id=...)
   - Маппинг:
     * title ↔ content
     * dueAt ↔ due_date
     * priority (High/Med/Low) ↔ (p1/p2/p3)
     * completed ↔ is_completed

Frontend:
1. Компонент SettingsIntegrationTodoist.tsx
2. Input для API Token (из env)
3. Dropdown для выбора проекта (GET /api/integrations/todoist/projects)
4. Кнопка "Connect"
5. Toggle "Enable sync"

════════════════════════════════════════════════════════════════════════════════

ЭТАП 9: ФИНАЛИЗАЦИЯ И DOCKER BUILD (2 дня)
═════════════════════════════════════════════════════════════════════════════

1. Все коммиты в ветку feature/help-page-google-todoist

2. Локальный финальный тест:
   yarn start
   Settings → Help ✅
   Settings → Integrations → Google Calendar/Contacts/Todoist ✅
   Синхронизация работает (задачи появляются в Google/Todoist) ✅
   Логи чистые ✅

3. Docker build:
   cd ~/twenty-fork
   docker build -t your-registry/twenty:v1.0.0 .
   docker push your-registry/twenty:v1.0.0

4. На VDS обновить docker-compose.yml:
   image: your-registry/twenty:v1.0.0 (вместо twentycrm/twenty:latest)

5. Перезагрузить:
   docker compose down
   docker compose up -d
   docker logs controlcenter-crm (проверить миграции)

6. Финальная проверка:
   https://controlcenter.me/settings/help ✅
   https://controlcenter.me/settings/integrations ✅
   curl -k https://controlcenter.me/healthz → 200 ✅

════════════════════════════════════════════════════════════════════════════════

ИТОГО: ~3-4 недели разработки + тестирования

════════════════════════════════════════════════════════════════════════════════

НАЧНИТЕ С ЭТАПА 0 РАЗВЕДКИ В ФОРКЕ! 🚀

Удалить временный клон: rm -rf /tmp/twentyhq-twenty
Клонировать свой форк: git clone https://github.com/ваш-fork/twenty.git ~/twenty-fork
```

---

## ✅ СКОПИРУЙТЕ И ВСТАВЬТЕ В CURSOR!

**Главные отличия от старого промпта:**

✅ **Реальная архитектура Twenty**
- ✅ Yarn 4 (не npm)
- ✅ SettingsPath enum + SettingsRoutes.tsx
- ✅ MessageQueue (не голый Bull)
- ✅ TaskWorkspaceEntity (не просто core.task)
- ✅ SecretEncryptionService (шифрование встроено)
- ✅ Миграции в `database/typeorm/core/migrations/`

✅ **Правильные пути к файлам**
- ✅ packages/twenty-shared/src/types/SettingsPath.ts
- ✅ packages/twenty-front/src/modules/settings/hooks/useSettingsNavigationItems.tsx
- ✅ packages/twenty-server/src/database/typeorm/core/migrations/

✅ **Токены только в .env**
- ✅ Todoist token НЕ из чата
- ✅ SecretEncryptionService для всех секретов

---

**ГОТОВО К ЗАПУСКУ! 🚀**
