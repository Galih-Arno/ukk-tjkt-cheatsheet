#!/bin/bash
#############################################################################
# ARNOLOKA UKK Cheatsheet - FINAL VERSION (FULL CONTENT SAVE)
# Features: View guides → Save FULL content to file → Edit in nano → Copy
# Saves COMPLETE guide with explanations (not just commands!)
# No Mouse Required | No tmux Required | Pure CLI Keyboard Workflow
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

# Clean markdown formatting for readable text
clean_markdown() {
    sed -e 's/^###* /  /g' \
        -e 's/^##* /  /g' \
        -e 's/\*\*\([^*]*\)\*\*/\1/g' \
        -e 's/\*\([^*]*\)\*/\1/g' \
        -e 's/^\`[^`]*\`//g' \
        -e 's/\`[^`]*\`/\1/g' \
        -e 's/^> /  │ /g' \
        -e 's/^---*/═══════════════════════════════════════════/g' \
        -e 's/^- /  • /g' \
        -e '/^```/d' \
        -e '/^$/d' | cat -s
}

# Save FULL content to file (with clean formatting)
save_full_content() {
    local file=$1
    local output=$2
    
    # Create header
    cat > "$output" << EOF
#!/bin/bash
# ═══════════════════════════════════════════
# ARNOLOKA UKK - FULL GUIDE
# ═══════════════════════════════════════════
# Source: $file
# Generated: $(date)
# 
# This file contains the COMPLETE guide with:
#   ✓ Full explanations
#   ✓ All commands
#   ✓ Warnings & tips
#   ✓ Troubleshooting
#
# HOW TO USE:
#   1. Read in nano: nano $output
#   2. Navigate: Arrow keys ↑↓←→
#   3. Copy: Select text + Ctrl+Shift+C (in most terminals)
#   4. Or: Ctrl+K to cut line, Ctrl+U to paste
#   5. Exit: Ctrl+X
#
# To execute commands: Copy-paste individually
# DO NOT run this file as script!
# ═══════════════════════════════════════════

EOF
    
    # Get content and clean markdown
    get_file "$file" | clean_markdown >> "$output"
    
    # Add footer
    cat >> "$output" << EOF

# ═══════════════════════════════════════════
# END OF GUIDE
# ═══════════════════════════════════════════
EOF
    
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
# VIEW & SAVE FUNCTIONS
#############################################################################

# View Content with Save Option
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
    
    # After viewing, offer save option
    echo ""
    echo -e "${C}[S]${N} Save FULL guide to file (for copy/edit)"
    echo -e "${C}[Q]${N} Back to menu"
    echo ""
    echo -n "Pilih: "
    read opt
    
    case $opt in
        [Ss]) save_and_edit "$file" "$title" ;;
        *) ;;
    esac
}

# Save Full Content & Open in Nano
save_and_edit() {
    local file=$1
    local title=$2
    
    # Generate output filename
    local basename=$(basename "$file" .md)
    local output="$HOME/ukk-${basename}.sh"
    
    echo ""
    echo -e "${G}📥 Saving FULL guide...${N}"
    
    # Save full content
    save_full_content "$file" "$output"
    
    if [ -s "$output" ]; then
        local lines=$(wc -l < "$output")
        echo -e "${G}✅ Saved to: $output${N}"
        echo -e "${G}   Total lines: $lines${N}"
        echo ""
        echo -e "${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
        echo -e "${Y}  WHAT DO YOU WANT TO DO?${N}"
        echo -e "${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
        echo ""
        echo -e "${C}[E]${N] Edit in nano (read & copy commands)${N}"
        echo -e "${C}[V]${N} View content in less"
        echo -e "${C}[C]${N} Copy to clipboard file (~/ukk-copy.txt)"
        echo -e "${C}[I]${N} Info about this file"
        echo -e "${C}[Q]${N} Back to menu"
        echo ""
        echo -e "${R}Keyboard Navigation in nano:${N}"
        echo "  ↑↓←→     : Move cursor"
        echo "  PageUp/Dn: Scroll page"
        echo "  Ctrl+Home: Go to top"
        echo "  Ctrl+End : Go to bottom"
        echo "  Ctrl+K   : Cut line"
        echo "  Ctrl+U   : Paste cut line"
        echo "  Ctrl+X   : Exit (will ask to save)"
        echo "  Ctrl+O   : Save file"
        echo "  Ctrl+W   : Search text"
        echo ""
        echo -e "${G}Tip: Use nano to read & select commands to copy!${N}"
        echo ""
        echo -n "Pilih: "
        read action
        
        case $action in
            [Ee])
                clear
                echo -e "${G}═══════════════════════════════════════════${N}"
                echo -e "${G}  NANO EDIT MODE - FULL GUIDE${N}"
                echo -e "${G}═══════════════════════════════════════════${N}"
                echo ""
                echo "File: $output"
                echo "Lines: $lines"
                echo ""
                echo -e "${Y}Instructions:${N}"
                echo "  1. Navigate: Arrow keys ↑↓←→"
                echo "  2. Scroll: PageUp/PageDown"
                echo "  3. Go to top: Ctrl+Home"
                echo "  4. Go to bottom: Ctrl+End"
                echo "  5. Search: Ctrl+W, type keyword, Enter"
                echo "  6. Select: Shift+Arrow (if terminal supports)"
                echo "  7. Copy: Ctrl+Shift+C (in most terminals)"
                echo "  8. Cut line: Ctrl+K"
                echo "  9. Paste: Ctrl+U"
                echo "  10. Exit: Ctrl+X"
                echo ""
                echo -e "${R}  This file contains the COMPLETE guide!${N}"
                echo -e "${R}  Read carefully and copy commands as needed.${N}"
                echo ""
                echo -n "Press Enter to open nano..."
                read dummy
                nano "$output"
                echo ""
                echo -e "${G}Edit complete! File saved at: $output${N}"
                echo ""
                echo -e "${Y}To view again: nano $output${N}"
                echo -e "${Y}To search: Ctrl+W in nano, type keyword${N}"
                echo ""
                echo -n "Press Enter to continue..."
                read dummy
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
            [Ii])
                echo ""
                echo -e "${G}═══════════════════════════════════════════${N}"
                echo -e "${G}  FILE INFORMATION${N}"
                echo -e "${G}═══════════════════════════════════════════${N}"
                echo ""
                echo "Source: $file"
                echo "Output: $output"
                echo "Lines: $lines"
                echo "Size: $(du -h "$output" | cut -f1)"
                echo "Created: $(date -r "$output")"
                echo ""
                echo "This file contains:"
                echo "  ✓ Full guide with explanations"
                echo "  ✓ All commands with context"
                echo "  ✓ Warnings & troubleshooting"
                echo "  ✓ Formatted for easy reading"
                echo ""
                echo "NOT a script to execute!"
                echo "Use nano to read and copy commands manually."
                echo ""
                echo -n "Press Enter to continue..."
                read dummy
                ;;
            *)
                echo -e "${Y}Back to menu.${N}"
                ;;
        esac
    else
        echo -e "${R}❌ Failed to save content!${N}"
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
    echo "  ✓ Save FULL guide to editable file"
    echo "  ✓ Complete with explanations & warnings"
    echo "  ✓ Edit in nano (keyboard-friendly)"
    echo "  ✓ Copy commands manually (safe!)"
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
