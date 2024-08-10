#!/bin/bash

# Source the utils file
if [ "$SUDO_USER" ]; then
    source "/home/$SUDO_USER/qtools-bootstrap/utils.sh"
elif [ "$HOME" = "/root" ]; then
    source "/root/qtools-bootstrap/utils.sh"
else
    source "$HOME/qtools-bootstrap/utils.sh"
fi

# Install Go 1.22.4
install_go() {
    echo "Installing Go"
    GO_COMPRESSED_FILE=go1.22.4.linux-amd64.tar.gz
    GOROOT="/usr/local/go"
    GOPATH="$HOME/go"
    BASHRC_FILE="$HOME/.bashrc"

    echo "Downloading $GO_COMPRESSED_FILE..."
    wget https://go.dev/dl/$GO_COMPRESSED_FILE 

    echo "Uncompressing $GO_COMPRESSED_FILE"
    sudo tar -C /usr/local -xzf $GO_COMPRESSED_FILE

    file_exists $GOROOT

    remove_file $GO_COMPRESSED_FILE

    append_to_file $BASHRC_FILE "export GOROOT=$GOROOT"
    append_to_file $BASHRC_FILE "export GOPATH=$GOPATH"
    append_to_file $BASHRC_FILE "export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH"

    source $BASHRC_FILE

    echo "Go 1.22.4 installed successfully"
}

# Check if Go is already installed
if command -v go &> /dev/null; then
    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    if [[ "$GO_VERSION" == "1.22.4" ]]; then
        echo "Go 1.22.4 is already installed"
        exit 0
    else
        echo "Incorrect Go version. Found $GO_VERSION, but version 1.22.4 is required."
    fi
fi

# Install Go 1.22.4
install_go