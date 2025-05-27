#!/bin/bash

# Nama asli dan nama baru
SOURCE_URL="https://raw.githubusercontent.com/gibobb/check_service/main/check_service.sh"
TEMP_FILE="check_service.sh"
FINAL_NAME="check_service"

# Download dari GitHub
echo "Downloading script from GitHub..."
curl -L -o "$TEMP_FILE" "$SOURCE_URL"

# Cek apakah file berhasil di-download
if [ ! -f "$TEMP_FILE" ]; then
    echo "Download failed. File $TEMP_FILE not found."
    exit 1
fi

# Ubah nama file
mv "$TEMP_FILE" "$FINAL_NAME"

# Ubah menjadi executable
chmod +x "$FINAL_NAME"

# Pindahkan ke /usr/bin/ (perlu sudo)
echo "Moving $FINAL_NAME to /usr/bin/..."
sudo mv "$FINAL_NAME" /usr/bin/

# Konfirmasi
echo "Done. You can now run the script by typing: check_service"
