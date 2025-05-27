#!/bin/bash

set -e

SOURCE_URL="https://raw.githubusercontent.com/gibobb/check_service/main/check_service"
FINAL_NAME="check_service"
INSTALL_PATH="/usr/bin/check_service"
LINK_PATH="/usr/local/bin/check_service"

echo "Downloading script from GitHub..."
curl -Lo "/tmp/$FINAL_NAME" "$SOURCE_URL"

if [ ! -f "/tmp/$FINAL_NAME" ]; then
    echo "Download failed. File not found."
    exit 1
fi

echo "Installing..."
sudo install -m 755 "/tmp/$FINAL_NAME" "$INSTALL_PATH"
sudo ln -sf "$INSTALL_PATH" "$LINK_PATH"

rm -f "/tmp/$FINAL_NAME"

echo "Done. You can now run: check_service"
