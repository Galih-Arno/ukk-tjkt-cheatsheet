#!/bin/bash
#############################################################################
# 🚀 ARNO UKK Cheatsheet - Quick Installer (Auto-Run)
# Usage: -
#############################################################################

SCRIPT_URL="https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/cheatsheet.sh"
SCRIPT_PATH="$HOME/.ukk-cheatsheet.sh"
ALIAS_FILE="$HOME/.bash_aliases"

echo ""
echo -e "\033[0;32m╔══════════════════════════════════════════╗\033[0m"
echo -e "\033[0;32m║\033[0m  \033[0;36mARNO UKK Installer\033[0m                \033[0;32m║\033[0m"
echo -e "\033[0;32m╚══════════════════════════════════════════╝\033[0m"
echo ""
echo "📥 Downloading..."

curl -sL "$SCRIPT_URL" -o "$SCRIPT_PATH"

if [ -f "$SCRIPT_PATH" ]; then
    chmod +x "$SCRIPT_PATH"
    
    # Add alias
    if ! grep -q "alias ukk=" "$ALIAS_FILE" 2>/dev/null; then
        echo "alias ukk='$SCRIPT_PATH'" >> "$ALIAS_FILE"
        source "$ALIAS_FILE" 2>/dev/null || source ~/.bashrc 2>/dev/null
    fi
    
    echo ""
    echo -e "\033[0;32m✅ Installed successfully!\033[0m"
    echo ""
    echo "📍 Location: $SCRIPT_PATH"
    echo "🔧 Alias: ukk"
    echo ""
    echo -e "\033[1;33m🚀 Starting cheatsheet...\033[0m"
    echo ""
    sleep 2
    
    # Auto-run
    "$SCRIPT_PATH"
else
    echo -e "\033[0;31m❌ Installation failed!\033[0m"
    exit 1
fi
