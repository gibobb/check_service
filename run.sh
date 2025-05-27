#!/bin/bash

# Nama asli dan nama baru
SOURCE_URL="https://raw.githubusercontent.com/gibobb/check_service/main/check_service"
FINAL_NAME="check_service"
PATH_BIN="/usr/bin/check_service"
PATH_BIN2="/usr/local/bin/check_service"

# Download dari GitHub
echo "Downloading script from GitHub..."
curl -L -o "$TEMP_FILE" "$SOURCE_URL"

# Cek apakah file berhasil di-download
if [ ! -f "$TEMP_FILE" ]; then
    echo "Download failed. File $TEMP_FILE not found."
    exit 1
fi

# Ubah nama file
sudo install -m 755 "$TEMP_FILE" /usr/bin/check_service
sudo ln -sf "$PATH_BIN" "$PATH_BIN2"

# Konfirmasi
echo "Done. You can now run the script by typing: check_service"
