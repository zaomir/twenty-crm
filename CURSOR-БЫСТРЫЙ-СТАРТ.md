# ⚡ CURSOR - БЫСТРЫЙ СТАРТ

**Как работать с Cursor за 5 минут**

---

## 🚀 СПОСОБ 1: САМЫЙ БЫСТРЫЙ (копировать → запустить)

### Шаг 1: Откройте Cursor Chat

```
Нажмите: Cmd+K (Mac) или Ctrl+K (Windows/Linux)
```

### Шаг 2: Скопируйте этот текст

```
Я хочу развернуть Twenty CRM на VDS 213.155.28.121.

Файлы готовы:
- docker-compose.yml
- .env.production
- twenty-crm-nginx.conf
- deploy-twenty.sh

Выполни:
1. Проверь SSH: ssh -i ~/.ssh/id_rsa root@213.155.28.121
2. Отправь файлы: scp *.yml *.production *.conf *.sh root@213.155.28.121:/tmp/
3. На VDS: cd /tmp && chmod +x deploy-twenty.sh && sudo bash deploy-twenty.sh
4. Настрой nginx: sudo cp twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm
5. SSL: sudo certbot certonly --standalone -d crm.grainee.com --non-interactive --agree-tos --email admin@grainee.com
6. Проверь: docker ps | grep twenty

SSH ключ: ~/.ssh/id_rsa
Выведи статус каждого шага.
```

### Шаг 3: Вставьте в Cursor Chat

```
Cmd+V (Mac) или Ctrl+V (Windows)
```

### Шаг 4: Нажмите Enter

Cursor автоматически:
- ✅ Создаст скрипты
- ✅ Выполнит развёртывание
- ✅ Покажет результаты

**Время: 15-20 минут ⏱️**

---

## 📂 СПОСОБ 2: ЧЕРЕЗ ПАПКУ ПРОЕКТА

### Шаг 1: Откройте папку в Cursor

```
Cmd+O (Mac) или Ctrl+O (Windows)
→ Выберите папку с файлами
```

### Шаг 2: Откройте Chat

```
Cmd+K или Ctrl+K
```

### Шаг 3: Добавьте файлы в контекст

В Chat введите:

```
@docker-compose.yml @deploy-twenty.sh @twenty-crm-nginx.conf @.env.production

Развёрни Twenty CRM на VDS 213.155.28.121 используя эти файлы.
```

Cursor покажет все файлы и выполнит развёртывание.

---

## 🎯 СПОСОБ 3: ЧЕРЕЗ DRAG & DROP

### Шаг 1: Откройте Cursor Chat

```
Cmd+K или Ctrl+K
```

### Шаг 2: Перетащите файлы в окно Chat

```
Просто перетащите файлы из папки в окно Chat
```

### Шаг 3: Дайте Cursor команду

```
Развёрни Twenty CRM используя эти файлы.
VDS: 213.155.28.121
SSH Key: ~/.ssh/id_rsa
```

### Шаг 4: Enter

Готово! Cursor выполнит всё.

---

## 💬 ЛУЧШИЕ PROMPTS ДЛЯ CURSOR

### Prompt 1: Развёртывание (копируй целиком)

```
Используя файлы проекта:
- docker-compose.yml (контейнеры)
- deploy-twenty.sh (скрипт)
- twenty-crm-nginx.conf (веб-сервер)
- .env.production (переменные)

Выполни полное развёртывание Twenty CRM:

1. Проверь SSH доступ к root@213.155.28.121
2. Отправь все 4 файла на VDS в /tmp/
3. На VDS запусти: cd /tmp && chmod +x deploy-twenty.sh && sudo bash deploy-twenty.sh
4. Скопируй nginx: sudo cp twenty-crm-nginx.conf /etc/nginx/sites-available/twenty-crm
5. Проверь nginx: sudo nginx -t && sudo systemctl reload nginx
6. Получи SSL: sudo certbot certonly --standalone -d crm.grainee.com --non-interactive --agree-tos --email admin@grainee.com
7. Проверь контейнеры: docker ps | grep twenty
8. Проверь API: curl http://localhost:3001/health
9. Проверь GRAINEE: curl http://localhost:3000

SSH Key: ~/.ssh/id_rsa
VDS User: root
VDS IP: 213.155.28.121
Domain: crm.grainee.com

Выведи:
- Статус каждого шага (✅ или ❌)
- Любые ошибки с решениями
- Финальный результат
```

### Prompt 2: Google Sheets Sync

```
@twenty-crm-google-apps-script.gs

Развёрни этот скрипт для синхронизации:

1. Скопируй содержимое скрипта
2. В Google Sheets → Extensions → Apps Script
3. Удали старый код и вставь новый
4. Обнови переменные:
   - TWENTY_API_TOKEN = (API токен из CRM)
   - SPREADSHEET_ID = (ID твоей таблицы)
5. Развёрни как Web App
6. Скопируй Deployment URL
7. Добавь webhook в Twenty CRM: Deployment URL
8. Протестируй на примере контакта

Выведи:
- Ссылку на развёрнутый скрипт
- Webhook URL для Twenty CRM
- Статус синхронизации
```

