# Добавить ежедневную задачу
cronless-manage-tasks add backup "/usr/local/bin/backup_db.sh" daily

# Добавить еженедельную задачу с отправкой отчета cronless на email
cronless-manage-tasks add cronless-report-to-email "cronless-weekly-report 2>&1 | mail -s 'Cronless weekly report' FIXME@example.com" weekly

# Удалить задачу
cronless-manage-tasks remove backup

# Список задач с последним результатом
cronless-manage-tasks list

# запустить задачу вручную
cronless-run-task backup

# получить недельный отчёт
cronless-weekly-report
cronless-weekly-report | mail -s "Weekly Tasks Report" you@example.com


# сборка
sudo apt install debhelper devscripts build-essential
dpkg-buildpackage -us -uc

