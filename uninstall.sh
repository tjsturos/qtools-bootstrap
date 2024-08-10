#!/bin/bash

# Source the utils file
source "$(dirname "$0")/utils.sh"

echo "This script will uninstall components of the Quilibrium Bootstrap Client."
echo "Please select which components you want to uninstall:"

# Initialize variables
uninstall_service=false
remove_binary=false
remove_repo=false
remove_cron=false
remove_aliases=false

# Function to get user input
get_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Ask about each component
get_yes_no "Uninstall and remove the ${SERVICE_NAME} service?" && uninstall_service=true
get_yes_no "Remove the bootstrap node binary?" && remove_binary=true
get_yes_no "Remove the qtools-bootstrap repository?" && remove_repo=true
get_yes_no "Remove the cron job?" && remove_cron=true
get_yes_no "Remove the update-bootstrap and manage-bootstrap aliases?" && remove_aliases=true

# Confirm uninstallation
echo "You have chosen to:"
$uninstall_service && echo "- Uninstall the ${SERVICE_NAME} service"
$remove_binary && echo "- Remove the bootstrap node binary"
$remove_repo && echo "- Remove the qtools-bootstrap repository"
$remove_cron && echo "- Remove the cron job"
$remove_aliases && echo "- Remove the aliases"

get_yes_no "Are you sure you want to proceed with the uninstallation?" || exit 0

# Perform uninstallation based on user choices
if $uninstall_service; then
    echo "Stopping and removing the ${SERVICE_NAME} service..."
    sudo systemctl stop "${SERVICE_NAME}"
    sudo systemctl disable "${SERVICE_NAME}"
    sudo rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
    sudo systemctl daemon-reload
fi

if $remove_binary; then
    echo "Removing the bootstrap node binary..."
    sudo rm -f "/usr/local/bin/node"
fi

if $remove_repo; then
    echo "Removing the qtools-bootstrap repository..."
    rm -rf "$(set_qtools_dir)"
fi

if $remove_cron; then
    echo "Removing the cron job..."
    (crontab -l | grep -v "update-bootstrap") | crontab -
fi

if $remove_aliases; then
    echo "Removing the aliases from .bashrc..."
    HOME_DIR=$(get_home_dir)
    sed -i '/alias update-bootstrap/d' "$HOME_DIR/.bashrc"
    sed -i '/alias manage-bootstrap/d' "$HOME_DIR/.bashrc"
    sed -i '/# Quilibrium Bootstrap aliases/d' "$HOME_DIR/.bashrc"
fi

# Always remove the update-bootstrap script
echo "Removing the update-bootstrap script..."
sudo rm -f "/usr/local/bin/update-bootstrap"

echo "Uninstallation completed based on your choices."
echo "You may need to log out and log back in for all changes to take effect."