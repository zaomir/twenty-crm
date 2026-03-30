# 🤖 КАК РАБОТАТЬ С CURSOR AI - ПОЛНАЯ ИНСТРУКЦИЯ

**Дата:** 30 марта 2026  
**Для:** Total (Моня)  
**Цель:** Автоматизировать развёртывание и управление Twenty CRM через Cursor

---

## 📋 ЧТО ТАКОЕ CURSOR

**Cursor** — это IDE (редактор кода) с встроенным AI (Claude), которая может:
- 📝 Писать и редактировать код/скрипты
- 🤖 Выполнять команды в терминале
- 📂 Работать с файлами проекта
- 🔄 Автоматизировать сложные задачи
- 🧠 Помнить контекст между сеансами

**Для вас:** Cursor может полностью автоматизировать развёртывание Twenty CRM

---

## 🚀 СПОСОБ 1: FAST MODE (САМЫЙ БЫСТРЫЙ)

### Шаг 1: Откройте Cursor

1. Запустите Cursor на вашем компьютере
2. Откройте новый проект или используйте существующий

### Шаг 2: Откройте Chat (Command Palette)

Нажмите: **Cmd+K** (Mac) или **Ctrl+K** (Windows/Linux)

Откроется окно чата в низу экрана.

### Шаг 3: Дайте Cursor этот prompt

Скопируйте и вставьте в Cursor Chat:

```
Я хочу развернуть Twenty CRM на VDS 213.155.28.121.

У меня есть готовые файлы:
- docker-compose.yml
- .env.production
- twenty-crm-nginx.conf
- deploy-twenty.sh

Выполни полное развёртывание:

1. Проверь SSH доступ к root@213.155.28.121
2. Отправь все 4 файла на VDS в /tmp/
3. Запусти deploy-twenty.sh на VDS
4. Настрой nginx
5. Получи SSL сертификат
6. Проверь все контейнеры

Используй SSH ключ: ~/.ssh/id_rsa
Выведи статус каждого шага.
```

### Шаг 4: Ждите результата

Cursor автоматически:
- ✅ Проверит наличие файлов
- ✅ Создаст скрипты
- ✅ Выполнит развёртывание
- ✅ Покажет результаты

**Время: 15-20 минут**

---

## 🎯 СПОСОБ 2: ЧЕРЕЗ CONTEXT (ПОЛНЫЙ КОНТРОЛЬ)

### Шаг 1: Создайте папку проекта

```bash
mkdir ~/twenty-crm-deployment
cd ~/twenty-crm-deployment
```

### Шаг 2: Скопируйте все файлы сюда

```bash
# На вашем локальном компьютере
cp /path/to/docker-compose.yml ~/twenty-crm-deployment/
cp /path/to/.env.production ~/twenty-crm-deployment/
cp /path/to/twenty-crm-nginx.conf ~/twenty-crm-deployment/
cp /path/to/deploy-twenty.sh ~/twenty-crm-deployment/
cp /path/to/twenty-crm-google-apps-script.gs ~/twenty-crm-deployment/
cp /path/to/CURSOR-AI-РУССКИЙ.md ~/twenty-crm-deployment/
cp /path/to/QUICK_START.md ~/twenty-crm-deployment/
```

### Шаг 3: Откройте папку в Cursor

1. **Откройте Cursor**
2. **File → Open Folder**
3. **Выберите:** ~/twenty-crm-deployment
4. **Откроется левая панель с файлами**

### Шаг 4: Используйте @-символ для контекста

В Cursor Chat введите:

```
@docker-compose.yml @deploy-twenty.sh

Это файлы для развёртывания Twenty CRM.
Создай полный скрипт развёртывания, который:
1. Проверит SSH
2. Отправит файлы на VDS
3. Запустит развёртывание
4. Настроит nginx
5. Получит SSL
6. Проверит всё

Используй VDS: 213.155.28.121
SSH ключ: ~/.ssh/id_rsa
```

**Что происходит:**
- ✅ Cursor видит содержимое файлов
- ✅ Создаст полный скрипт
- ✅ Поймёт контекст вашего проекта

---

## 📂 СПОСОБ 3: ЧЕРЕЗ ФАЙЛЫ ПРОЕКТА (ЛУЧШИЙ ДЛЯ ПОСТОЯННОЙ РАБОТЫ)

### Структура папки:

