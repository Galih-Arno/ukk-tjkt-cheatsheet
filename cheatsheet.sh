#!/bin/bash
#############################################################################
# 📘 ARNOLOKA UKK TJKT 2026 - Interactive Cloud Cheatsheet
# 🎯 Usage: curl -sL https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/cheatsheet.sh | bash
# 👤 Maintainer: @Galih-Arno
# 📅 Last Update: 2026-03-04
#############################################################################

# Configuration
REPO_OWNER="Galih-Arno"
REPO_NAME="ukk-tjkt-cheatsheet"
REPO_BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_BRANCH}"

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Cache directory for offline mode
CACHE_DIR="$HOME/.ukk-cheatsheet-cache"
mkdir -p "$CACHE_DIR" 2>/dev/null

#############################################################################
# HELPER FUNCTIONS
#############################################################################

# Check internet connection
check_internet() {
    curl -sf --connect-timeout 3 "https://github.com" > /dev/null 2>&1
    return $?
}

# Fetch content from GitHub (with fallback to cache)
fetch_content() {
    local file_path=$1
    local cache_file="$CACHE_DIR/$(echo "$file_path" | tr '/' '_')"
    
    # Try online first
    if check_internet; then
        if curl -sf --connect-timeout 5 "${BASE_URL}/${file_path}" -o "$cache_file" 2>/dev/null; then
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Fallback to cache if offline
    if [ -f "$cache_file" ]; then
        echo -e "${YELLOW}⚠ Offline mode - showing cached version${NC}" >&2
        cat "$cache_file"
        return 0
    fi
    
    echo -e "${RED}❌ Error: Cannot fetch content. Check your internet connection.${NC}" >&2
    return 1
}

# Display content with less (with search hint)
show_content() {
    local content=$1
    echo "$content" | less -R +G  # Start at bottom, -R for colors
}

