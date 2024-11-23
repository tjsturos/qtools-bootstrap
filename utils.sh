#!/bin/bash

QTOOLS_BOOTSTRAP_REPO_URL="https://github.com/tjsturos/qtools-bootstrap.git"
QUIL_REPO_URL="https://github.com/QuilibriumNetwork/ceremonyclient.git"
REPO_RAW_URL="https://raw.githubusercontent.com/tjsturos/qtools-bootstrap/main"
SERVICE_NAME="bootstrapclient"

# Function to get the appropriate home directory
get_home_dir() {
    if [ "$SUDO_USER" ]; then
        echo "/home/$SUDO_USER"
    else
        echo "$HOME"
    fi
}

# Function to set the repository directory
set_repo_dir() {
    echo "$(get_home_dir)/ceremonyclient"
}

# Function to set the qtools-bootstrap directory
set_qtools_dir() {
    echo "$(get_home_dir)/qtools-bootstrap"
}


# Function to check if a file exists
file_exists() {
    if [ -d "$1" ]; then
        echo "Directory $1 exists."
    else
        echo "Error: Directory $1 does not exist."
        exit 1
    fi
}

# Function to remove a file
remove_file() {
    if [ -f "$1" ]; then
        rm "$1"
        echo "Removed file: $1"
    else
        echo "File not found: $1"
    fi
}

# Function to append to a file if the line doesn't exist
append_to_file() {
    if ! grep -qF "$2" "$1"; then
        echo "$2" >> "$1"
        echo "Appended to $1: $2"
    else
        echo "Line already exists in $1: $2"
    fi
}

# Function to get the appropriate user
get_user() {
    if [ "$SUDO_USER" ]; then
        echo "$SUDO_USER"
    else
        echo "$USER"
    fi
}