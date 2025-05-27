#!/bin/bash

set -e

SOURCE_URL="https://raw.githubusercontent.com/gibobb/check_service/main/check_service"
FINAL_NAME="check_service"
INSTALL_PATH="/usr/bin/$FINAL_NAME"
LINK_PATH="/usr/local/bin/$FINAL_NAME"

echo "Mengunduh dan memasang $FINAL_NAME..."

# Download silently
curl -sSL -o "/tmp/$FINAL_NAME" "$SOURCE_URL"

# Pastikan file berhasil diunduh
if [ ! -f "/tmp/$FINAL_NAME" ]; then
    echo "Gagal mengunduh $FINAL_NAME."
    exit 1
fi

# Install silently
sudo install -m 755 "/tmp/$FINAL_NAME" "$INSTALL_PATH"
sudo ln -sf "$INSTALL_PATH" "$LINK_PATH"

# Bersihkan
rm -f "/tmp/$FINAL_NAME"

echo "Instalasi selesai. Jalankan: $FINAL_NAME"
