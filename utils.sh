#!/bin/bash

REPO_URL="https://github.com/tjsturos/qtools-bootstrap"
REPO_RAW_URL="https://raw.githubusercontent.com/tjsturos/qtools-bootstrap/main"
SERVICE_NAME="bootstrapclient"

# Function to set the repository directory
set_repo_dir() {
    echo "$HOME/ceremonyclient"
}

# Function to set the qtools-bootstrap directory
set_qtools_dir() {
    echo "$HOME/qtools-bootstrap"
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
    local bashrc_file="$HOME/.bashrc"
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