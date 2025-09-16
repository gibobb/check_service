#!/bin/bash

# Buat direktori sementara
TMP_DIR=$(mktemp -d)

# Unduh install.sh ke direktori sementara
curl -sL -o "$TMP_DIR/install.sh" https://raw.githubusercontent.com/gibobb/check_service/main/install.sh

# Jadikan executable
chmod +x "$TMP_DIR/install.sh"

# Jalankan install.sh
"$TMP_DIR/install.sh"

# Hapus file dan direktori sementara
rm -rf "$TMP_DIR"
