# 📦 КАК ЗАГРУЗИТЬ НА GITHUB И ИСПОЛЬЗОВАТЬ С CURSOR

**Пошаговая инструкция**

---

## 🚀 БЫСТРЫЙ СТАРТ (5 МИНУТ)

### Шаг 1: Создайте репозиторий на GitHub

1. Откройте https://github.com
2. Нажмите **"+"** в верхнем правом углу
3. Выберите **"New repository"**
4. Заполните:
   ```
   Repository name: twenty-crm-deployment
   Description: Twenty CRM deployment for GRAINEE
   Public (чтобы Cursor мог доступ)
   Initialize with README
   ```
5. Нажмите **"Create repository"**

### Шаг 2: Скопируйте ссылку репозитория

На странице репозитория нажмите **"Code"** (зелёная кнопка)

Выберите HTTPS и скопируйте ссылку:
```
https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment.git
```

### Шаг 3: Клонируйте репозиторий локально

На вашем компьютере в терминале:

```bash
git clone https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment.git
cd twenty-crm-deployment
```

### Шаг 4: Скопируйте все файлы в папку

Скопируйте все 17 файлов в эту папку:

```bash
# Из папки с файлами
cp ~/Downloads/* ./twenty-crm-deployment/

# Или вручную скопируйте файлы через файловый менеджер
```

### Шаг 5: Загрузите на GitHub

```bash
cd twenty-crm-deployment

# Добавьте все файлы
git add .

# Создайте коммит
git commit -m "Initial commit: Twenty CRM deployment files"

# Загрузьте на GitHub
git push origin main
```

### ✅ Готово!

Теперь репозиторий доступен на GitHub.

---

## 🤖 КАК ИСПОЛЬЗОВАТЬ С CURSOR

### Способ 1: Клонировать в Cursor (САМЫЙ БЫСТРЫЙ)

```bash
# В Cursor Terminal (Ctrl+`):

git clone https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment.git
cd twenty-crm-deployment
```

Теперь все файлы в Cursor и готовы к использованию!

### Способ 2: Открыть через Cursor

1. В Cursor: **File → Open Folder**
2. Выберите папку `twenty-crm-deployment`
3. **Cmd+K** → Chat в Cursor
4. Все файлы доступны через **@имя_файла**

### Способ 3: Использовать напрямую из GitHub

В Cursor Chat скопируйте этот prompt:

```
GitHub репозиторий: https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment

Клонируй репозиторий и развёрни Twenty CRM используя файлы:

1. git clone https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment.git
2. cd twenty-crm-deployment
3. Используй deploy-twenty.sh для развёртывания на VDS 213.155.28.121

SSH Key: ~/.ssh/id_rsa
VDS User: root

Выведи статус каждого шага.
```

---

## 📂 СТРУКТУРА РЕПОЗИТОРИЯ

Рекомендуемая структура:

```
twenty-crm-deployment/
├── README.md                          (главный файл)
├── .gitignore                         (исключить пароли)
├── CHANGELOG.md                       (история изменений)
│
├── docs/                              (документация)
│   ├── QUICK_START.md
│   ├── TWENTY_CRM_SETUP_COMPLETE.md
│   ├── twenty-crm-deployment-plan.md
│   └── FOUNDER-NOTES-TWENTY-CRM-UPDATE.md
│
├── cursor/                            (для Cursor AI)
│   ├── CURSOR-БЫСТРЫЙ-СТАРТ.md
│   ├── CURSOR-ПОЛНАЯ-ИНСТРУКЦИЯ.md
│   ├── CURSOR-AI-РУССКИЙ.md
│   └── CURSOR-AI-PROMPT.md
│
├── config/                            (конфигурация)
│   ├── docker-compose.yml
│   ├── .env.production
│   ├── .env.example
│   ├── twenty-crm-nginx.conf
│   └── twenty-crm-google-apps-script.gs
│
├── scripts/                           (скрипты)
│   ├── deploy.sh
│   ├── verify.sh
│   ├── backup.sh
│   └── monitor.sh
│
└── .github/                           (для GitHub Actions)
    └── workflows/
        ├── deploy.yml
        └── test.yml
```

---

## 🛠️ СОЗДАЙТЕ .gitignore

Создайте файл `.gitignore` в корне:

```
# Secrets and credentials
.env
.env.local
.env.*.local
*.key
*.pem
id_rsa
id_rsa.pub

