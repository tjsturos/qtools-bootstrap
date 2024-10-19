#!/bin/bash

# Source the utils file
source "$(dirname "$0")/utils.sh"

# Trap Ctrl+C and handle it gracefully
trap ctrl_c INT

function ctrl_c() {
    echo -e "\n\nUninstallation cancelled. Exiting..."
    exit 1
}

# Initialize variables
remove_repo=false
remove_aliases=false
remove_service=false
remove_cron=false
remove_auto_completion=false
remove_binary=false

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
    rm -rf "$(set_qtools_dir)"
}

# Function to remove aliases
remove_aliases() {
    echo "Removing aliases..."
    sed -i '/alias manage-bootstrap/d' ~/.bashrc
    sed -i '/alias update-bootstrap/d' ~/.bashrc
}

# Function to remove service
remove_service() {
    echo "Removing systemd service..."
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm "/etc/systemd/system/${SERVICE_NAME}.service"
    sudo systemctl daemon-reload
}

# Function to remove cron job
remove_cron() {
    echo "Removing cron job..."
    crontab -l | grep -v "update-bootstrap" | crontab -
}

# Function to remove binary
remove_binary() {
    echo "Removing bootstrap client binary..."
    local node_dir="$(set_repo_dir)/node"
    local binary_path="$node_dir/bootstrap-node"
    if [ -f "$binary_path" ]; then
        rm -f "$binary_path"
        echo "Bootstrap binary removed."
    else
        echo "Bootstrap binary not found in expected location: $binary_path"
    fi
}

# Main uninstall process
echo "Quilibrium Bootstrap Client Uninstaller"
echo "======================================="

read -p "Do you want to remove the qtools-bootstrap repository? (y/N): " remove_repo_choice
if [[ $remove_repo_choice =~ ^[Yy]$ ]]; then
    remove_repo=true
    remove_aliases=true
    remove_cron=true
    remove_auto_completion=true
else
    read -p "Do you want to remove the manage-bootstrap and update-bootstrap aliases? (y/N): " remove_aliases_choice
    if [[ $remove_aliases_choice =~ ^[Yy]$ ]]; then
        remove_aliases=true
        remove_auto_completion=true
    fi

    read -p "Do you want to remove the cron job? (y/N): " remove_cron_choice
    if [[ $remove_cron_choice =~ ^[Yy]$ ]]; then
        remove_cron=true
    fi

    # Only ask about auto-completion if it wasn't already set to be removed
    if [ "$remove_aliases" = false ]; then
        read -p "Do you want to remove the auto-completion for manage-bootstrap? (y/N): " remove_completion_choice
        if [[ $remove_completion_choice =~ ^[Yy]$ ]]; then
            remove_auto_completion=true
        fi
    fi
fi

read -p "Do you want to remove the bootstrap client binary and service? (y/N): " remove_binary_choice
if [[ $remove_binary_choice =~ ^[Yy]$ ]]; then
    remove_binary=true
    remove_service=true
fi

# Summarize choices and ask for confirmation
echo -e "\nYou have chosen to remove the following components:"
if [ "$remove_repo" = true ]; then
    echo "- qtools-bootstrap repository (includes aliases, cron job, and auto-completion)"
else
    if [ "$remove_aliases" = true ]; then
        echo "- Aliases (manage-bootstrap and update-bootstrap)"
    fi
    if [ "$remove_cron" = true ]; then
        echo "- Cron job"
    fi
    if [ "$remove_auto_completion" = true ]; then
        echo "- Auto-completion for manage-bootstrap"
    fi
fi
if [ "$remove_binary" = true ]; then
    echo "- Bootstrap client binary"
    echo "- Systemd service ($SERVICE_NAME)"
fi

echo -e "\nConsequences:"
if [ "$remove_repo" = true ]; then
    echo "- You will lose all local modifications to the qtools-bootstrap scripts."
    echo "- The manage-bootstrap and update-bootstrap commands will no longer be available."
fi
if [ "$remove_aliases" = true ]; then
    echo "- The manage-bootstrap and update-bootstrap commands will no longer be available."
fi
if [ "$remove_cron" = true ]; then
    echo "- Automatic updates for the bootstrap client will no longer occur."
fi
if [ "$remove_auto_completion" = true ]; then
    echo "- Tab completion for manage-bootstrap will no longer work."
fi
if [ "$remove_binary" = true ]; then
    echo "- The bootstrap client binary will be removed."
    echo "- The systemd service will be stopped and removed."
    echo "- The ceremonyclient directory will remain, but you'll need to manually remove it if desired."
fi

read -p $'\nAre you sure you want to proceed with the uninstallation? (y/N/q): ' confirm
if [[ $confirm =~ ^[Qq]$ ]]; then
    echo "Uninstallation cancelled. Exiting..."
    exit 1
elif [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled. Exiting..."
    exit 1
fi

# Perform the removals
if [ "$remove_repo" = true ]; then
    remove_repository
fi
if [ "$remove_aliases" = true ]; then
    remove_aliases
fi
if [ "$remove_cron" = true ]; then
    remove_cron
fi
if [ "$remove_auto_completion" = true ]; then
    remove_auto_completion
fi
if [ "$remove_binary" = true ]; then
    remove_binary
fi
if [ "$remove_service" = true ]; then
    remove_service
fi

echo "Uninstallation process completed."
echo "Note: The ceremonyclient directory ($(set_repo_dir)) has been left intact."
echo "If you wish to remove it entirely, you'll need to do so manually."
exit 0