```
~/twenty-crm-deployment/
├── README.md                          ← Документация
├── .cursor/
│   ├── prompt.md                      ← Главный prompt для Cursor
│   ├── config.json                    ← Конфигурация
│   └── instructions.md                ← Инструкции для AI
├── scripts/
│   ├── deploy.sh                      ← Скрипт развёртывания
│   └── verify.sh                      ← Скрипт проверки
├── config/
│   ├── docker-compose.yml
│   ├── .env.production
│   ├── twenty-crm-nginx.conf
│   └── twenty-crm-google-apps-script.gs
└── docs/
    ├── QUICK_START.md
    ├── SETUP.md
    └── INTEGRATION.md
```

### Создайте .cursor/prompt.md:

```markdown
# Twenty CRM Deployment Prompt for Cursor AI

## Context
- VDS IP: 213.155.28.121
- VDS User: root
- SSH Key: ~/.ssh/id_rsa
- Domain: crm.grainee.com

## Files
- Docker Compose: config/docker-compose.yml
- Environment: config/.env.production
- Nginx: config/twenty-crm-nginx.conf
- Deploy Script: scripts/deploy.sh

## Tasks

### Task 1: File Transfer
- Check all required files exist
- Transfer to VDS /tmp/
- Verify transfer

### Task 2: Deployment
- SSH to VDS
- Run scripts/deploy.sh
- Monitor logs
- Report status

### Task 3: SSL Certificate
- Get Let's Encrypt cert for crm.grainee.com
- Install nginx config
- Reload nginx

### Task 4: Verification
- Check all containers
- Test API health
- Verify GRAINEE still works
- Check backups

## Output Format
- ✅ Green for success
- ⚠️ Yellow for warnings
- ❌ Red for errors
- Report each step
```

### Откройте в Cursor:

1. **File → Open Folder → ~/twenty-crm-deployment**
2. **Cmd+K и скопируйте содержимое .cursor/prompt.md**
3. **Cursor выполнит все задачи автоматически**

---

## 🔧 СПОСОБ 4: THROUGH CURSOR CODE (ДЛЯ BACKGROUND AGENTS)

### Если у вас Cursor Code (Version Control Integration):

Создайте файл `.cursor-ai.yaml`:

```yaml
# Cursor AI Configuration for Twenty CRM

project_name: "Twenty CRM Deployment"
version: "1.0"

contexts:
  - name: "VDS Configuration"
    files:
      - config/docker-compose.yml
      - config/.env.production
      - config/twenty-crm-nginx.conf
    variables:
      vds_ip: "213.155.28.121"
      vds_user: "root"
      ssh_key: "~/.ssh/id_rsa"
      domain: "crm.grainee.com"

tasks:
  - name: "Deploy"
    command: "scripts/deploy.sh"
    requires_approval: true
    log_output: true
    
  - name: "Verify"
    command: "scripts/verify.sh"
    depends_on: "Deploy"
    
  - name: "Backup"
    command: "scripts/backup.sh"
    schedule: "0 3 * * *"  # 3 AM daily

instructions:
  - "Always verify SSH before any operation"
  - "Never delete data without backup"
  - "Report all changes to stdout"
  - "Use HTTPS for all connections"
```

### Используйте в Cursor:

```
Используй конфигурацию из .cursor-ai.yaml для управления развёртыванием.
Выполни: @tasks Deploy → Verify → Backup
```

---

## 📝 СПОСОБ 5: ЧЕРЕЗ FILES CONTEXT (ОПТИМАЛЬНО)

### Шаг 1: Добавьте файлы в контекст

В Cursor Chat используйте это меню:

```
Menu → @Files → Add Files/Folders
```

Добавьте:
- docker-compose.yml
- deploy-twenty.sh
- twenty-crm-nginx.conf
- .env.production
- twenty-crm-google-apps-script.gs

### Шаг 2: Дайте Cursor задачу

```
Используя эти файлы:

@docker-compose.yml - конфиг контейнеров
@deploy-twenty.sh - скрипт развёртывания
@twenty-crm-nginx.conf - веб-сервер
@.env.production - переменные

Создай полный процесс развёртывания:
1. Проверка зависимостей
2. Валидация файлов
3. SSH тест
4. Отправка файлов
5. Развёртывание
6. Настройка
7. Проверка

Используй VDS: 213.155.28.121
```

