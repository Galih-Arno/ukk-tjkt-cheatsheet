#!/bin/bash
#############################################################################
# ARNOLOKA UKK Cheatsheet - FINAL VERSION (MD FILES)
# Features: View guides → Extract commands → Edit in nano → Execute
# No Mouse Required | No tmux Required | Pure CLI Keyboard Workflow
# File Format: .md (Markdown)
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

#############################################################################
# HELPER FUNCTIONS
#############################################################################

# Get file from GitHub or cache
get_file() {
    local file=$1
    local cached="$CACHE/$(echo $file | tr '/' '_')"
    
    # Download if not exists or older than 1 hour
    if [ ! -f "$cached" ] || [ $(find "$cached" -mmin +60 2>/dev/null) ]; then
        curl -sf "$REPO/$file" -o "$cached" 2>/dev/null
    fi
    
    # Display content
    if [ -s "$cached" ]; then
        cat "$cached"
    else
        echo -e "${R}Error: Cannot load $file${N}"
        return 1
    fi
}

# Extract commands from markdown content
extract_commands() {
    local file=$1
    local output=$2
    
    # Create header
    echo "#!/bin/bash" > "$output"
    echo "# ARNOLOKA UKK - Commands Extracted" >> "$output"
    echo "# Source: $file" >> "$output"
    echo "# Generated: $(date)" >> "$output"
    echo "# WARNING: Review before executing!" >> "$output"
    echo "" >> "$output"
    
    # Extract command lines (filter markdown syntax)
    get_file "$file" | grep -v "^#" | grep -v "^>" | grep -v "^|" | grep -v "^-" | grep -v "^$" | grep -v "^\`\`\`" | grep -E "(sudo|apt|systemctl|mysql|curl|wget|nano|chmod|chown|echo|mkdir|cat|touch|zcat|openssl|a2enmod|a2ensite|named-check|snmpwalk|zabbix_get|^ip |^ping |^nslookup |^dig |ufw )" >> "$output" 2>/dev/null
    
    # If no commands extracted, get content without markdown
    if [ ! -s "$output" ] || [ $(wc -l < "$output") -le 3 ]; then
        get_file "$file" | sed 's/^#\+ //g' | sed 's/\*\*//g' | sed 's/\`//g' >> "$output"
    fi
    
    chmod +x "$output"
}

#############################################################################
# MENU FUNCTIONS
#############################################################################

# Show Menu
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
    echo -e "${B}[U]${N} Update  ${B}[Q]${N} Quit"
    echo ""
}

#############################################################################
# VIEW & EXTRACT FUNCTIONS
#############################################################################

# View Content with Extract Option
view() {
    local file=$1
    local title=$2
    
    echo ""
    echo -e "${B}══════════════════════════════════════════${N}"
    echo -e "${B}  $title${N}"
    echo -e "${B}══════════════════════════════════════════${N}"
    echo ""
    
    # Check if file exists first
    local cached="$CACHE/$(echo $file | tr '/' '_')"
    if ! curl -sf "$REPO/$file" -o "$cached" 2>/dev/null || [ ! -s "$cached" ]; then
        echo -e "${R}❌ Error: Cannot load $file${N}"
        echo ""
        echo "Possible causes:"
        echo "  1. File does not exist in GitHub repo"
        echo "  2. Internet connection issue"
        echo "  3. Wrong file path"
        echo ""
        echo "Check URL: $REPO/$file"
        echo ""
        echo -e "${Y}Press Enter to continue...${N}"
        read dummy
        return 1
    fi
    
    # Get and display content in less
    cat "$cached" | less -R
    
    # After viewing, offer extract option
    echo ""
    echo -e "${C}[E]${N} Extract commands to file (for copy/edit)"
    echo -e "${C}[Q]${N} Back to menu"
    echo ""
    echo -n "Pilih: "
    read opt
    
    case $opt in
        [Ee]) extract_and_edit "$file" "$title" ;;
        *) ;;
    esac
}