### Prompt 3: Мониторинг

```
Создай скрипт мониторинга для Twenty CRM:

1. Проверка health контейнеров каждые 5 минут
2. Логирование в файл /docker/logs/monitor.log
3. Автоматический рестарт при ошибках
4. Отправка оповещений в Slack (если включено)

Скрипт должен:
- Проверять docker ps | grep twenty
- Проверять curl http://localhost:3001/health
- Проверять curl http://localhost:3000 (GRAINEE)
- Проверять диск: df -h /docker
- Логировать время, статус, ошибки

VDS: 213.155.28.121
SSH: ~/.ssh/id_rsa
```

### Prompt 4: Резервные копии

```
Создай скрипт резервного копирования:

1. Ежедневный бэкап PostgreSQL в /docker/backups/
2. Имя файла: twenty_YYYY-MM-DD.sql.gz
3. Удаление старых бэкапов (старше 30 дней)
4. Проверка целостности бэкапа
5. Логирование: размер, время, статус
6. Отправка отчёта по email (если включено)

Cron:
- Запуск ежедневно в 3 AM UTC
- Проверка целостности по воскресеньям

VDS: 213.155.28.121
SSH: ~/.ssh/id_rsa
```

---

## 🔧 ВАЖНЫЕ КОМАНДЫ CURSOR

| Действие | Комбинация |
|----------|----------|
| **Открыть Chat** | Cmd+K (Mac) / Ctrl+K (Windows) |
| **Открыть папку** | Cmd+O / Ctrl+O |
| **Открыть Terminal** | Ctrl+` (везде) |
| **Вставить файл в контекст** | Cmd+L / Ctrl+L |
| **Добавить файл через @** | Введи @filename |
| **Выполнить файл** | Cmd+Enter / Ctrl+Enter |

---

## 📋 ЧЕКЛИСТ ПЕРЕД ЗАПУСКОМ

Перед тем как дать Cursor команду:

- [ ] Скопировали все 4 файла:
  - docker-compose.yml
  - .env.production
  - twenty-crm-nginx.conf
  - deploy-twenty.sh

- [ ] Проверили SSH доступ:
  ```bash
  ssh -i ~/.ssh/id_rsa root@213.155.28.121 "echo OK"
  ```

- [ ] Убедились что домен crm.grainee.com указывает на VDS:
  ```bash
  nslookup crm.grainee.com
  ```

- [ ] Cursor установлен и работает

- [ ] У вас есть интернет соединение

**Если всё ✅ — начинайте!**

---

## ✅ ПОСЛЕ РАЗВЁРТЫВАНИЯ

### Проверьте в браузере

```
https://crm.grainee.com
```

Вы должны увидеть:
- Экран входа Twenty CRM
- HTTPS (замок в адресной строке)
- Форма для создания admin аккаунта

### Создайте админ аккаунт

```
Email: total@grainee.com
Password: Надёжный пароль
Company: GRAINEE Main
```

### Затем

1. Создайте workspace'ы (GRAINEE, ROVLEX, ARBITR)
2. Настройте интеграции (Google Sheets, WhatsApp, Stripe)
3. Читайте TWENTY_CRM_SETUP_COMPLETE.md для дальнейших шагов

---

## 🆘 ЕСЛИ ЧТО-ТО НЕ РАБОТАЕТ

### Спросите Cursor

```
Cmd+K

Произошла ошибка при развёртывании Twenty CRM.
Ошибка: [скопируй ошибку отсюда]

Исправь или предложи решение.
```

Cursor:
- ✅ Разберётся в проблеме
- ✅ Предложит решение
- ✅ Поможет её исправить

---

## 🎯 БЫСТРЫЙ ПУТЬ

1. **Откройте Cursor** → **Cmd+K**
2. **Вставьте prompt из "Способ 1"** выше
3. **Нажмите Enter**
4. **Ждите 15-20 минут**
5. **Откройте https://crm.grainee.com**
6. **Готово! 🎉**

---

## 📚 ДОПОЛНИТЕЛЬНО

Для более подробной инструкции смотрите:
- `CURSOR-ПОЛНАЯ-ИНСТРУКЦИЯ.md` (полная версия)
- `QUICK_START.md` (пошаговая версия)
- `TWENTY_CRM_SETUP_COMPLETE.md` (все фазы)

---

**Версия:** 1.0  
**Статус:** ✅ ГОТОВО  
**Время:** 15-20 минут  

**НАЧНИТЕ СЕЙЧАС! 🚀**
