#!/bin/bash

# Source the utils file
if [ "$SUDO_USER" ]; then
    source "/home/$SUDO_USER/qtools-bootstrap/utils.sh"
elif [ "$HOME" = "/root" ]; then
    source "/root/qtools-bootstrap/utils.sh"
else
    source "$HOME/qtools-bootstrap/utils.sh"
fi

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get service status and uptime
get_status_and_uptime() {
    local status=$(systemctl is-active "$SERVICE_NAME")
    if [ "$status" = "active" ]; then
        local uptime=$(systemctl show "$SERVICE_NAME" --property=ActiveEnterTimestamp | cut -d= -f2)
        local current_time=$(date +%s)
        local start_time=$(date -d "$uptime" +%s)
        local uptime_seconds=$((current_time - start_time))
        local uptime_formatted=$(printf '%dd %dh %dm %ds' $((uptime_seconds/86400)) $((uptime_seconds%86400/3600)) $((uptime_seconds%3600/60)) $((uptime_seconds%60)))
        echo -e "${GREEN}Service Status: Active${NC}"
        echo -e "${GREEN}Uptime: $uptime_formatted${NC}"
    else
        echo -e "${RED}Service Status: $status${NC}"
        echo -e "${RED}Uptime: Not available (service is not active)${NC}"
    fi
}

# Function to get last update time of node binary
get_last_link_update_time() {
    local node_path="/usr/local/bin/node"
    if [ -f "$node_path" ]; then
        local last_modified=$(stat -c %y "$node_path")
        echo -e "${GREEN}Last update time of node binary: $last_modified${NC}"
    else
        echo -e "${RED}Node binary not found at $node_path${NC}"
    fi
}

# Function to get last modified date of bootstrap-node binary
get_bootstrap_node_last_modified() {
    local bootstrap_node_path="$(set_repo_dir)/node/bootstrap-node"
    if [ -f "$bootstrap_node_path" ]; then
        local last_modified=$(stat -c %y "$bootstrap_node_path")
        echo -e "${GREEN}Last modified date of bootstrap-node binary: $last_modified${NC}"
    else
        echo -e "${RED}bootstrap-node binary not found at $bootstrap_node_path${NC}"
    fi
}

# Function to display the menu
show_menu() {
    clear
    get_status_and_uptime
    get_last_link_update_time
    get_bootstrap_node_last_modified
    echo -e "${YELLOW}===== ${SERVICE_NAME} Management Menu =====${NC}"
    echo "1. View Service Status"
    echo "2. View Live Log Output"
    echo "3. Start Service"
    echo "4. Stop Service"
    echo "5. Restart Service"
    echo "6. Check for Updates"
    echo "7. View Last 50 Log Lines"
    echo "8. Uninstall"
    echo "9 (or q). Exit"
}

# Function to view service status
view_status() {
    echo -e "${GREEN}Service Status:${NC}"
    sudo systemctl status "$SERVICE_NAME"
}

# Function to view live log output
view_live_log() {
    echo -e "${GREEN}Live Log Output (press Ctrl+C to exit):${NC}"
    sudo journalctl -u "$SERVICE_NAME" -f
}

# Function to start the service
start_service() {
    echo -e "${GREEN}Starting ${SERVICE_NAME} Service...${NC}"
    sudo systemctl start "$SERVICE_NAME"
}

# Function to stop the service
stop_service() {
    echo -e "${RED}Stopping ${SERVICE_NAME} Service...${NC}"
    sudo systemctl stop "$SERVICE_NAME"
}

# Function to restart the service
restart_service() {
    echo -e "${YELLOW}Restarting ${SERVICE_NAME} Service...${NC}"
    sudo systemctl restart "$SERVICE_NAME"
}

# Function to check for updates
check_updates() {
    echo -e "${YELLOW}Checking for Updates...${NC}"
    /usr/local/bin/update-bootstrap
}

# Function to view last 50 log lines
view_last_logs() {
    echo -e "${GREEN}Last 50 Log Lines:${NC}"
    journalctl -u "$SERVICE_NAME" -n 50 --no-pager
}

# Function to uninstall the service
uninstall_service() {
    echo -e "${YELLOW}This will start the uninstallation process for the Quilibrium Bootstrap Client.${NC}"
    echo -e "${YELLOW}You will be asked which components you want to uninstall.${NC}"
    read -p "Do you want to proceed? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        sudo bash "$(dirname "$0")/uninstall.sh"
        echo "Uninstallation process completed. Exiting management script."
        exit 0
    else
        echo "Uninstallation cancelled."
    fi
}

# Function to handle command-line arguments
handle_argument() {
    case "$1" in
        status) view_status ;;
        log) view_live_log ;;
        start) start_service ;;
        stop) stop_service ;;
        restart) restart_service ;;
        update) check_updates ;;
        lastlog) view_last_logs ;;
        uninstall) uninstall_service ;;
        *) return 1 ;;
    esac
    exit 0
}

# Check for command-line argument
if [ $# -gt 0 ]; then
    handle_argument "$1"
fi

# Main loop
while true
do
    show_menu
    echo -n "Enter your choice [1-9 or q to exit]: "
    read -n 1 -r choice
    echo  # move to a new line

    case $choice in
        1) view_status ;;
        2) view_live_log ;;
        3) start_service ;;
        4) stop_service ;;
        5) restart_service ;;
        6) check_updates ;;
        7) view_last_logs ;;
        8) uninstall_service ;;
        9|q|Q) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}" && sleep 2
    esac
done