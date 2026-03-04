#!/bin/bash
#############################################################################
# 📘 ARNOLOKA UKK TJKT 2026 - Interactive Cloud Cheatsheet (STABLE VERSION)
# 🎯 Usage: curl -sL https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/cheatsheet.sh | bash
#############################################################################

# Configuration
REPO_URL="https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main"
CACHE_DIR="$HOME/.ukk-cheatsheet"
mkdir -p "$CACHE_DIR" 2>/dev/null

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Show menu without clearing screen
show_menu() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  📘 ${GREEN}ARNOLOKA UKK Cheatsheet${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}🎯 ROUTER CONFIG (MikroTik)${NC}"
    echo "  [1] VLAN Interface & IP Address"
    echo "  [2] DHCP Server, NAT & Internet"
    echo -e "  [3] ${RED}🔥 Firewall Rules (LENGKAP)${NC}"
    echo ""
    echo -e "${YELLOW}🔄 SWITCH CONFIG (MikroTik)${NC}"
    echo "  [4] Bridge VLAN Filtering + Port Map"
    echo ""
    echo -e "${YELLOW}💻 SERVER CONFIG (Ubuntu 24.04)${NC}"
    echo "  [5] Network Setup (Netplan) ⚠️ Gateway!"
    echo "  [6] DNS Server (Bind9) + Hardening"
    echo "  [7] Web Server (Apache) + HTTPS"
    echo -e "  [8] ${GREEN}📊 Zabbix 7.0 Monitoring${NC}"
    echo ""
    echo -e "${YELLOW}🧪 TESTING & VERIFICATION${NC}"
    echo "  [9] Testing Commands + Checklist"
    echo ""
    echo -e "${YELLOW}📄 DOCUMENTATION${NC}"
    echo "  [A] Kebijakan Keamanan"
    echo "  [B] Troubleshooting Quick Fix"
    echo ""
    echo "─────────────────────────────────────"
    echo -e "${CYAN}[U]${NC} Update cache  ${CYAN}[Q]${NC} Quit"
    echo ""
}

# Fetch file from GitHub or cache
fetch_file() {
    local file=$1
    local cache_file="$CACHE_DIR/$(echo $file | tr '/' '_')"
    
    # Try download from GitHub
    if curl -sf --connect-timeout 5 "$REPO_URL/$file" -o "$cache_file" 2>/dev/null; then
        cat "$cache_file"
        return 0
    elif [ -f "$cache_file" ]; then
        echo -e "${YELLOW}⚠ Offline mode (cached)${NC}"
        cat "$cache_file"
        return 0
    else
        echo -e "${RED}❌ Error: Cannot fetch $file${NC}"
        return 1
    fi
}

# View file content
view_content() {
    local file=$1
    local title=$2
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $title${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo ""
    
    if fetch_file "$file" | less -R; then
        echo ""
        echo -e "${YELLOW}💡 Tips: '/' = search, 'q' = quit, Enter = back to menu${NC}"
    fi
    echo ""
    echo -n "Press Enter to continue..."
    read
}

# Update all cache
update_cache() {
    echo ""
    echo -e "${GREEN}🔄 Downloading all files for offline mode...${NC}"
    echo ""
    
    local files="README.md router/01-vlan-ip.md router/02-dhcp-nat.md router/03-firewall.md switch/01-bridge-vlan.md server/01-netplan.md server/02-dns-bind9.md server/03-web-https.md server/04-zabbix-setup.md testing/01-verify-commands.md docs/kebijakan-keamanan.md docs/troubleshooting.md"
    
    for file in $files; do
        echo -n "  Downloading $file... "
        if curl -sf --connect-timeout 5 "$REPO_URL/$file" -o "$CACHE_DIR/$(echo $file | tr '/' '_')" 2>/dev/null; then
            echo -e "${GREEN}OK${NC}"
        else
            echo -e "${RED}FAILED${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ Cache updated in: $CACHE_DIR${NC}"
    echo ""
    echo -n "Press Enter to continue..."
    read
}

# Main loop
main() {
    clear
    echo -e "${GREEN}🎉 Welcome to ARNOLOKA UKK Cheatsheet!${NC}"
    echo ""
    echo "Repository: github.com/Galih-Arno/ukk-tjkt-cheatsheet"
    echo ""
    echo -e "${YELLOW}💡 Tips:${NC}"
    echo "  • Pastikan server terhubung internet"
    echo "  • Gunakan menu [U] untuk download offline"
    echo "  • Tekan 'q' untuk keluar dari bacaan"
    echo ""
    echo -n "Press Enter to start..."
    read
    
    while true; do
        clear
        show_menu
        
        echo -n -e "${GREEN}➤ Pilih menu (1-9, A, B, U, Q): ${NC}"
        read choice
        
        case $choice in
            1) view_content "router/01-vlan-ip.md" "🎯 Router: VLAN & IP Address" ;;
            2) view_content "router/02-dhcp-nat.md" "🎯 Router: DHCP, NAT & Internet" ;;
            3) view_content "router/03-firewall.md" "🔥 Router: Firewall Rules" ;;
            4) view_content "switch/01-bridge-vlan.md" "🔄 Switch: Bridge VLAN Filtering" ;;
            5) view_content "server/01-netplan.md" "💻 Server: Netplan (Gateway!)" ;;
            6) view_content "server/02-dns-bind9.md" "💻 Server: DNS Bind9" ;;
            7) view_content "server/03-web-https.md" "💻 Server: Apache + HTTPS" ;;
            8) view_content "server/04-zabbix-setup.md" "📊 Server: Zabbix 7.0" ;;
            9) view_content "testing/01-verify-commands.md" "🧪 Testing Commands" ;;
            [Aa]) view_content "docs/kebijakan-keamanan.md" "📄 Kebijakan Keamanan" ;;
            [Bb]) view_content "docs/troubleshooting.md" "📄 Troubleshooting" ;;
            [Uu]) update_cache ;;
            [Qq]) 
                clear
                echo -e "${GREEN}🚀 Semangat UKK-nya! Good luck! 🎓${NC}"
                echo ""
                exit 0
                ;;
            *) 
                echo ""
                echo -e "${RED}⚠ Pilihan tidak valid!${NC}"
                echo ""
                echo -n "Press Enter to try again..."
                read
                ;;
        esac
    done
}

# Run main
main
