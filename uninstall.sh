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
remove_update_script=false
remove_auto_completion=false
remove_ceremonyclient=false

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

# Function to remove auto-completion
remove_auto_completion() {
    if [ -f /etc/bash_completion.d/manage-bootstrap-completion.sh ]; then
        echo "Removing auto-completion for manage-bootstrap..."
        sudo rm /etc/bash_completion.d/manage-bootstrap-completion.sh
        echo "Auto-completion removed. You may need to restart your shell for changes to take effect."
    fi
}

# Function to remove repository
remove_repository() {
    echo "Removing qtools-bootstrap repository..."
    rm -rf ~/qtools-bootstrap
    remove_repo=true
    remove_auto_completion
    remove_aliases=true
    remove_service=true
    remove_cron=true
}

# Function to remove aliases
remove_aliases() {
    echo "Removing aliases..."
    sed -i '/alias manage-bootstrap/d' ~/.bashrc
    sed -i '/alias update-bootstrap/d' ~/.bashrc
    remove_aliases=true
    remove_auto_completion
}

# Function to remove service
remove_service() {
    echo "Removing systemd service..."
    sudo systemctl stop quilibrium-bootstrap
    sudo systemctl disable quilibrium-bootstrap
    sudo rm /etc/systemd/system/quilibrium-bootstrap.service
    sudo systemctl daemon-reload
}

# Function to remove cron job
remove_cron() {
    echo "Removing cron job..."
    crontab -l | grep -v "update-bootstrap" | crontab -
}

# Function to remove ceremonyclient
remove_ceremonyclient() {
    echo "Removing ceremonyclient directory..."
    rm -rf ~/ceremonyclient
}

# Main uninstall process
echo "Quilibrium Bootstrap Client Uninstaller"
echo "======================================="

read -p "Do you want to remove the qtools-bootstrap repository? (y/N): " remove_repo_choice
if [[ $remove_repo_choice =~ ^[Yy]$ ]]; then
    remove_repository
else
    read -p "Do you want to remove the manage-bootstrap and update-bootstrap aliases? (y/N): " remove_aliases_choice
    if [[ $remove_aliases_choice =~ ^[Yy]$ ]]; then
        remove_aliases
    fi

    read -p "Do you want to remove the systemd service? (y/N): " remove_service_choice
    if [[ $remove_service_choice =~ ^[Yy]$ ]]; then
        remove_service
    fi

    read -p "Do you want to remove the cron job? (y/N): " remove_cron_choice
    if [[ $remove_cron_choice =~ ^[Yy]$ ]]; then
        remove_cron
    fi

    # Only ask about auto-completion if it wasn't already removed
    if [ "$remove_aliases" = false ]; then
        read -p "Do you want to remove the auto-completion for manage-bootstrap? (y/N): " remove_completion
        if [[ $remove_completion =~ ^[Yy]$ ]]; then
            remove_auto_completion
        fi
    fi
fi

read -p "Do you want to remove the ceremonyclient directory? (y/N): " remove_ceremonyclient_choice
if [[ $remove_ceremonyclient_choice =~ ^[Yy]$ ]]; then
    remove_ceremonyclient
fi

# Perform the removals
if [ "$remove_repo" = true ]; then
    remove_repository
fi
if [ "$remove_aliases" = true ]; then
    remove_aliases
fi
if [ "$remove_service" = true ]; then
    remove_service
fi
if [ "$remove_cron" = true ]; then
    remove_cron
fi
if [ "$remove_ceremonyclient" = true ]; then
    remove_ceremonyclient
fi
