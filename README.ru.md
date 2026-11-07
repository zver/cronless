[English](README.md) | **Русский**

# Cronless

**Cronless** — лёгкий менеджер периодических задач для Linux на основе systemd timers.
Подходит для ноутбуков и рабочих станций, которые часто уходят в спящий режим: пропущенные запуски выполняются после пробуждения системы.

---

## Возможности

- Лёгкая замена cron без постоянной нагрузки на систему.
- Управление задачами через CLI: добавление, удаление, ручной запуск, просмотр логов и другое (см. [Команды](#команды)).
- Поддержка systemd timers с `Persistent=true`: задачи, пропущенные во время сна, выполняются после пробуждения системы.
- Отчёт о выполнении задач (`cronless report`):
  - количество запусков за выбранный период;
  - успешные и неудачные выполнения;
  - максимальное время выполнения.
- Экспорт метрик в формате [textfile collector](https://github.com/prometheus/node_exporter#textfile-collector) для Prometheus node_exporter.

---

## Установка

### Debian и производные дистрибутивы (одной командой)

```bash
curl -sL https://raw.githubusercontent.com/zver/cronless/refs/heads/master/scripts/install-latest-from-github | bash
```

Команда скачивает и запускает скрипт, который находит на GitHub deb-пакет последнего релиза и устанавливает его.

> Скрипт можно предварительно просмотреть: [install-latest-from-github](https://github.com/zver/cronless/blob/master/scripts/install-latest-from-github).

Либо скачайте deb-пакет вручную со [страницы релизов](https://github.com/zver/cronless/releases) и установите его:

```bash
sudo apt install ./<файл>.deb
```

### Ansible

См. [отдельный репозиторий с Ansible-ролью](https://github.com/zver/ansible-cronless/).

---

## Использование

Вместо `cronless` можно использовать короткое имя `cl`.

### Команды

| Команда | Описание |
| :------ | :------- |
| `cronless add <name> "<command>" "<schedule>"` | Добавить задачу |
| `cronless remove <name>` | Удалить задачу |
| `cronless list` | Показать список задач с последним результатом |
| `cronless edit <name>` | Открыть в редакторе скрипт запуска задачи |
| `cronless logs <name>` | Показать логи задачи |
| `cronless debug <name>` | Запустить задачу в режиме отладки |
| `cronless run <name>` | Запустить задачу вручную, выполнив её скрипт напрямую |
| `cronless start <name>` | Запустить задачу вручную через systemd-сервис: информация о запуске попадёт в journald и метрики Prometheus |
| `cronless enable <name>` | Включить выполнение задачи по расписанию |
| `cronless disable <name>` | Отключить выполнение задачи по расписанию |
| `cronless report [-d <days>] [-n <count>]` | Показать отчёт о выполнении задач (см. [Опции отчёта](#опции-отчёта)) |
| `cronless update-node-exporter-textfile <path>` | Обновить файл с метриками для node_exporter |

### Опции отчёта

Команда `cronless report` принимает следующие флаги:

| Флаг | Описание |
| :--- | :------- |
| `-d <days>` | Ограничивает количество дней лога, в которых ищется информация для отчёта |
| `-n <count>` | Ограничивает количество результатов выполнения задач в отчёте |

### Примеры

```bash
# Добавить ежедневную задачу
cronless add backup "/usr/local/bin/backup_db.sh" daily

# Добавить еженедельную задачу с отправкой отчёта cronless на email
# (замените you@example.com на свой адрес)
cronless add cronless-report-to-email "cronless report -d 7 -n 20 2>&1 | mail -s 'Cronless weekly report' you@example.com" weekly

# Показать список задач с последним результатом
cronless list

# Открыть в редакторе скрипт запуска задачи
cronless edit backup

# Показать логи задачи
cronless logs backup

# Запустить задачу в режиме отладки
cronless debug backup

# Запустить задачу вручную, выполнив её скрипт
cronless run backup

# Запустить задачу вручную через systemd-сервис,
# который уже запустит исполняемый скрипт.
# Так информация о запуске попадёт в journald и метрики Prometheus
cronless start backup

# Отключить выполнение задачи по расписанию
cronless disable backup

# Включить выполнение задачи по расписанию
cronless enable backup

# Получить недельный отчёт: информация за 7 дней лога, не более 20 результатов выполнения
cronless report -d 7 -n 20

# Отправить отчёт на почту
cronless report -d 7 -n 20 | mail -s "Weekly Tasks Report" you@example.com

# Удалить задачу
cronless remove backup
```

---

## Формат расписания

Расписание задаётся в формате systemd [calendar events](https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Calendar%20Events). Несколько примеров:

| Значение | Что делает |
| :------- | :--------- |
| `daily` | Каждый день в 00:00 |
| `weekly` | Каждый понедельник в 00:00 |
| `*-*-* 03:30:00` | Каждый день в 03:30 |
| `Mon *-*-* 02:00:00` | Каждый понедельник в 02:00 |
| `*:0/30` | Каждые 30 минут |
| `*-*-* *:0/15:00` | Каждые 15 минут |

Проверить выражение и узнать время ближайшего запуска можно командой:

```bash
systemd-analyze calendar "*-*-* *:0/15:00"
```

---

## Метрики для Prometheus

Команда `cronless update-node-exporter-textfile <path-to-metrics.prom>` обновляет файл с метриками cronless в формате [textfile collector](https://github.com/prometheus/node_exporter#textfile-collector).

Чтобы файл обновлялся автоматически, добавьте эту команду как периодическую задачу. Например, каждые 5 минут (`$USER` подставляется оболочкой в момент добавления задачи):

```bash
cronless add update-prometheus-textfile-for-cronless-tasks "cronless update-node-exporter-textfile /var/lib/node_exporter/textfile_collector/cronless.$USER.prom" "*-*-* *:0/5:00"
```

---

## Сборка deb-пакета самостоятельно

Выполните в корне репозитория:

```bash
sudo apt install debhelper devscripts build-essential
dpkg-buildpackage -us -uc
```

Готовый пакет появится в родительском каталоге.

---

## Структура проекта

- `debian/` — файлы для сборки deb-пакета;
- `scripts/` — скрипты самого cronless.