# Clear screen with header
clear_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  📘 ${GREEN}ARNOLOKA UKK Cheatsheet${NC} ${CYAN}          ║${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}github.com/${REPO_OWNER}/${REPO_NAME}${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

#############################################################################
# MENU FUNCTIONS
#############################################################################

show_main_menu() {
    clear_header
    echo -e "${GREEN}📚 MAIN MENU${NC}"
    echo "─────────────────────────────────────"
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
    echo -e "  [8] ${GREEN}📊 Zabbix 7.0 Monitoring Setup${NC}"
    echo ""
    echo -e "${YELLOW}🧪 TESTING & VERIFICATION${NC}"
    echo "  [9] Testing Commands + Checklist"
    echo ""
    echo -e "${YELLOW}📄 DOCUMENTATION${NC}"
    echo "  [A] Kebijakan Keamanan (Template)"
    echo "  [B] Troubleshooting Quick Fix"
    echo ""
    echo "─────────────────────────────────────"
    echo -e "${CYAN}[U]${NC} Update cheatsheet cache  ${CYAN}[Q]${NC} Quit"
    echo ""
    echo -n -e "${GREEN}➤ Pilih menu (1-9, A, B, U, Q): ${NC}"
}

show_submenu_docs() {
    clear_header
    echo -e "${GREEN}📄 DOCUMENTATION MENU${NC}"
    echo "─────────────────────────────────────"
    echo "  [A] Kebijakan Keamanan (Template .docx)"
    echo "  [B] Troubleshooting Quick Fix Guide"
    echo ""
    echo "─────────────────────────────────────"
    echo -e "${CYAN}[M]${NC} Back to Main Menu  ${CYAN}[Q]${NC} Quit"
    echo ""
    echo -n -e "${GREEN}➤ Pilih menu (A, B, M, Q): ${NC}"
}

#############################################################################
# CONTENT DISPLAY FUNCTIONS
#############################################################################

view_file() {
    local file_path=$1
    local title=$2
    
    clear_header
    echo -e "${BLUE}📖 $title${NC}"
    echo "─────────────────────────────────────"
    echo ""
    
    if fetch_content "$file_path" | show_content; then
        echo ""
        echo -e "${YELLOW}💡 Tips: Tekan '/' untuk search, 'q' untuk keluar${NC}"
    fi
    echo ""
    echo -n "Tekan Enter untuk kembali ke menu..."
    read
}

update_cache() {
    clear_header
    echo -e "${GREEN}🔄 Updating cheatsheet cache...${NC}"
    echo ""
    
    if ! check_internet; then
        echo -e "${RED}❌ Tidak ada koneksi internet!${NC}"
        echo "Tips: Pastikan server terhubung ke Router VLAN 30"
        echo ""
        echo -n "Tekan Enter..."
        read
        return 1
    fi
    
    # List of files to cache
    local files=(
        "README.md"
        "router/01-vlan-ip.md"
        "router/02-dhcp-nat.md"
        "router/03-firewall.md"
        "switch/01-bridge-vlan.md"
        "server/01-netplan.md"
        "server/02-dns-bind9.md"
        "server/03-web-https.md"
        "server/04-zabbix-setup.md"
        "testing/01-verify-commands.md"
        "docs/kebijakan-keamanan.md"
        "docs/troubleshooting.md"
    )
    
    local success=0
    local failed=0
    
    for file in "${files[@]}"; do
        if curl -sf --connect-timeout 5 "${BASE_URL}/${file}" -o "$CACHE_DIR/$(echo "$file" | tr '/' '_')" 2>/dev/null; then
            ((success++))
            echo -e "  ${GREEN}✓${NC} $file"
        else
            ((failed++))
            echo -e "  ${RED}✗${NC} $file"
        fi
    done
    
    echo ""
    echo "─────────────────────────────────────"
    echo -e "Result: ${GREEN}${success} success${NC}, ${RED}${failed} failed${NC}"
    echo -e "Cache location: ${BLUE}$CACHE_DIR${NC}"
    echo ""
    echo -n "Tekan Enter..."
    read
}

show_quick_info() {
    clear_header
    echo -e "${GREEN}⚡ QUICK INFO${NC}"
    echo "─────────────────────────────────────"
    echo ""
    echo -e "${YELLOW}🌐 Repository:${NC}"
    echo "  https://github.com/${REPO_OWNER}/${REPO_NAME}"
    echo ""
    echo -e "${YELLOW}🔧 Cara Pakai:${NC}"
    echo "  1. Ketik: curl -sL URL | bash"
    echo "  2. Pilih menu dengan angka/huruf"
    echo "  3. Tekan 'q' untuk keluar dari bacaan"
    echo "  4. Tekan Enter untuk kembali ke menu"
    echo ""
    echo -e "${YELLOW}📥 Offline Mode:${NC}"
    echo "  - Pilih menu [U] untuk download cache"
    echo "  - File tersimpan di: ~/.ukk-cheatsheet-cache/"
    echo "  - Bisa diakses walau internet putus"
    echo ""
    echo -e "${YELLOW}🔍 Search di Less:${NC}"
    echo "  /keyword  → Cari teks"
    echo "  n         → Next hasil"
    echo "  q         → Quit"
    echo ""
    echo -n "Tekan Enter..."
    read
}

#############################################################################
# MAIN LOOP
#############################################################################

main() {
    # Show welcome on first run
    if [ ! -f "$CACHE_DIR/.welcome_shown" ]; then
        clear_header
        echo -e "${GREEN}🎉 Selamat Datang di ARNOLOKA UKK Cheatsheet!${NC}"
        echo ""
        echo "Ini adalah panduan interaktif untuk UKK TJKT 2026."
        echo "Konten diambil dari GitHub: ${BLUE}${REPO_OWNER}/${REPO_NAME}${NC}"
        echo ""
        echo -e "${YELLOW}💡 Tips:${NC}"
        echo "  • Pastikan server terhubung internet via Router VLAN 30"
        echo "  • Gunakan menu [U] untuk download cache offline"
        echo "  • Tekan 'q' untuk keluar dari tampilan bacaan"
        echo ""
        echo -n "Tekan Enter untuk mulai..."
        read
        touch "$CACHE_DIR/.welcome_shown"
    fi
    
    while true; do
        show_main_menu
        read -n 1 choice
        echo ""  # New line after input
        
        case $choice in
            1) view_file "router/01-vlan-ip.md" "🎯 Router: VLAN & IP Address" ;;
            2) view_file "router/02-dhcp-nat.md" "🎯 Router: DHCP, NAT & Internet" ;;
            3) view_file "router/03-firewall.md" "🔥 Router: Firewall Rules (PENTING!)" ;;
            4) view_file "switch/01-bridge-vlan.md" "🔄 Switch: Bridge VLAN Filtering" ;;
            5) view_file "server/01-netplan.md" "💻 Server: Netplan (Gateway 192.168.30.1!)" ;;
            6) view_file "server/02-dns-bind9.md" "💻 Server: DNS Bind9 + Hardening" ;;
            7) view_file "server/03-web-https.md" "💻 Server: Apache Web + HTTPS" ;;
            8) view_file "server/04-zabbix-setup.md" "📊 Server: Zabbix 7.0 Monitoring" ;;
            9) view_file "testing/01-verify-commands.md" "🧪 Testing Commands + Checklist" ;;
            [Aa]) view_file "docs/kebijakan-keamanan.md" "📄 Kebijakan Keamanan (Template)" ;;
            [Bb]) view_file "docs/troubleshooting.md" "📄 Troubleshooting Quick Fix" ;;
            [Uu]) update_cache ;;
            [Ii]) show_quick_info ;;
            [Qq]) 
                clear_header
                echo -e "${GREEN}🚀 Semangat UKK-nya, Boss! Good luck! 🎓${NC}"
                echo ""
                exit 0
                ;;
            *) 
                echo -e "${RED}⚠ Pilihan tidak valid. Tekan Enter untuk coba lagi...${NC}"
                read
                ;;
        esac
    done
}

#############################################################################
# ENTRY POINT
#############################################################################

# Run main function
main
