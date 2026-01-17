#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

clear_screen() {
    clear
}

banner() {
    clear_screen
    echo -e "${CYAN}"
    echo "            ######   #########       ############           ########   #############"
    echo "          ###        ###      ###    ###                  ###               ###         "
    echo "         ###         ###       ###   ###                ###                 ###"
    echo "         ###         ###       ###   ###               ###                  ###"
    echo "          ###        ###       ###   ###              ###                   ###"
    echo "           ###       ###      ###    ############    ###                    ###"
    echo "             ###     ###########     ###              ###                   ###"
    echo "              ###    ###             ###               ###                  ###"
    echo "     ###      ###    ###             ###                ###                 ###  "
    echo "      ###   ####     ###             ###                 ###                ###"
    echo "        #####        ###             ############           ########        ###${NC}"
    echo -e "${YELLOW}============================="
    echo "        MAIN MENU   "
    echo "=============================${NC}"
    echo ""
}

menu() {
    while true; do
        banner
        echo -e "${GREEN}   [1] Start Netstating         [11]${NC}"
        echo -e "   [2] WifiCracker              [12]${NC}"
        echo -e "   [3] PyBrute                  [13]${NC}"
        echo -e "   [4] Zphisher                 [14]${NC}"
        echo -e "   [5] IPCracker                [15]${NC}"
        echo -e "   [6] KaliLinux                [16]${NC}"
        echo -e "   [7] DarkWeb                  [17]${NC}"
        echo -e "   [8]                          [18]${NC}"
        echo -e "   [9]                          [19]${NC}"
        echo -e "   [10]                         [20] Exit${NC}"
        echo ""
        
        read -p "Select an option: " choice
        
        case $choice in
            1) netstat ;;
            2) wifipswrd ;;
            3) pybrute ;;
            4) zphisher ;;
            5) ipcracker ;;
            6) kali_linux ;;
            7) darkweb ;;
            20) echo "Goodbye!"; exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 2 ;;
        esac
    done
}

netstat() {
    clear_screen
    echo -e "${GREEN}Starting...${NC}"
    netstat -tuln
    sleep 5
}

wifipswrd() {
    clear_screen
    echo -e "${BLUE}WiFi Profiles${NC}"
    echo ""
    termux-wifi-scaninfo | grep -E "(SSID|signal)" || echo "Install termux-api: pkg install termux-api"
    read -p "Press enter to continue..."
}

pybrute() {
    clear_screen
    echo -e "${PURPLE}========================================"
    echo "    Mobile PIN Brute Force Tool v2.0"
    echo "========================================"
    echo ""
    echo "[1] 4-digit (0000-9999)     ~10k attempts"
    echo "[2] 6-digit (000000-999999) ~1M attempts"
    echo ""
    read -p "Enter choice (1 or 2): " choice
    
    if [ "$choice" = "1" ]; then
        min=0; max=9999; padlen=4
        echo "[+] Starting 4-digit PIN brute force (10,000 attempts)..."
    elif [ "$choice" = "2" ]; then
        min=0; max=999999; padlen=6
        echo "[+] Starting 6-digit PIN brute force (1,000,000 attempts)..."
    else
        echo -e "${RED}[!] Invalid choice!${NC}"
        sleep 2; return
    fi
    
    echo ""
    echo -e "${YELLOW}Enter your ADB command (use \$PIN as placeholder):${NC}"
    echo "Example: adb shell input text \$PIN && adb shell input keyevent 66"
    read -p "Command: " target_cmd
    
    if [ -z "$target_cmd" ]; then
        echo -e "${RED}[!] Command cannot be empty!${NC}"
        sleep 2; return
    fi
    
    echo ""
    echo "========================================"
    echo "Starting brute force attack... (Ctrl+C to stop)"
    echo "Target Command: $target_cmd"
    echo "PIN Length: $padlen digits ($min - $max)"
    echo "========================================"
    echo ""
    
    attempts=0
    for ((i=min; i<=max; i++)); do
        pin=$(printf "%0${padlen}d" $i)
        current_cmd="${target_cmd//\$PIN/$pin}"
        echo "[$(date +%H:%M:%S)] [$((++attempts))] Trying: $pin"
        eval "$current_cmd"
        sleep 0.1
    done
    
    echo ""
    echo "========================================"
    echo "Brute force completed!"
    echo "Total attempts: $attempts"
    echo "========================================"
    read -p "Press enter to continue..."
}