# Logs
logs/
*.log
npm-debug.log*

# Dependencies
node_modules/
.npm

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Backups
*.backup
*.bak
backups/
```

---

## 📝 СОЗДАЙТЕ ГЛАВНЫЙ README.md

```markdown
# Twenty CRM Deployment

Полный пакет для развёртывания Twenty CRM на VDS с Cursor AI.

## 🚀 Быстрый старт

### С Cursor AI (15 минут)

1. Откройте Cursor
2. Cmd+K (Chat)
3. Скопируйте из `cursor/CURSOR-БЫСТРЫЙ-СТАРТ.md`
4. Вставьте в Chat
5. ENTER

### Ручное развёртывание (30 минут)

Смотрите `docs/QUICK_START.md`

## 📦 Содержимое

- `docs/` - Полная документация
- `cursor/` - Инструкции для Cursor AI
- `config/` - Конфигурационные файлы
- `scripts/` - Автоматизированные скрипты

## 🔗 Файлы

- `docker-compose.yml` - Docker контейнеры
- `deploy-twenty.sh` - Скрипт развёртывания
- `twenty-crm-nginx.conf` - Nginx конфигурация
- `.env.production` - Переменные окружения

## 📚 Документация

- [QUICK_START.md](docs/QUICK_START.md) - Пошаговая инструкция
- [TWENTY_CRM_SETUP_COMPLETE.md](docs/TWENTY_CRM_SETUP_COMPLETE.md) - Полная документация
- [CURSOR-БЫСТРЫЙ-СТАРТ.md](cursor/CURSOR-БЫСТРЫЙ-СТАРТ.md) - Cursor AI инструкция

## 🎯 Требования

- VDS IP: 213.155.28.121
- SSH доступ: root@213.155.28.121
- Domain: crm.grainee.com
- Docker установлен на VDS

## 🔧 Поддержка

Для вопросов смотрите документацию в папке `docs/`.
```

---

## 🚀 ОТПРАВЬТЕ НА GITHUB

```bash
# Создайте папку для репозитория
mkdir ~/twenty-crm-deployment
cd ~/twenty-crm-deployment

# Инициализируйте git (если ещё не клонировали)
git init

# Добавьте remote
git remote add origin https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment.git

# Убедитесь что есть .gitignore (смотрите выше)
nano .gitignore

# Добавьте все файлы
git add .

# Первый коммит
git commit -m "Initial commit: Twenty CRM deployment package"

# Загрузите
git push -u origin main
```

---

## ✅ ПРОВЕРЬТЕ НА GITHUB

1. Откройте https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment
2. Вы должны увидеть все файлы
3. Скопируйте ссылку: `https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment.git`

---

## 🤖 ИСПОЛЬЗУЙТЕ С CURSOR

### Способ A: Клонировать

```bash
# В Cursor Terminal:
git clone https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment.git
cd twenty-crm-deployment
```

### Способ B: Prompt для Cursor

```
GitHub: https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment

Клонируй и развёрни Twenty CRM используя файлы из репозитория.
VDS: 213.155.28.121
SSH: ~/.ssh/id_rsa
```

---

## 🔄 ОБНОВЛЕНИЯ

Если вы хотите добавить новые файлы или изменить существующие:

```bash
cd ~/twenty-crm-deployment

# Отредактируйте файлы
nano config/docker-compose.yml

# Добавьте изменения
git add .

# Создайте коммит
git commit -m "Update: улучшение конфигурации"

# Загрузите
git push origin main
```

---

## 📊 СТРУКТУРА GITHUB

Ваш репозиторий будет выглядеть так:

```
twenty-crm-deployment/
├── README.md
├── .gitignore
├── docs/
│   ├── QUICK_START.md
│   └── ...
├── cursor/
│   ├── CURSOR-БЫСТРЫЙ-СТАРТ.md
│   └── ...
├── config/
│   ├── docker-compose.yml
│   └── ...
└── scripts/
    ├── deploy.sh
    └── ...
```

---

## 🎯 ФИНАЛЬНАЯ ССЫЛКА

Когда всё готово, ваша ссылка будет:

```
https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment
```

Используйте эту ссылку в Cursor:

```
GitHub: https://github.com/ВАШ_ЮЗЕР/twenty-crm-deployment

Разверни Twenty CRM используя файлы из этого репозитория.
```

---

**Готово! Теперь всё на GitHub и готово к использованию с Cursor! 🚀**
