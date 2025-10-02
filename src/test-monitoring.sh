#!/bin/bash

echo "TESTING THE MONITORING SYSTEM"

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

test_passed() {
    echo -e "${GREEN}✓ $1${NC}"
}

test_failed() {
    echo -e "${RED}✗ $1${NC}"
}

# Проверка установки
echo "1. Checking the installed components..."
if [ -f "/usr/local/bin/monitor_test.sh" ]; then
    test_passed "The monitoring script is installed"
else
    test_failed "The monitoring script was not found"
fi

if systemctl is-enabled monitor_test.timer >/dev/null 2>&1; then
    test_passed "The timer is on"
else
    test_failed "The timer is off"
fi

# Проверка работы
echo -e "\n2. Checking the script operation..."
sudo /usr/local/bin/monitor_test.sh status
if [ $? -eq 0 ]; then
    test_passed "The script status is working"
else
    test_failed "The script status is not working"
fi

# Проверка логов
echo -e "\n3. Checking the logging system..."
if [ -f "/var/log/monitoring.log" ]; then
    test_passed "The log file exists"
    echo "Recent log entries:"
    sudo tail -n 3 /var/log/monitoring.log
else
    test_failed "The log file does not exist"
fi

# Итог
echo -e "\nTEST RESULTS"
echo "For full verification:"
echo "1. Wait for the next minute (xx:01, xx:02, etc.)"
echo "2. Check the logs: sudo tail -f /var/log/monitoring.log"
echo "3. Make sure there are recordings every minute."
