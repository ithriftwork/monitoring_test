# Система мониторинга процессов для Linux
Автоматическая система мониторинга, которая отслеживает состояние процесса test и отправляет отчеты на сервер мониторинга.

## Примечания
Система требует наличия curl для HTTP запросов\
Рекомендуется тестирование в staging среде перед развертыванием\
Для продакшн использования настройте реальный URL мониторинга

## Функциональность
-  Мониторинг процесса каждую минуту
-  Автозапуск при загрузке системы
-  Отправка HTTPS отчетов на сервер мониторинга
-  Логирование перезапусков процесса
-  Логирование ошибок связи с сервером
-  Отслеживание изменений статуса процесса

## Структура проекта
**monitoring-system/**
- **monitor_test.sh** (Основной скрипт мониторинга)
- **monitor_test.service** (Systemd service unit)
- **monitor_test.timer** (Systemd timer unit)
- **install.sh** (Скрипт установки)
- **test-monitoring.sh** (Скрипт для автоматической проверки работоспособности системы)


## Установка

### Автоматическая установка:
sudo chmod +x install.sh\
sudo ./install.sh


### Ручная установка:

**Копировать файлы:**\
sudo cp monitor_test.sh /usr/local/bin/\
sudo chmod +x /usr/local/bin/monitor_test.sh\
sudo cp monitor_test.service /etc/systemd/system/\
sudo cp monitor_test.timer /etc/systemd/system/

**Создать необходимые файлы:**\
sudo touch /var/log/monitoring.log\
sudo touch /var/run/monitor_test.last\
sudo chmod 644 /var/log/monitoring.log /var/run/monitor_test.last

**Активировать systemd:**\
sudo systemctl daemon-reload\
sudo systemctl enable monitor_test.timer\
sudo systemctl start monitor_test.timer


## Основные команды скрипта

**Проверить статус процесса:**\
sudo /usr/local/bin/monitor_test.sh status

**Запустить мониторинг вручную:**\
sudo /usr/local/bin/monitor_test.sh start

**Тестирование системы:**\
sudo /usr/local/bin/monitor_test.sh test

**Автоматический запуск (по умолчанию):**\
sudo /usr/local/bin/monitor_test.sh


## Systemd команды

**Статус таймера:**\
sudo systemctl status monitor_test.timer

**Статус сервиса:**\
sudo systemctl status monitor_test.service

**Включить/выключить автозапуск:**\
sudo systemctl enable monitor_test.timer\
sudo systemctl disable monitor_test.timer

**Запустить/остановить таймер:**\
sudo systemctl start monitor_test.timer\
sudo systemctl stop monitor_test.timer

## Логирование
**Логи:**\
/var/log/monitoring.log


### Просмотр логов

**Реальный времени:**\
sudo tail -f /var/log/monitoring.log

**Последние 20 записей:**\
sudo tail -n 20 /var/log/monitoring.log

**Поиск ошибок:**\
sudo grep -i error /var/log/monitoring.log

## Автоматическая проверка работоспособности системы
sudo chmod +x test_monitoring.sh\
sudo ./test_monitoring.sh

## Полное удаление системы

**Остановить и отключить сервисы:**\
sudo systemctl stop monitor_test.timer\
sudo systemctl disable monitor_test.timer\
sudo systemctl stop monitor_test.service

**Удалить файлы:**\
sudo rm -f /usr/local/bin/monitor_test.sh\
sudo rm -f /etc/systemd/system/monitor_test.service\
sudo rm -f /etc/systemd/system/monitor_test.timer\
sudo rm -f /var/run/monitor_test.last

**Очистить systemd:**\
sudo systemctl daemon-reload