zphisher() {
    echo -e "${GREEN}[+] Installing Zphisher...${NC}"
    pkg install git php -y
    git clone https://github.com/htr-tech/zphisher.git
    cd zphisher
    bash zphisher.sh
    cd ..
}

ipcracker() {
    clear_screen
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "                              IP TRACKER"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    read -p "Enter IP address: " IP
    echo ""
    echo "🔍 Querying ipinfo.io/$IP..."
    curl -s "https://ipinfo.io/$IP/json" | grep -E "ip|city|region|country|loc|org|hostname"
    echo ""
    echo "📍 Full details: https://ipinfo.io/$IP"
    read -p "Press enter to continue..."
}

kali_linux() {
    clear_screen
    echo -e "${GREEN}[+] Kali Terminal Active! Type 'back' for menu${NC}"
    echo "[+] Commands: nmap ls ll ps kill pwd cd clear wget curl"
    echo ""
    
    while true; do
        echo -n "kali@kali:~$ "
        read cmd
        if [ "$cmd" = "back" ]; then
            return
        elif [ "$cmd" = "clear" ]; then
            clear_screen
        elif [ "$cmd" = "ls" ]; then
            ls -la
        elif [ "$cmd" = "pwd" ]; then
            pwd
        elif [ "$cmd" = "ps" ]; then
            ps aux
        else
            eval "$cmd"
        fi
    done
}

darkweb() {
    mkdir -p darknet_global
    CHAT_LOG="darknet_global/global_chat.log"
    
    clear_screen
    echo "========================================================"
    echo "  DARKNET TERMINAL v3.0 - GLOBAL REAL-TIME CHAT"
    echo "========================================================"
    echo ""
    echo "[1] JOIN GLOBAL CHAT    [2] HOST SERVER     [3] VIEW ONLINE"
    echo "[4] CHAT HISTORY       [5] GEN ANON-ID    [0] EXIT DARKNET"
    echo ""
    read -p "Choose: " choice
    
    case $choice in
        1) global_chat ;;
        2) host_server ;;
        3|4|5) echo "Feature coming soon!"; sleep 2 ;;
        0) return ;;
    esac
}

global_chat() {
    read -p "Enter your Anon-ID [anon_xxx]: " USERID
    if [ -z "$USERID" ]; then
        USERID="anon_$(openssl rand -hex 3 | cut -c1-6)"
    fi
    
    echo "<$USERID> JOINED DARKNET" >> darknet_global/global_chat.log
    echo "[+] Connected to GLOBAL CHAT"
    echo "[+] Type :q to quit | :c to clear | :h for help"
    
    while true; do
        echo -n "<$USERID> "
        read MESSAGE
        if [ "$MESSAGE" = ":q" ]; then
            break
        elif [ "$MESSAGE" = ":c" ]; then
            clear_screen
        elif [ "$MESSAGE" = ":h" ]; then
            echo ":q - Quit | :c - Clear | :h - Help"
        else
            echo "<$USERID> $MESSAGE" >> darknet_global/global_chat.log
            echo "[SENT] Message broadcast to ALL darknet terminals..."
        fi
    done
}

host_server() {
    echo "[+] DARKNET SERVER ACTIVE - Broadcasting to all clients"
    while true; do
        clear_screen
        echo "========================================================"
        echo "              LIVE CHAT FEED"
        echo "========================================================"
        cat darknet_global/global_chat.log
        sleep 2
    done
}

# Make executable and run
chmod +x "$0"
menu
