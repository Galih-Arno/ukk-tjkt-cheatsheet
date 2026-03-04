#!/bin/bash
#############################################################################
# ARNOLOKA UKK Cheatsheet - SIMPLE NANO VERSION
# Workflow: Pilih Menu → Langsung Nano → Baca/Copy → Ctrl+X → Balik Menu
# No Mouse Required | Full Content Save | Clean & Simple
#############################################################################

REPO="https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main"
CACHE="$HOME/.ukk-cache"
WORK="$HOME/.ukk-work"
mkdir -p "$CACHE" "$WORK" 2>/dev/null

# Colors
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
R='\033[0;31m'
C='\033[0;36m'
N='\033[0m'

#############################################################################
# HELPER FUNCTIONS
#############################################################################

# Get file from GitHub or cache
get_file() {
    local file=$1
    local cached="$CACHE/$(echo $file | tr '/' '_')"
    
    if [ ! -f "$cached" ] || [ $(find "$cached" -mmin +60 2>/dev/null) ]; then
        curl -sf "$REPO/$file" -o "$cached" 2>/dev/null
    fi
    
    if [ -s "$cached" ]; then
        cat "$cached"
        return 0
    else
        return 1
    fi
}

# Clean markdown for better nano reading
clean_md() {
    sed -e 's/^###* /  /g' \
        -e 's/^##* /  /g' \
        -e 's/\*\*\([^*]*\)\*\*/\1/g' \
        -e 's/\*\([^*]*\)\*/\1/g' \
        -e 's/^\`[^`]*\`//g' \
        -e 's/\`[^`]*\`/\1/g' \
        -e 's/^> /  │ /g' \
        -e 's/^---*/═══════════════════════════════════════════/g' \
        -e 's/^- /  • /g' \
        -e '/^```/d' | cat -s
}

# Save full content and open in nano
open_in_nano() {
    local file=$1
    local title=$2
    
    # Generate output filename
    local basename=$(basename "$file" .md)
    local output="$WORK/${basename}.txt"
    
    # Create header
    cat > "$output" << HEADER
═══════════════════════════════════════════
$TITLE
═══════════════════════════════════════════
Source: $file
Generated: $(date)

KEYBOARD NAVIGATION:
  ↑↓←→     : Move cursor
  PageUp/Dn: Scroll page
  Ctrl+Home: Go to top
  Ctrl+End : Go to bottom
  Ctrl+W   : Search keyword
  Ctrl+K   : Cut line
  Ctrl+U   : Paste cut line
  Ctrl+X   : Exit to menu
  Ctrl+O   : Save (if you edit)

TIPS:
  • Read carefully before copying commands
  • Search with Ctrl+W for keywords
  • Copy: Select text + Ctrl+Shift+C (in most terminals)
  • This is NOT a script - do NOT execute this file!
═══════════════════════════════════════════


HEADER
    
    # Get and clean content
    get_file "$file" | clean_md >> "$output" 2>/dev/null
    
    if [ -s "$output" ]; then
        # Clear screen and open nano
        clear
        nano "$output"
    else
        echo -e "${R}Error: Cannot load content${N}"
        sleep 2
    fi
}

#############################################################################
# MENU FUNCTION
#############################################################################

show_menu() {
    clear
    echo ""
    echo -e "${B}╔══════════════════════════════════════════╗${N}"
    echo -e "${B}║${N}  ${G}ARNOLOKA UKK Cheatsheet${N}              ${B}║${N}"
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
    echo -e "${B}[U]${N} Update Cache  ${B}[Q]${N} Quit"
    echo ""
}

#############################################################################
# UPDATE CACHE FUNCTION
#############################################################################

update_cache() {
    clear
    echo ""
    echo -e "${G}🔄 Updating all files...${N}"
    echo ""
    
    for f in README.md router/01-vlan-ip.md router/02-dhcp-nat.md router/03-firewall.md switch/01-bridge-vlan.md server/01-netplan.md server/02-dns-bind9.md server/03-web-https.md server/04-zabbix-setup.md testing/01-verify-commands.md docs/kebijakan-keamanan.md docs/troubleshooting.md; do
        printf "  %-40s " "$f"
        if curl -sf "$REPO/$f" -o "$CACHE/$(echo $f | tr '/' '_')" 2>/dev/null; then
            if [ -s "$CACHE/$(echo $f | tr '/' '_')" ]; then
                echo -e "${G}OK${N}"
            else
                echo -e "${R}EMPTY${N}"
            fi
        else
            echo -e "${R}FAIL${N}"
        fi
    done
    
    echo ""
    echo -e "${G}✅ Done!${N}"
    echo ""
    echo -e "${Y}Press Enter to continue...${N}"
    read dummy
}

#############################################################################
# MAIN FUNCTION
#############################################################################

main() {
    # Welcome
    clear
    echo -e "${G}╔══════════════════════════════════════════╗${N}"
    echo -e "${G}║${N}  ${C}ARNOLOKA UKK Cheatsheet${N}                ${G}║${N}"
    echo -e "${G}╚══════════════════════════════════════════╝${N}"
    echo ""
    echo "Repo: github.com/Galih-Arno/ukk-tjkt-cheatsheet"
    echo "Deployed: arno-ukk.vercel.app"
    echo ""
    echo -e "${Y}Workflow:${N}"
    echo "  1. Pilih menu"
    echo "  2. Baca panduan di nano"
    echo "  3. Copy command yang diperlukan"
    echo "  4. Ctrl+X untuk keluar"
    echo "  5. Kembali ke menu"
    echo ""
    echo -e "${Y}Press Enter to start...${N}"
    read dummy
    
    # Main loop
    while true; do
        show_menu
        echo -ne "${G}➤ Menu: ${N}"
        read choice
        
        # Normalize input
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        case "$choice" in
            1) open_in_nano "router/01-vlan-ip.md" "ROUTER: VLAN & IP ADDRESS" ;;
            2) open_in_nano "router/02-dhcp-nat.md" "ROUTER: DHCP, NAT & INTERNET" ;;
            3) open_in_nano "router/03-firewall.md" "ROUTER: FIREWALL (LENGKAP)" ;;
            4) open_in_nano "switch/01-bridge-vlan.md" "SWITCH: BRIDGE VLAN FILTERING" ;;
            5) open_in_nano "server/01-netplan.md" "SERVER: NETPLAN (GATEWAY!)" ;;
            6) open_in_nano "server/02-dns-bind9.md" "SERVER: DNS BIND9" ;;
            7) open_in_nano "server/03-web-https.md" "SERVER: APACHE HTTPS" ;;
            8) open_in_nano "server/04-zabbix-setup.md" "SERVER: ZABBIX 7.0 MONITORING" ;;
            9) open_in_nano "testing/01-verify-commands.md" "TESTING & VERIFICATION" ;;
            a) open_in_nano "docs/kebijakan-keamanan.md" "KEBIJAKAN KEAMANAN" ;;
            b) open_in_nano "docs/troubleshooting.md" "TROUBLESHOOTING" ;;
            u) update_cache ;;
            q) clear
               echo -e "${G}╔══════════════════════════════════════════╗${N}"
               echo -e "${G}║${N}  ${C}🚀 Good luck with UKK!${N}                  ${G}║${N}"
               echo -e "${G}╚══════════════════════════════════════════╝${N}"
               echo ""
               exit 0
               ;;
            *) echo -e "${R}Invalid!${N}"; sleep 1 ;;
        esac
    done
}

#############################################################################
# RUN
#############################################################################

main
