#!/bin/bash

# Function to get the appropriate home directory
get_home_dir() {
    if [ "$SUDO_USER" ]; then
        echo "/home/$SUDO_USER"
    else
        echo "$HOME"
    fi
}

# Check if we're running from the cloned repository or via curl
if [[ ! -f "$(dirname "$0")/utils.sh" ]]; then
    echo "Downloading qtools-bootstrap repository..."
    HOME_DIR=$(get_home_dir)
    qtools_dir="$HOME_DIR/qtools-bootstrap"
    
    # Remove existing directory if it exists
    if [ -d "$qtools_dir" ]; then
        echo "Removing existing qtools-bootstrap directory..."
        rm -rf "$qtools_dir"
    fi
    
    mkdir -p "$qtools_dir"
    if ! git clone https://github.com/tjsturos/qtools-bootstrap.git "$qtools_dir"; then
        echo "Failed to clone qtools-bootstrap repository"
        exit 1
    fi
    cd "$qtools_dir"
else
    echo "Using existing qtools-bootstrap repository..."
    cd "$(dirname "$0")"
fi

# Source utils.sh
if [ -f "utils.sh" ]; then
    source utils.sh
else
    echo "utils.sh not found. Installation may be incomplete."
    exit 1
fi

# Check if script is run with sudo privileges
check_sudo

# Function to setup the repository
setup_repository() {
    local repo_dir=$(set_repo_dir)
    if [[ ! -d "$repo_dir" ]]; then
        echo "Cloning ceremonyclient repository..."
        if ! git clone "$REPO_URL" "$repo_dir"; then
            echo "Failed to clone ceremonyclient repository"
            exit 1
        fi
    fi
    cd "$repo_dir"
    echo "Updating repository..."
    git fetch origin
    git checkout v2.0-bootstrap
    git pull origin v2.0-bootstrap
}

# Function to build the bootstrap node
build_bootstrap_node() {
    echo "Building bootstrap node..."
    cd "$(set_repo_dir)/node"
    go build -o bootstrap-node
    sudo ln -sf "$(set_repo_dir)/node/bootstrap-node" /usr/local/bin/node
}

# Function to create and start the service
setup_service() {
    if [[ ! -f "/etc/systemd/system/${SERVICE_NAME}.service" ]]; then
        echo "Creating ${SERVICE_NAME} service..."
        echo "[Unit]
Description=Quilibrium Mainnet Bootstrap Client Service
[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=$(set_repo_dir)/node
ExecStart=/usr/local/bin/node
[Install]
WantedBy=multi-user.target" | sudo tee "/etc/systemd/system/${SERVICE_NAME}.service" > /dev/null
        sudo systemctl daemon-reload
        sudo systemctl enable "${SERVICE_NAME}.service"
    fi
    if ! systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "Starting ${SERVICE_NAME} service..."
        sudo systemctl start "$SERVICE_NAME"
    fi
}

# Function to setup cron job
setup_cron_job() {
    if ! crontab -l | grep -q "update-bootstrap"; then
        echo "Setting up cron job..."
        (crontab -l 2>/dev/null; echo "*/10 * * * * /usr/local/bin/update-bootstrap") | crontab -
        echo "Cron job added to run every 10 minutes."
    fi
}

# Main execution
echo "Initializing Quilibrium Bootstrap setup..."

# Setup the repository
setup_repository

# Build bootstrap node
build_bootstrap_node

# Setup the service
setup_service

# Setup cron job
setup_cron_job

# Add alias to appropriate bashrc file
add_alias_to_bashrc "$HOME_DIR/.bashrc"

# Setup the update-bootstrap script
SCRIPT_PATH="/usr/local/bin/update-bootstrap"
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Setting up update-bootstrap script..."
    sudo ln -sf "$(set_repo_dir)/update-bootstrap.sh" "$SCRIPT_PATH"
    sudo chmod +x "$SCRIPT_PATH"
fi

echo "Installation completed. Please run 'source ~/.bashrc' or log out and log back in to use the 'update-bootstrap' command."