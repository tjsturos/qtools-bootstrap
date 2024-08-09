#!/bin/bash

# Source the utils file
source "$(dirname "$0")/utils.sh"

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display the menu
show_menu() {
    clear
    echo -e "${YELLOW}===== ${SERVICE_NAME} Management Menu =====${NC}"
    echo "1. View Service Status"
    echo "2. View Live Log Output"
    echo "3. Start Service"
    echo "4. Stop Service"
    echo "5. Restart Service"
    echo "6. Check for Updates"
    echo "7. View Last 50 Log Lines"
    echo "8. Exit"
    echo
}

# Function to pause
pause() {
    read -p "Press [Enter] key to continue..." fackEnterKey
}

# Function to view service status
view_status() {
    echo -e "${GREEN}Service Status:${NC}"
    systemctl status "$SERVICE_NAME"
    pause
}

# Function to view live log output
view_live_log() {
    echo -e "${GREEN}Live Log Output (press Ctrl+C to exit):${NC}"
    journalctl -u "$SERVICE_NAME" -f
}

# Function to start the service
start_service() {
    echo -e "${GREEN}Starting ${SERVICE_NAME} Service...${NC}"
    systemctl start "$SERVICE_NAME"
    pause
}

# Function to stop the service
stop_service() {
    echo -e "${RED}Stopping ${SERVICE_NAME} Service...${NC}"
    systemctl stop "$SERVICE_NAME"
    pause
}

# Function to restart the service
restart_service() {
    echo -e "${YELLOW}Restarting ${SERVICE_NAME} Service...${NC}"
    systemctl restart "$SERVICE_NAME"
    pause
}

# Function to check for updates
check_updates() {
    echo -e "${YELLOW}Checking for Updates...${NC}"
    /usr/local/bin/update-bootstrap
    pause
}

# Function to view last 50 log lines
view_last_logs() {
    echo -e "${GREEN}Last 50 Log Lines:${NC}"
    journalctl -u "$SERVICE_NAME" -n 50 --no-pager
    pause
}

# Main loop
while true
do
    show_menu
    read -p "Enter your choice [1-8]: " choice
    case $choice in
        1) view_status ;;
        2) view_live_log ;;
        3) start_service ;;
        4) stop_service ;;
        5) restart_service ;;
        6) check_updates ;;
        7) view_last_logs ;;
        8) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Error...${NC}" && sleep 2
    esac
done