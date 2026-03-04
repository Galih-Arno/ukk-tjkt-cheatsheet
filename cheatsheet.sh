#!/bin/bash
# ARNOLOKA UKK Cheatsheet - Stable Interactive Version
# NO CLEAR SCREEN - Works perfectly with stdin

REPO="https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main"
CACHE="$HOME/.ukk-cache"
mkdir -p "$CACHE" 2>/dev/null

# Simple color codes
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
R='\033[0;31m'
N='\033[0m'

get_file() {
    local file=$1
    local cached="$CACHE/$(echo $file | tr '/' '_')"
    
    curl -sf "$REPO/$file" -o "$cached" 2>/dev/null && cat "$cached" && return 0
    [ -f "$cached" ] && echo -e "${Y}[Offline]${N}" && cat "$cached" && return 0
    echo -e "${R}Error: Cannot fetch $file${N}"
    return 1
}

show_menu() {
    echo ""
    echo -e "${B}═══════════════════════════════════════════${N}"
    echo -e "${G}  ARNOLOKA UKK Cheatsheet${N}"
    echo -e "${B}═══════════════════════════════════════════${N}"
    echo ""
    echo -e "${Y}ROUTER (MikroTik):${N}"
    echo "  [1] VLAN & IP Address"
    echo "  [2] DHCP, NAT & Internet"
    echo -e "  [3] ${R}Firewall (LENGKAP)${N}"
    echo ""
    echo -e "${Y}SWITCH (MikroTik):${N}"
    echo "  [4] Bridge VLAN Filtering"
    echo ""
    echo -e "${Y}SERVER (Ubuntu):${N}"
    echo "  [5] Netplan (Gateway!)"
    echo "  [6] DNS Bind9"
    echo "  [7] Apache HTTPS"
    echo -e "  [8] ${G}Zabbix Monitoring${N}"
    echo ""
    echo -e "${Y}TESTING:${N}"
    echo "  [9] Test Commands"
    echo ""
    echo -e "${Y}DOCS:${N}"
    echo "  [A] Kebijakan Keamanan"
    echo "  [B] Troubleshooting"
    echo ""
    echo "─────────────────────────────────────"
    echo -e "${B}[U]${N} Update cache  ${B}[Q]${N} Quit"
    echo ""
}

view() {
    local file=$1
    local title=$2
    
    echo ""
    echo -e "${B}>>> $title${N}"
    echo ""
    
    if get_file "$file" | less -R; then
        echo ""
        echo -e "${Y}Tip: /keyword = search | q = quit | Enter = back${N}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

update_all() {
    echo ""
    echo -e "${G}Updating cache...${N}"
    for f in README.md router/01-vlan-ip.md router/02-dhcp-nat.md router/03-firewall.md switch/01-bridge-vlan.md server/01-netplan.md server/02-dns-bind9.md server/03-web-https.md server/04-zabbix-setup.md testing/01-verify-commands.md; do
        echo -n "  $f... "
        curl -sf "$REPO/$f" -o "$CACHE/$(echo $f | tr '/' '_')" 2>/dev/null && echo -e "${G}OK${N}" || echo -e "${R}FAIL${N}"
    done
    echo -e "${G}Done! Cache: $CACHE${N}"
    echo ""
    read -p "Press Enter to continue..."
}

# WELCOME
echo ""
echo -e "${G}Welcome to ARNOLOKA UKK Cheatsheet!${N}"
echo "Repo: github.com/Galih-Arno/ukk-tjkt-cheatsheet"
echo ""
read -p "Press Enter to start..."

# MAIN LOOP
while true; do
    show_menu
    read -p "Choose menu: " choice
    
    case $choice in
        1) view "router/01-vlan-ip.md" "Router: VLAN & IP" ;;
        2) view "router/02-dhcp-nat.md" "Router: DHCP & NAT" ;;
        3) view "router/03-firewall.md" "Router: Firewall" ;;
        4) view "switch/01-bridge-vlan.md" "Switch: Bridge VLAN" ;;
        5) view "server/01-netplan.md" "Server: Netplan" ;;
        6) view "server/02-dns-bind9.md" "Server: DNS Bind9" ;;
        7) view "server/03-web-https.md" "Server: Apache HTTPS" ;;
        8) view "server/04-zabbix-setup.md" "Server: Zabbix" ;;
        9) view "testing/01-verify-commands.md" "Testing Commands" ;;
        [Aa]) view "docs/kebijakan-keamanan.md" "Kebijakan Keamanan" ;;
        [Bb]) view "docs/troubleshooting.md" "Troubleshooting" ;;
        [Uu]) update_all ;;
        [Qq]) echo -e "${G}Good luck with UKK!${N}"; exit 0 ;;
        *) echo -e "${R}Invalid choice!${N}"; sleep 1 ;;
    esac
done
