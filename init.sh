#!/bin/bash

# Function to get the appropriate home directory and user
get_home_dir_and_user() {
    if [ "$SUDO_USER" ]; then
        echo "/home/$SUDO_USER" "$SUDO_USER"
    else
        echo "$HOME" "$USER"
    fi
}

# Get home directory and user
read HOME_DIR ACTUAL_USER <<< $(get_home_dir_and_user)

# Check if we're running from the cloned repository or via curl
if [[ ! -f "$(dirname "$0")/utils.sh" ]]; then
    echo "Downloading qtools-bootstrap repository..."
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


# Function to build the bootstrap node
build_bootstrap_node() {
    echo "Building bootstrap node..."
    cd "$(set_repo_dir)/node"
    if ! go build -o bootstrap-node; then
        echo "Failed to build bootstrap node. Please check your Go installation."
        exit 1
    fi
    sudo ln -sf "$(set_repo_dir)/node/bootstrap-node" /usr/local/bin/node
}

# Function to setup cron job
setup_cron_job() {
    if ! sudo -u "$ACTUAL_USER" crontab -l | grep -q "update-bootstrap"; then
        echo "Setting up cron job..."
        (sudo -u "$ACTUAL_USER" crontab -l 2>/dev/null; echo "*/10 * * * * /usr/local/bin/update-bootstrap") | sudo -u "$ACTUAL_USER" crontab -
        echo "Cron job added to run every 10 minutes for user $ACTUAL_USER."
    fi
}

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
    if ! sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "Starting ${SERVICE_NAME} service..."
        sudo systemctl start "$SERVICE_NAME"
    fi
}

# Function to add alias to bashrc
add_alias_to_bashrc() {
    local bashrc_file="$1"
    local qtools_dir="$(set_qtools_dir)"
    local update_alias="alias update-bootstrap='sudo bash \"$qtools_dir/update-bootstrap.sh\"'"
    local manage_alias="alias manage-bootstrap='bash \"$qtools_dir/manage-bootstrap.sh\"'"
    
    if ! grep -q "alias update-bootstrap" "$bashrc_file"; then
        echo "" >> "$bashrc_file"
        echo "# Quilibrium Bootstrap aliases" >> "$bashrc_file"
        echo "$update_alias" >> "$bashrc_file"
        echo "$manage_alias" >> "$bashrc_file"
        echo "Aliases added to $bashrc_file"
    else
        echo "Aliases already exist in $bashrc_file"
    fi
}

# Copy the auto-complete file
echo "Setting up auto-completion for manage-bootstrap..."
sudo cp "$HOME_DIR/qtools-bootstrap/manage-bootstrap-completion.sh" /etc/bash_completion.d/
sudo chmod +x /etc/bash_completion.d/manage-bootstrap-completion.sh

# Source the completion script for immediate use
source /etc/bash_completion.d/manage-bootstrap-completion.sh

echo "Auto-completion for manage-bootstrap has been set up. You may need to restart your shell or run 'source ~/.bashrc' to use it immediately."

# Main execution
echo "Initializing Quilibrium Bootstrap setup..."

# Ensure Go 1.22.4 is installed
bash "$(set_qtools_dir)/install-go.sh"

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
fi

echo "Installation completed. Please run 'source ~/.bashrc' or log out and log back in to use the 'update-bootstrap' command."