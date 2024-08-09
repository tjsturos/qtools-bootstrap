#!/bin/bash

# Source the utils file
source "$(dirname "$0")/utils.sh"

echo "This script will uninstall the Quilibrium Bootstrap Client and remove associated files, except for the ceremonyclient directory."
read -p "Are you sure you want to proceed? (y/N): " confirm

if [[ $confirm != [yY] ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Stop and remove the service
echo "Stopping and removing the ${SERVICE_NAME} service..."
sudo systemctl stop "${SERVICE_NAME}"
sudo systemctl disable "${SERVICE_NAME}"
sudo rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
sudo systemctl daemon-reload

# Remove the binary
echo "Removing the bootstrap node binary..."
sudo rm -f "/usr/local/bin/node"

# Remove the qtools-bootstrap repository
echo "Removing the qtools-bootstrap repository..."
rm -rf "$(set_qtools_dir)"

# Remove the cron job
echo "Removing the cron job..."
(crontab -l | grep -v "update-bootstrap") | crontab -

# Remove the update-bootstrap script
echo "Removing the update-bootstrap script..."
sudo rm -f "/usr/local/bin/update-bootstrap"

# Remove the alias from .bashrc
HOME_DIR=$(get_home_dir)
sed -i '/alias update-bootstrap/d' "$HOME_DIR/.bashrc"
sed -i '/# Quilibrium Bootstrap update alias/d' "$HOME_DIR/.bashrc"

echo "Uninstallation completed. The ceremonyclient directory has been left intact."
echo "You may need to log out and log back in for all changes to take effect."