Cursor автоматически:
- ✅ Прочитает все файлы
- ✅ Поймёт структуру
- ✅ Создаст полный скрипт
- ✅ Выполнит развёртывание

---

## 🎯 СПОСОБ 6: ЧЕРЕЗ GOOGLE APPS SCRIPT

Если вы хотите автоматизировать через Google Sheets:

### Шаг 1: Скажите Cursor

```
@twenty-crm-google-apps-script.gs

Это скрипт синхронизации Google Sheets ↔ Twenty CRM API.

Создай версию для Cursor Background Agent, которая:
1. Выполняется каждые 30 минут
2. Синхронизирует контакты
3. Синхронизирует сделки
4. Логирует в Google Sheets
5. Отправляет отчёты в Slack

Используй API token: будет передан в переменных
```

### Шаг 2: Cursor создаст

- ✅ Обновлённый скрипт Apps Script
- ✅ Инструкции развёртывания
- ✅ Webhook handlers
- ✅ Логирование

---

## 📦 КАК ПЕРЕДАТЬ ВСЕ ФАЙЛЫ CURSOR

### Способ A: Drag & Drop

1. **Откройте Cursor**
2. **Откройте Chat (Cmd+K)**
3. **Перетащите все файлы в окно чата**
4. **Cursor автоматически добавит их в контекст**

### Способ B: Через папку проекта

```bash
# В Cursor откройте папку проекта:
# File → Open Folder → /path/to/twenty-crm-deployment

# Все файлы будут в левой панели
# Кликните на файл + Cmd+K = добавится в контекст
```

### Способ C: Через @-команду

```
В Cursor Chat введите:

@docker-compose.yml @deploy-twenty.sh @.env.production

Это автоматически добавит файлы в контекст
```

### Способ D: Скопируйте содержимое

```
1. Откройте файл в редакторе
2. Выберите весь текст (Cmd+A)
3. Скопируйте (Cmd+C)
4. В Cursor Chat вставьте (Cmd+V)
5. Файл добавится в контекст
```

---

## 🔄 CONTINUOUS INTEGRATION С CURSOR

### Автоматизируйте повторяющиеся задачи:

**Создайте файл `.cursor-tasks.md`:**

```markdown
# Автоматизированные задачи для Cursor

## Ежедневно (3 AM UTC)
- [ ] Создать резервную копию БД
- [ ] Проверить здоровье контейнеров
- [ ] Отправить отчёт в Slack

## Еженедельно (понедельник 9 AM)
- [ ] Обновить Docker images
- [ ] Проверить обновления SSL
- [ ] Синхронизировать данные с Google Sheets

## Ежемесячно (1-е число)
- [ ] Полная инвентаризация
- [ ] Проверка резервных копий
- [ ] Анализ логов

## При необходимости
- Развёртывание новых версий
- Миграция данных
- Масштабирование
```

**В Cursor Chat:**

```
Прочитай .cursor-tasks.md и создай cron jobs для этих задач.
Используй VDS 213.155.28.121 для выполнения.
```

---

## 💬 ПРИМЕРЫ PROMPTS ДЛЯ CURSOR

### Пример 1: Быстрое развёртывание

```
Используя файлы в проекте, развёрни Twenty CRM на VDS 213.155.28.121 
за 20 минут. Выведи статус каждого шага.

VDS: root@213.155.28.121
SSH: ~/.ssh/id_rsa
```

### Пример 2: Интеграция Google Sheets

```
@twenty-crm-google-apps-script.gs

Развёрни этот скрипт как синхронизацию между Twenty CRM и моей 
Google Sheet [SHEET_ID].

Настрой:
- Real-time sync при изменении контактов
- Webhook handlers
- Error logging
```

### Пример 3: Мониторинг

```
Создай скрипт мониторинга для Twenty CRM на VDS:

1. Проверка здоровья контейнеров каждые 5 минут
2. Отправка отчёта каждый час в Slack
3. Автоматический рестарт при ошибках
4. Логирование в /docker/logs/

Используй VDS: 213.155.28.121
Slack Webhook: будет передан
```

### Пример 4: Бэкап и восстановление

```
Создай скрипт резервного копирования:

1. Ежедневный бэкап БД в /docker/backups/
2. Загрузка в облако (S3 или Google Drive)
3. Удаление старых бэкапов (>30 дней)
4. Проверка целостности
5. Отправка статуса в Slack
```

