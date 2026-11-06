# Cronless

**Cronless** — лёгкий менеджер периодических задач на Linux с использованием systemd timers.  
Идеален для ноутбуков и рабочих станций, которые часто уходят в спящий режим. Задачи выполняются даже после пробуждения системы.

---

## 🚀 Возможности

- Лёгкая замена cron, без постоянной нагрузки на систему
- Добавление и удаление задач через CLI:
  - `cronless add <name> "<command>" "<schedule>"`
  - `cronless remove <name>`
  - `cronless list`
  - `cronless run <name>`
  - `cronless logs <name>`
- Еженедельный отчёт:

```cronless report```

  - количество запусков за последние дни
  - успешные и неудачные выполнения
  - максимальное время выполнения
- Экспорт метрик cronless в формате [node_exporter textfile_collector](https://prometheus.io/docs/prometheus/latest/configuration/template_processing/#textfile_collector):
  - `cronless update-node-exporter-textfile <path-to-metrics.prom>` — обновит файл с метриками
  - можно добавить как periodic task для автоматической генерации
- Поддержка systemd timers с `Persistent=true` — задачи выполняются даже если ноут спал

---

## Установка

### Однострочная команда для OS, основанных на Debian.

```curl -sL https://raw.githubusercontent.com/zver/cronless/refs/heads/master/scripts/install-latest-from-github | bash```

Этой командой скачивается и запускается скрипт. Он ищет на github deb-пакет последнего релиза и затем устанавливает его.

### Ansible

Смотри [отдельный репозитарий с ansible ролью](https://github.com/zver/ansible-cronless/).

---

## 📂 Структура проекта

debian - файлы для сборки deb-пакета
scripts - скрипты самого cronless

---

## Примеры команд

```
# Добавить ежедневную задачу
cronless add backup "/usr/local/bin/backup_db.sh" daily

# Добавить еженедельную задачу с отправкой отчета cronless на email
cronless add cronless-report-to-email "cronless report -d 7 -n 20 2>&1 | mail -s 'Cronless weekly report' FIXME@example.com" weekly

# Удалить задачу
cronless remove backup

# Список задач с последним результатом
cronless list

# Получить логи
cronless logs backup

# запустить задачу вручную через выполнение скрипта
cronless run backup

# запустить задачу вручную через systemd сервис,
# который уже запустит исполняемый скрипт
# так информация о запуске попадет в journald и prometheus метрики
cronless start backup

# отключить выполнение задачи по расписанию
cronless disable backup

# включить выполнение задачи по расписанию
cronless disable backup

# получить недельный отчёт
cronless report -d 7 -n 20

# Отправить его на почту
cronless report -d 7 -n 20 | mail -s "Weekly Tasks Report" you@example.com

# Автоматически обновлять файлы метрик node_exporter
cronless add update-prometheus-textfile-for-cronless-tasks "cronless update-node-exporter-textfile /var/lib/node_exporter/textfile_collector/cronless.$USER.prom" "*-*-* *:0/5:00"
```

---

## Формат расписания

Systemd использует формат CalendarEvents. Несколько примеров:

|  Значение  |  Что делает  |
| :------------ | :------------ |
|  ```daily```  | Каждый день в 00:00  |
|  ```weekly``` |  Каждый понедельник в 00:00 |
|  ```*-*-* 03:30:00``` |	Каждый день в 03:30 |
|  ```Mon *-*-* 02:00:00```	| Каждую неделю в понедельник 02:00 |
|  ```*:0/30```	| Каждые 30 минут (каждый час) |
|  ```*-*-* *:0/15:00``` | Каждые 15 минут (время в формате HH:MM:SS) |

---

## Сборка deb-пакета самостоятельно

```
sudo apt install debhelper devscripts build-essential
dpkg-buildpackage -us -uc
```