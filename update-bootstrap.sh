#!/bin/bash

# Source the utils file
if [ "$SUDO_USER" ]; then
    source "/home/$SUDO_USER/qtools-bootstrap/utils.sh"
elif [ "$HOME" = "/root" ]; then
    source "/root/qtools-bootstrap/utils.sh"
else
    source "$HOME/qtools-bootstrap/utils.sh"
fi


# Set the directory for the repository
REPO_DIR=$(set_repo_dir)

# Initialize force flag
FORCE=0

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--force) FORCE=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Function to update the repository
update_repository() {
    cd "$REPO_DIR"
    echo "Fetching updates to the repository..."
    git fetch origin
    local changes=$(git rev-list HEAD...origin/v2.0-bootstrap --count)
    if [ "$changes" -eq "0" ] && [ $FORCE -eq 0 ]; then
        echo "No updates to the repository available."
        return 1
    fi
    git pull origin v2.0-bootstrap
    return 0
}

# Function to rebuild the bootstrap node
rebuild_bootstrap_node() {
    echo "Rebuilding bootstrap node..."
    cd "$REPO_DIR/node"
    # Get current time before build
    local pre_build_time=$(date +%s)

    # Perform the build
    if ! go build -o bootstrap-node; then
        echo "Failed to build bootstrap node. Please check your Go installation."
        exit 1
    fi

    # Check if the bootstrap-node file is newer than pre-build time
    if [ -f "bootstrap-node" ]; then
        local file_mtime=$(stat -c %Y bootstrap-node)
        if [ $file_mtime -gt $pre_build_time ]; then
            echo "Bootstrap node successfully built and is newer than pre-build time."
        else
            echo "Warning: Bootstrap node file is not newer than pre-build time. Build may have failed silently."
        fi
    else
        echo "Error: bootstrap-node file not found after build attempt."
        exit 1
    fi

    local link_path="/usr/local/bin/node"
    # Check if the link exists and points to the bootstrap-node file
    if [ -L "$link_path" ]; then
        local target=$(readlink -f "$link_path")
        if [ "$target" == "$REPO_DIR/node/bootstrap-node" ]; then
            echo "Symlink $link_path correctly points to bootstrap-node."
        else
            echo "Warning: Symlink $link_path exists but points to $target instead of $REPO_DIR/node/bootstrap-node."
            echo "Updating symlink..."
            sudo ln -sf "$REPO_DIR/node/bootstrap-node" "$link_path"
        fi
    else
        echo "Symlink $link_path does not exist. Creating it..."
        sudo ln -sf "$REPO_DIR/node/bootstrap-node" "$link_path"
    fi
}

# Function to update bootstrap
update_bootstrap() {
    echo "Updating bootstrap..."
    if update_repository; then
    sudo systemctl stop "$SERVICE_NAME"
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
        update_bootstrap
    else
        echo "Failed to complete initial setup. Please run the init script manually."
        exit 1
    fi
else
    echo "Checking for updates..."
    update_bootstrap
fi

echo "Update script execution completed."