---

## 🛠️ РАБОТА С CURSOR TERMINAL

### Запустите скрипт прямо из Cursor

1. **Откройте Terminal в Cursor:** Ctrl+`
2. **В Chat скажите:**

```
Запусти скрипт deploy.sh из Terminal 
и выведи весь логи в реальном времени.
```

3. **Cursor выполнит:**
   - ✅ Откроет Terminal
   - ✅ Запустит скрипт
   - ✅ Покажет прогресс
   - ✅ Выведет результат

---

## 📊 MONITORING & ALERTS

### Спросите Cursor о мониторинге

```
@docker-compose.yml

Создай систему мониторинга, которая:
1. Отслеживает использование ресурсов (CPU, RAM, Disk)
2. Проверяет здоровье контейнеров
3. Отправляет оповещения в Slack при проблемах
4. Логирует все события

Используй Prometheus (или аналог) для метрик.
```

Cursor создаст:
- ✅ Скрипт мониторинга
- ✅ Docker config для Prometheus
- ✅ Alerting rules
- ✅ Dashboard config

---

## 🔐 БЕЗОПАСНОСТЬ

### Скажите Cursor

```
Проверь все файлы конфигурации на проблемы безопасности:

@docker-compose.yml
@.env.production
@twenty-crm-nginx.conf

Убедись что:
1. Нет exposed secrets
2. Все пароли strong
3. SSH ключи не в коммитах
4. Nginx имеет security headers
5. CORS настроен правильно
```

Cursor проверит и предложит исправления.

---

## 🚀 ПОЛНЫЙ WORKFLOW

### День 1: Развёртывание

```
Cursor, используя эти файлы:
- docker-compose.yml
- deploy-twenty.sh
- twenty-crm-nginx.conf

Развёрни Twenty CRM на VDS 213.155.28.121.
```

### День 2: Интеграции

```
Cursor, используя этот скрипт:
- twenty-crm-google-apps-script.gs

Настрой синхронизацию с моей Google Sheet [ID].
```

### День 3-5: Оптимизация

```
Cursor, используя всё, что мы развернули:

Создай скрипты для:
1. Мониторинга
2. Резервных копий
3. Масштабирования
4. Отчётов
```

---

## 📞 ПОЛЕЗНЫЕ КУРСОР-КОМАНДЫ

| Команда | Результат |
|---------|-----------|
| **Cmd+K** | Открыть Chat |
| **Cmd+L** | Выбрать файл для контекста |
| **@filename** | Добавить файл в контекст |
| **Ctrl+`** | Открыть Terminal |
| **Cmd+Shift+P** | Command Palette |
| **/edit** | Режим редактирования |
| **/review** | Просмотреть изменения |

---

## 🎯 РЕКОМЕНДУЕМЫЙ ПОРЯДОК

1. **Откройте Cursor**
2. **Откройте папку проекта** (File → Open Folder)
3. **Откройте Chat** (Cmd+K)
4. **Добавьте файлы** (перетащите или @)
5. **Дайте первый prompt:**

```
Используя все файлы в проекте, 
выполни полное развёртывание Twenty CRM.

VDS: 213.155.28.121
SSH Key: ~/.ssh/id_rsa
Domain: crm.grainee.com

Выведи подробный логи каждого шага.
```

6. **Ждите 15-20 минут**
7. **Готово! Twenty CRM работает** 🎉

---

## ⚙️ НАСТРОЙКИ CURSOR ДЛЯ ОПТИМАЛЬНОЙ РАБОТЫ

**Откройте Settings (Cmd+,):**

```
[Cursor Settings]

AI Model:
  - Model: claude-opus-4 или claude-sonnet-4
  - Temperature: 0.3 (для точности)
  - Max tokens: 4000

Code Execution:
  - Allow terminal: ✅ YES
  - Require approval: ✅ YES
  - Log output: ✅ YES

Context:
  - Include workspace files: ✅ YES
  - Max context size: 100000 tokens
```

---

**ИТОГО:**

Вы можете использовать Cursor несколькими способами:

1. **Fast Mode (быстрый)** — просто prompt в Chat
2. **Project Mode** — папка с файлами + Chat
3. **Integration Mode** — через .cursor-ai.yaml
4. **Continuous Mode** — автоматизированные задачи

**Выберите способ и начинайте!** 🚀