# Extract Commands & Open in Nano
extract_and_edit() {
    local file=$1
    local title=$2
    
    # Generate output filename
    local basename=$(basename "$file" .md)
    local output="$HOME/ukk-${basename}.sh"
    
    echo ""
    echo -e "${G}📥 Extracting commands...${N}"
    
    # Extract commands
    extract_commands "$file" "$output"
    
    if [ -s "$output" ]; then
        echo -e "${G}✅ Saved to: $output${N}"
        echo ""
        echo -e "${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
        echo -e "${Y}  WHAT DO YOU WANT TO DO?${N}"
        echo -e "${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
        echo ""
        echo -e "${C}[E]${N} Edit in nano (review/copy commands)"
        echo -e "${C}[X]${N} Execute directly (⚠️ DANGEROUS!)"
        echo -e "${C}[V]${N} View content in less"
        echo -e "${C}[C]${N} Copy to clipboard file (~/ukk-copy.txt)"
        echo -e "${C}[Q]${N} Back to menu"
        echo ""
        echo -e "${R}Keyboard Navigation in nano:${N}"
        echo "  ↑↓←→ : Move cursor"
        echo "  Ctrl+K : Cut line"
        echo "  Ctrl+U : Paste cut line"
        echo "  Ctrl+X : Exit (will ask to save)"
        echo "  Ctrl+O : Save file"
        echo ""
        echo -n "Pilih: "
        read action
        
        case $action in
            [Ee])
                clear
                echo -e "${G}═══════════════════════════════════════════${N}"
                echo -e "${G}  NANO EDIT MODE${N}"
                echo -e "${G}═══════════════════════════════════════════${N}"
                echo ""
                echo "File: $output"
                echo ""
                echo -e "${Y}Instructions:${N}"
                echo "  • Navigate: Arrow keys ↑↓←→"
                echo "  • Select: Shift+Arrow (if terminal supports)"
                echo "  • Copy: Ctrl+Shift+C (in most terminals)"
                echo "  • Cut line: Ctrl+K"
                echo "  • Paste: Ctrl+U"
                echo "  • Save: Ctrl+O → Enter"
                echo "  • Exit: Ctrl+X"
                echo ""
                echo -e "${R}  Tip: Comment out dangerous lines with #${N}"
                echo ""
                echo -n "Press Enter to open nano..."
                read dummy
                nano "$output"
                echo ""
                echo -e "${G}Edit complete! File saved at: $output${N}"
                echo "Run with: bash $output"
                echo ""
                echo -n "Press Enter to continue..."
                read dummy
                ;;
            [Xx])
                echo ""
                echo -e "${R}╔═══════════════════════════════════════════╗${N}"
                echo -e "${R}║  ⚠️  WARNING: EXECUTE ALL COMMANDS?  ⚠️  ${N}"
                echo -e "${R}╚═══════════════════════════════════════════╝${N}"
                echo ""
                echo "File: $output"
                echo ""
                echo "Preview first 5 lines:"
                head -5 "$output"
                echo "..."
                echo ""
                read -p "Are you SURE? Type 'YES' to confirm: " confirm
                if [ "$confirm" = "YES" ]; then
                    echo ""
                    echo -e "${G}Executing...${N}"
                    bash "$output"
                    echo ""
                    echo -e "${G}Execution complete!${N}"
                    echo ""
                    echo -n "Press Enter to continue..."
                    read dummy
                else
                    echo -e "${Y}Cancelled.${N}"
                    echo ""
                    echo -n "Press Enter to continue..."
                    read dummy
                fi
                ;;
            [Vv])
                echo ""
                echo -e "${G}Content of $output:${N}"
                echo ""
                less "$output"
                ;;
            [Cc])
                cp "$output" ~/ukk-copy.txt
                echo -e "${G}✅ Copied to: ~/ukk-copy.txt${N}"
                echo "Open with: nano ~/ukk-copy.txt"
                echo ""
                echo -n "Press Enter to continue..."
                read dummy
                ;;
            *)
                echo -e "${Y}Back to menu.${N}"
                ;;
        esac
    else
        echo -e "${R}❌ Failed to extract commands!${N}"
        echo ""
        echo -n "Press Enter to continue..."
        read dummy
    fi
}

#############################################################################
# UPDATE CACHE FUNCTION
#############################################################################

update_cache() {
    echo ""
    echo -e "${G}🔄 Updating all files...${N}"
    
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
    
    echo -e "\n${G}✅ Done!${N}"
    echo ""
    echo -e "${Y}Press Enter to continue...${N}"
    read dummy
}

#############################################################################
# MAIN FUNCTION
#############################################################################

main() {
    # Welcome screen
    clear
    echo -e "${G}╔══════════════════════════════════════════╗${N}"
    echo -e "${G}║${N}  ${C}ARNOLOKA UKK Cheatsheet${N}                ${G}║${N}"
    echo -e "${G}╚══════════════════════════════════════════╝${N}"
    echo ""
    echo "Repo: github.com/Galih-Arno/ukk-tjkt-cheatsheet"
    echo "Deployed: arno-ukk.vercel.app"
    echo ""
    echo -e "${Y}Features:${N}"
    echo "  ✓ View guides in less"
    echo "  ✓ Extract commands to editable file"
    echo "  ✓ Edit in nano (keyboard-friendly)"
    echo "  ✓ Execute or copy commands"
    echo "  ✓ No mouse required!"
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
            q) clear; echo -e "${G}╔══════════════════════════════════════════╗${N}"
                       echo -e "${G}║${N}  ${C}🚀 Good luck with UKK!${N}                  ${G}║${N}"
                       echo -e "${G}╚══════════════════════════════════════════╝${N}"
                       echo ""
                       exit 0 ;;
            *) echo -e "${R}Invalid!${N}"; sleep 1 ;;
        esac
    done
}

#############################################################################
# ENTRY POINT
#############################################################################

main
