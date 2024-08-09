#!/bin/bash

REPO_URL="https://github.com/tjsturos/qtools-bootstrap"
REPO_RAW_URL="https://raw.githubusercontent.com/tjsturos/qtools-bootstrap/main"
SERVICE_NAME="bootstrapclient"

# Function to get the appropriate home directory
get_home_dir() {
    if [[ "$SUDO_USER" ]]; then
        getent passwd "$SUDO_USER" | cut -d: -f6
    else
        echo "$HOME"
    fi
}

# Function to get the appropriate user
get_user() {
    if [[ "$SUDO_USER" ]]; then
        echo "$SUDO_USER"
    else
        echo "$USER"
    fi
}

# Function to set the repository directory
set_repo_dir() {
    local home_dir=$(get_home_dir)
    echo "$home_dir/ceremonyclient"
}

# Function to check if script is run with sudo privileges
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo privileges"
        exit 1
    fi
}

# Function to add alias to bashrc
add_alias_to_bashrc() {
    local bashrc_file="$1"
    local alias_line="alias update-bootstrap='bash <(curl -sSf \"$REPO_RAW_URL/update-bootstrap.sh\") || echo \"Error: Failed to download or execute the update script\"'"
    
    if ! grep -q "alias update-bootstrap" "$bashrc_file"; then
        echo "" >> "$bashrc_file"
        echo "# Quilibrium Bootstrap update alias" >> "$bashrc_file"
        echo "$alias_line" >> "$bashrc_file"
        echo "Alias added to $bashrc_file"
    else
        echo "Alias already exists in $bashrc_file"
    fi
}