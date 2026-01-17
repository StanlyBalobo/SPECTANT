#!/bin/bash
# termux-radar.sh - WiFi/Network Scanner for Termux Pentesting
# Save as termux-radar.sh, chmod +x, then ./termux-radar.sh

echo "🚀 Termux Pentesting Radar Starting..."
pkg update && pkg install aircrack-ng nmap tshark wireless-tools

# WiFi scanning (requires root or monitor mode)
echo "📡 Scanning WiFi networks..."
iwlist scan | grep -E "ESSID|Signal|Channel"

# Network discovery
echo "🔍 Scanning local network..."
nmap -sn 192.168.1.0/24

# Active devices
echo "📱 Active hosts:"
arp -a

echo "✅ Scan complete. Use 'tshark' for packet capture."
