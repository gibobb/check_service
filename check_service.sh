#!/bin/bash

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "=== CHECKING AUTOLOGIN GDM3 ==="
CONFIG_FILE="/etc/gdm3/custom.conf"

if grep -q "^AutomaticLoginEnable=true" "$CONFIG_FILE"; then
    echo -e "Autologin: ${GREEN}ENABLED${NC}"
    USERNAME=$(grep "^AutomaticLogin=" "$CONFIG_FILE" | cut -d'=' -f2)
    echo "Autologin User: ${USERNAME:-Not found}"
else
    echo -e "Autologin: ${RED}DISABLED${NC}"
fi

echo
echo -e "=== CHECKING DISPLAY SERVER ==="

DISPLAY_SERVER=$(ps -e -o comm= | grep -Ei 'Xorg|wayland|weston' | head -n 1)

if [[ -n "$DISPLAY_SERVER" ]]; then
    echo -e "Display Server: ${GREEN}${DISPLAY_SERVER}${NC}"
else
    echo -e "Display Server: ${RED}Not Detected (Xorg, Wayland, or Weston not running)${NC}"
fi

echo
echo -e "=== CHECKING ACTIVE USER ==="
USER_DISPLAY=$(who | grep -Ei 'tty|:0|:1' | awk '{print $1}' | sort | uniq | head -n 1)

if [[ -n "$USER_DISPLAY" ]]; then
    echo -e "Active User: ${GREEN}${USER_DISPLAY}${NC}"
else
    echo -e "Active User: ${RED}Not Detected${NC}"
fi

echo
echo -e "=== CHECKING PRINTERS ==="

PRINTER_LIST=$(lpstat -p 2>/dev/null | grep -E 'KPOS')

if [[ -n "$PRINTER_LIST" ]]; then
    echo -e "Active Printers:"
    echo "$PRINTER_LIST" | awk '{print "- " $2 " (" $3 ")"}'
else
    echo -e "${RED}No printers detected.${NC}"
fi

DEFAULT_OUTPUT=$(lpstat -d 2>/dev/null)

if echo "$DEFAULT_OUTPUT" | grep -qi 'default destination'; then
    DEFAULT_PRINTER=$(echo "$DEFAULT_OUTPUT" | awk -F': ' '{print $2}')
    echo -e "Default Printer: ${GREEN}${DEFAULT_PRINTER}${NC}"
else
    echo -e "Default Printer: ${RED}Not Set${NC}"
fi

echo
echo -e "=== CHECKING STAMPS SERVICES ==="

check_service2() {
    SERVICE_NAME="$1"
    echo "Service: $SERVICE_NAME"

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "  Status: ${GREEN}ACTIVE (running)${NC}"
    else
        echo -e "  Status: ${RED}INACTIVE (not running)${NC}"
    fi

    if systemctl is-enabled --quiet "$SERVICE_NAME"; then
        echo -e "  Startup: ${GREEN}ENABLED (starts at boot)${NC}"
    else
        echo -e "  Startup: ${YELLOW}DISABLED (does not start at boot)${NC}"
    fi
    echo
}

check_service2 "kiosk"
check_service2 "kiosk_mode"

echo -e "=== CHECKING CONNECTION OMNI (PING richeese.omni.fm) ==="
PING_RESULT=$(ping -c 1 -W 2 richeese.omni.fm 2>/dev/null)

if [[ $? -eq 0 ]]; then
    LATENCY=$(echo "$PING_RESULT" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    echo -e "Connection Omni: ${GREEN}CONNECTED${NC} (Latency: ${LATENCY} ms)"
else
    echo -e "Connection Omni: ${RED}NOT CONNECTED${NC} (Ping failed)"
fi
echo

echo
echo -e "=== CHECKING SYSTEM SERVICES ==="

check_service() {
    SERVICE_NAME="$1"
    echo "Service: $SERVICE_NAME"

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "  Status: ${GREEN}ACTIVE (running)${NC}"
    else
        echo -e "  Status: ${RED}INACTIVE (not running)${NC}"
    fi

    if systemctl is-enabled --quiet "$SERVICE_NAME"; then
        echo -e "  Startup: ${GREEN}ENABLED (starts at boot)${NC}"
    else
        echo -e "  Startup: ${YELLOW}DISABLED (does not start at boot)${NC}"
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

echo -e "=== CHECKING IP ADDRESS & INTERFACES ==="
ip -o -4 addr show | awk '!/ lo / {print "Interface:", $2, "| IP Address:", $4}'
echo

echo -e "=== CHECKING INTERNET CONNECTION (PING google.com) ==="
PING_RESULT=$(ping -c 1 -W 2 google.com 2>/dev/null)

if [[ $? -eq 0 ]]; then
    LATENCY=$(echo "$PING_RESULT" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    echo -e "Internet: ${GREEN}CONNECTED${NC} (Latency: ${LATENCY} ms)"
else
    echo -e "Internet: ${RED}NOT CONNECTED${NC} (Ping failed)"
fi
echo

echo -e "=== CHECKING EDC DEVICE (INGENICO) ==="
EDC_DEVICES=$(lsusb | grep -i 'INGENICO' | awk '{for(i=7;i<=NF;++i) printf $i" "; print ""}')

if [[ -n "$EDC_DEVICES" ]]; then
    echo -e "EDC Devices Detected: ${GREEN}"
    echo "$EDC_DEVICES"
    echo -e "${NC}"
else
    echo -e "EDC Devices: ${RED}Not Detected${NC}"
fi
echo
