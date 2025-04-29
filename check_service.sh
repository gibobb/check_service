#!/bin/bash

# === Warna ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "=== CEK AUTOLOGIN GDM3 ==="
CONFIG_FILE="/etc/gdm3/custom.conf"

if grep -q "^AutomaticLoginEnable=true" "$CONFIG_FILE"; then
    echo -e "Autologin: ${GREEN}AKTIF${NC}"
    USERNAME=$(grep "^AutomaticLogin=" "$CONFIG_FILE" | cut -d'=' -f2)
    echo "User Autologin: ${USERNAME:-Tidak ditemukan}"
else
    echo -e "Autologin: ${RED}TIDAK AKTIF${NC}"
fi

echo
echo -e "=== CEK DISPLAY KIOSK ==="

DISPLAY_SERVER=$(ps -e -o comm= | grep -Ei 'Xorg|wayland|weston' | head -n 1)

if [[ -n "$DISPLAY_SERVER" ]]; then
    echo -e "Display Server: ${GREEN}${DISPLAY_SERVER}${NC}"
else
    echo -e "Display Server: ${RED}Tidak Terdeteksi (Xorg, Wayland, atau Weston tidak berjalan)${NC}"
fi
echo
echo -e "=== CEK User KIOSK ==="
USER_DISPLAY=$(who | grep -Ei 'tty|:0|:1' | awk '{print $1}' | sort | uniq | head -n 1)

if [[ -n "$USER_DISPLAY" ]]; then
    echo -e "User Aktif: ${GREEN}${USER_DISPLAY}${NC}"
else
    echo -e "User Aktif: ${RED}Tidak Terdeteksi${NC}"
fi

echo -e "\n=== CEK PRINTER ==="

PRINTER_LIST=$(lpstat -p 2>/dev/null|grep -E 'KPOS')

if [[ -n "$PRINTER_LIST" ]]; then
    echo -e "Daftar Printer Aktif:"
    echo "$PRINTER_LIST" | awk '{print "- " $2 " (" $3 ")"}'
else
    echo -e "${RED}Tidak ada printer terdeteksi.${NC}"
fi

DEFAULT_OUTPUT=$(lpstat -d 2>/dev/null)

if echo "$DEFAULT_OUTPUT" | grep -qi 'default destination'; then
    DEFAULT_PRINTER=$(echo "$DEFAULT_OUTPUT" | awk -F': ' '{print $2}')
    echo -e "Default Printer: ${GREEN}${DEFAULT_PRINTER}${NC}"
else
    echo -e "Default Printer: ${RED}Tidak Diset${NC}"
fi

echo
echo -e "=== CEK STATUS SERVICE STAMPS==="

check_service2() {
    SERVICE_NAME="$1"
    echo "Service: $SERVICE_NAME"

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "  Status: ${GREEN}AKTIF (running)${NC}"
    else
        echo -e "  Status: ${RED}TIDAK AKTIF (not running)${NC}"
    fi

    if systemctl is-enabled --quiet "$SERVICE_NAME"; then
        echo -e "  Startup: ${GREEN}ENABLED (jalan saat boot)${NC}"
    else
        echo -e "  Startup: ${YELLOW}DISABLED (tidak jalan saat boot)${NC}"
    fi
    echo
}

check_service2 "kiosk"
check_service2 "kiosk_mode"

echo
echo -e "=== CEK STATUS SERVICE ==="

check_service() {
    SERVICE_NAME="$1"
    echo "Service: $SERVICE_NAME"

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "  Status: ${GREEN}AKTIF (running)${NC}"
    else
        echo -e "  Status: ${RED}TIDAK AKTIF (not running)${NC}"
    fi

    if systemctl is-enabled --quiet "$SERVICE_NAME"; then
        echo -e "  Startup: ${GREEN}ENABLED (jalan saat boot)${NC}"
    else
        echo -e "  Startup: ${YELLOW}DISABLED (tidak jalan saat boot)${NC}"
    fi
    echo
}

check_service "ssh"
check_service "anydesk"
check_service "apparmor"
check_service "unattended-upgrades"
check_service "apt-daily.service"
check_service "apt-daily.timer"
check_service "apt-daily-upgrade.service"
check_service "apt-daily-upgrade.timer"

echo -e "=== CEK IP ADDRESS & INTERFACE ==="
ip -o -4 addr show | awk '!/ lo / {print "Interface:", $2, "| IP Address:", $4}'
echo

echo -e "=== CEK KONEKSI INTERNET (PING google.com) ==="
PING_RESULT=$(ping -c 1 -W 2 google.com 2>/dev/null)

if [[ $? -eq 0 ]]; then
    LATENCY=$(echo "$PING_RESULT" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    echo -e "Internet: ${GREEN}TERHUBUNG${NC} (Latency: ${LATENCY} ms)"
else
    echo -e "Internet: ${RED}TIDAK TERHUBUNG${NC} (Ping gagal)"
fi
echo
	
