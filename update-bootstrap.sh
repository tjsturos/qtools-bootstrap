#!/bin/bash

# Source the utils file
source "$(dirname "$0")/utils.sh"

# Check if script is run with sudo privileges
check_sudo

# Set the directory for the repository
REPO_DIR=$(set_repo_dir)

# Function to update the repository
update_repository() {
    echo "Updating repository..."
    cd "$REPO_DIR"
    git fetch origin
    local changes=$(git rev-list HEAD...origin/v2.0-bootstrap --count)
    if [ "$changes" -eq "0" ] && [ "$1" != "--force" ]; then
        echo "No updates available."
        return 1
    fi
    git pull origin v2.0-bootstrap
    return 0
}

# Function to rebuild the bootstrap node
rebuild_bootstrap_node() {
    echo "Rebuilding bootstrap node..."
    cd "$REPO_DIR/node"
    go build -o bootstrap-node
    sudo ln -sf "$REPO_DIR/node/bootstrap-node" /usr/local/bin/node
}

# Function to update bootstrap
update_bootstrap() {
    echo "Updating bootstrap..."
    sudo systemctl stop "$SERVICE_NAME"
    if update_repository "$1"; then
        rebuild_bootstrap_node
        sudo systemctl start "$SERVICE_NAME"
        echo "Update completed."
    else
        sudo systemctl start "$SERVICE_NAME"
        echo "No update performed."
    fi
}

# Function to run init script
run_init_script() {
    echo "Initial setup not completed. Attempting to run init script..."
    INIT_SCRIPT="$REPO_DIR/init.sh"
    if [[ -f "$INIT_SCRIPT" ]]; then
        sudo bash "$INIT_SCRIPT"
        if [[ $? -eq 0 ]]; then
            echo "Init script completed successfully."
            return 0
        else
            echo "Init script failed."
            return 1
        fi
    else
        echo "Init script not found at $INIT_SCRIPT"
        return 1
    fi
}

# Main execution
if [[ ! -f "/etc/systemd/system/${SERVICE_NAME}.service" ]] || [[ ! -L "/usr/local/bin/node" ]]; then
    if run_init_script; then
        echo "Initial setup completed. Proceeding with update..."
        update_bootstrap "$1"
    else
        echo "Failed to complete initial setup. Please run the init script manually."
        exit 1
    fi
else
    echo "Checking for updates..."
    update_bootstrap "$1"
fi

echo "Update script execution completed."