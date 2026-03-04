#!/bin/bash
#############################################################################
# 📘 ARNOLOKA UKK TJKT 2026 - Interactive Cheatsheet (FINAL VERSION)
# Features: Clean output, Auto-run, Offline cache
#############################################################################

REPO="https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main"
CACHE="$HOME/.ukk-cache"
mkdir -p "$CACHE" 2>/dev/null

# Colors
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
R='\033[0;31m'
C='\033[0;36m'
N='\033[0m'

# Strip Markdown Formatting (Clean Output)
strip_md() {
    sed -e 's/^###* //' \
        -e 's/^##* //' \
        -e 's/\*\*\([^*]*\)\*\*/\1/g' \
        -e 's/\*\([^*]*\)\*/\1/g' \
        -e 's/^\`[^`]*\`//' \
        -e 's/\`[^`]*\`/\1/g' \
        -e 's/^---*$//' \
        -e 's/^> //' \
        -e '/^```/,/^```/d' \
        -e 's/^- /  • /g' \
        -e '/^$/d' | \
    cat -s
}

# Get File (Online/Offline)
get_file() {
    local file=$1
    local cached="$CACHE/$(echo $file | tr '/' '_')"
    curl -sf "$REPO/$file" -o "$cached" 2>/dev/null && cat "$cached" && return 0
    [ -f "$cached" ] && cat "$cached" && return 0
    return 1
}

# Show Menu
show_menu() {
    echo ""
    echo -e "${C}╔══════════════════════════════════════════╗${N}"
    echo -e "${C}║${N}  ${G}ARNOLOKA UKK Cheatsheet${N}              ${C}║${N}"
    echo -e "${C}╚══════════════════════════════════════════╝${N}"
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
    echo -e "${C}[U]${N} Update  ${C}[Q]${N} Quit"
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
    if get_file "$file" | strip_md | less -R; then
        echo ""
        echo -e "${Y}💡 /keyword=search | q=quit | Enter=back${N}"
    fi
    echo ""
    read -p "Press Enter..." dummy
}

# Update Cache
update_cache() {
    echo ""
    echo -e "${G}🔄 Downloading all files...${N}"
    for f in README.md router/01-vlan-ip.md router/02-dhcp-nat.md router/03-firewall.md switch/01-bridge-vlan.md server/01-netplan.md server/02-dns-bind9.md server/03-web-https.md server/04-zabbix-setup.md testing/01-verify-commands.md; do
        echo -n "  $f... "
        curl -sf "$REPO/$f" -o "$CACHE/$(echo $f | tr '/' '_')" 2>/dev/null && echo -e "${G}OK${N}" || echo -e "${R}FAIL${N}"
    done
    echo -e "${G}✅ Done! Cache: $CACHE${N}"
    echo ""
    read -p "Press Enter..." dummy
}

# Welcome
clear
echo -e "${G}╔══════════════════════════════════════════╗${N}"
echo -e "${G}║${N}  ${C}ARNOLOKA UKK Cheatsheet${N}                ${G}║${N}"
echo -e "${G}╚══════════════════════════════════════════╝${N}"
echo ""
echo "Repo: github.com/Galih-Arno/ukk-tjkt-cheatsheet"
echo ""
read -p "Press Enter to start..." dummy

# Main Loop
while true; do
    clear
    show_menu
    echo -n -e "${G}➤ Menu: ${N}"
    read choice
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
