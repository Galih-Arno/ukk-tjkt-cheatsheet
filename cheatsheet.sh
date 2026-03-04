#!/bin/bash
# ARNO UKK Cheatsheet - SIMPLE WORKING VERSION

REPO="https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main"
CACHE="$HOME/.ukk-cache"
mkdir -p "$CACHE" 2>/dev/null

# Colors
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
R='\033[0;31m'
N='\033[0m'

# Get file from GitHub or cache
get_file() {
    local file=$1
    local cached="$CACHE/$(echo $file | tr '/' '_')"
    
    # Download if not exists or older than 1 hour
    if [ ! -f "$cached" ] || [ $(find "$cached" -mmin +60 2>/dev/null) ]; then
        curl -sf "$REPO/$file" -o "$cached" 2>/dev/null
    fi
    
    # Display content (NO strip_md - show raw markdown)
    if [ -s "$cached" ]; then
        cat "$cached"
    else
        echo -e "${R}Error: Cannot load $file${N}"
    fi
}

# Show Menu
show_menu() {
    clear
    echo ""
    echo -e "${B}╔══════════════════════════════════════════╗${N}"
    echo -e "${B}║${N}  ${G}ARNO UKK Cheatsheet${N}              ${B}║${N}"
    echo -e "${B}╚══════════════════════════════════════════╝${N}"
    echo ""
    echo -e "${Y}🎯 ROUTER (MikroTik)${N}"
    echo "  [1] VLAN & IP Address"
    echo "  [2] DHCP, NAT & Internet"
    echo -e "  [3] ${R}🔥 Firewall (LENGKAP)${N}"
    echo ""
    echo -e "${Y}🔄 SWITCH (MikroTik)${N}"
    echo "  [4] Bridge VLAN Filtering"
    echo ""
    echo -e "${Y}💻 SERVER (Ubuntu)${N}"
    echo "  [5] Netplan (Gateway!)"
    echo "  [6] DNS Bind9"
    echo "  [7] Apache HTTPS"
    echo -e "  [8] ${G}📊 Zabbix 7.0${N}"
    echo ""
    echo -e "${Y}🧪 TESTING${N}"
    echo "  [9] Test Commands"
    echo ""
    echo -e "${Y}📄 DOCS${N}"
    echo "  [A] Kebijakan Keamanan"
    echo "  [B] Troubleshooting"
    echo ""
    echo "──────────────────────────────────────"
    echo -e "${B}[U]${N} Update  ${B}[Q]${N} Quit"
    echo ""
}

# View Content
view() {
    local file=$1
    local title=$2
    
    echo ""
    echo -e "${B}══════════════════════════════════════════${N}"
    echo -e "${B}  $title${N}"
    echo -e "${B}══════════════════════════════════════════${N}"
    echo ""
    
    # Get and display content directly
    get_file "$file" | less -R
    
    echo ""
    echo -e "${Y}Press Enter to continue...${N}"
    read dummy
}

# Update All Cache
update_cache() {
    echo ""
    echo -e "${G}🔄 Updating all files...${N}"
    
    for f in README.md router/01-vlan-ip.md router/02-dhcp-nat.md router/03-firewall.md switch/01-bridge-vlan.md server/01-netplan.md server/02-dns-bind9.md server/03-web-https.md server/04-zabbix-setup.md testing/01-verify-commands.md; do
        printf "  %-30s " "$f"
        if curl -sf "$REPO/$f" -o "$CACHE/$(echo $f | tr '/' '_')" 2>/dev/null; then
            echo -e "${G}OK${N}"
        else
            echo -e "${R}FAIL${N}"
        fi
    done
    
    echo -e "\n${G}✅ Done!${N}"
    echo ""
    echo -e "${Y}Press Enter to continue...${N}"
    read dummy
}

# MAIN LOOP
main() {
    # Welcome
    clear
    echo -e "${G}╔══════════════════════════════════════════╗${N}"
    echo -e "${G}║${N}  ${B}ARNO UKK Cheatsheet${N}                ${G}║${N}"
    echo -e "${G}╚══════════════════════════════════════════╝${N}"
    echo ""
    echo "Repo: github.com/Galih-Arno/ukk-tjkt-cheatsheet"
    echo ""
    echo -e "${Y}Press Enter to start...${N}"
    read dummy
    
    while true; do
        show_menu
        echo -ne "${G}➤ Menu: ${N}"
        read choice
        
        # Normalize input
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        case "$choice" in
            1) view "router/01-vlan-ip.md" "Router: VLAN & IP" ;;
            2) view "router/02-dhcp-nat.md" "Router: DHCP & NAT" ;;
            3) view "router/03-firewall.md" "Router: Firewall" ;;
            4) view "switch/01-bridge-vlan.md" "Switch: Bridge VLAN" ;;
            5) view "server/01-netplan.md" "Server: Netplan" ;;
            6) view "server/02-dns-bind9.md" "Server: DNS Bind9" ;;
            7) view "server/03-web-https.md" "Server: Apache HTTPS" ;;
            8) view "server/04-zabbix-setup.md" "Server: Zabbix" ;;
            9) view "testing/01-verify-commands.md" "Testing" ;;
            a) view "docs/kebijakan-keamanan.md" "Kebijakan Keamanan" ;;
            b) view "docs/troubleshooting.md" "Troubleshooting" ;;
            u) update_cache ;;
            q) clear; echo -e "${G}🚀 Good luck UKK!${N}\n"; exit 0 ;;
            *) echo -e "${R}Invalid!${N}"; sleep 1 ;;
        esac
    done
}

# Run
main
