#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
MONITORING_URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test"
LAST_STATUS_FILE="/var/run/monitor_test.last"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

is_process_running() {
    pgrep -x "$PROCESS_NAME" > /dev/null 2>&1
}

get_process_status() {
    if is_process_running; then
        echo "running"
    else
        echo "stopped"
    fi
}

get_last_status() {
    if [[ -f "$LAST_STATUS_FILE" && -s "$LAST_STATUS_FILE" ]]; then
        cat "$LAST_STATUS_FILE"
    else
        echo "unknown"
    fi
}

save_current_status() {
    local status="$1"
    echo "$status" > "$LAST_STATUS_FILE"
}

send_monitoring_data() {
    local status="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    local payload=$(cat << EOF 
{
    "process_name": "$PROCESS_NAME",
    "status": "$status",
    "timestamp": "$timestamp",
    "hostname": "$(hostname)"
}
EOF
    )

    local response=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "User-Agent: ProcessMonitor/1.0" \
        -d "$payload" \
        --connect-timeout 10 \
        --max-time 30 \
        "$MONITORING_URL")

    echo "$response"
}

main() {
    local current_status=$(get_process_status)
    local last_status=$(get_last_status)

    if [[ "$current_status" == "running" ]]; then
        if [[ "$last_status" == "stopped" ]]; then
            log_message "PROCESS_RESTARTED - Process '$PROCESS_NAME' was restarted"
        fi

        local http_code=$(send_monitoring_data "$current_status")

        if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
            log_message "MONITORING_SUCCESS - Status reported successfully (HTTP $http_code)"
        else
            log_message "MONITORING_FAILED - Server unreachable or error (HTTP $http_code)"
        fi

        save_current_status "$current_status"

    elif [[ "$current_status" == "stopped" && "$last_status" == "running" ]]; then
        log_message "PROCESS_STOPPED - Process '$PROCESS_NAME' stopped"
        save_current_status "$current_status"
    fi
}

case "${1:-}" in
    start)
        echo "Starting process monitoring..."
        main
        ;;
    status)
        echo "Current process status: $(get_process_status)"
        echo "Last known status: $(get_last_status)"
        ;;
    test)
        echo "Monitoring testing..."
        echo "Process is running: $(is_process_running && echo 'Yes' || echo 'No')"
        echo "Monitoring URL: $MONITORING_URL"
        ;;
    *)
        main
        ;;
esac
