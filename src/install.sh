#!/bin/bash

set -e

SCRIPT_NAME="monitor_test.sh"
SERVICE_NAME="monitor_test.service"
TIMER_NAME="monitor_test.timer"
INSTALL_DIR="/usr/local/bin"
SERVICE_DIR="/etc/systemd/system"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    exit 1
fi

if [[ ! -f "$SCRIPT_NAME" ]]; then
    print_error "Main script $SCRIPT_NAME not found in current directory"
    exit 1
fi

if [[ ! -f "$SERVICE_NAME" ]]; then
    print_error "Service file $SERVICE_NAME not found in current directory"
    exit 1
fi

if [[ ! -f "$TIMER_NAME" ]]; then
    print_error "Timer file $TIMER_NAME not found in current directory"
    exit 1
fi

print_status "Installing process monitoring system..."

print_status "Copying $SCRIPT_NAME to $INSTALL_DIR/"
cp "$SCRIPT_NAME" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

print_status "Copying systemd service and timer files..."
cp "$SERVICE_NAME" "$SERVICE_DIR/"
cp "$TIMER_NAME" "$SERVICE_DIR/"

print_status "Creating log file..."
touch /var/log/monitoring.log
chmod 644 /var/log/monitoring.log

print_status "Creating status directory..."
mkdir -p /var/run/
touch /var/run/monitor_test.last
chmod 644 /var/run/monitor_test.last

print_status "Reloading systemd daemon..."
systemctl daemon-reload

print_status "Enabling and starting monitor timer..."
systemctl enable "$TIMER_NAME"
systemctl start "$TIMER_NAME"

print_status "Testing the monitoring service..."
if systemctl start "$SERVICE_NAME"; then
    print_status "Service test completed successfully"
else
    print_error "Service test failed"
    exit 1
fi

print_status "Installation completed successfully!"
print_status "Monitoring will start on next boot and run every minute."
print_status "Log file: /var/log/monitoring.log"
print_status "Timer status: systemctl status $TIMER_NAME"
print_status "Service status: systemctl status $SERVICE_NAME"
print_status "Manual test: $INSTALL_DIR/$SCRIPT_NAME status"
