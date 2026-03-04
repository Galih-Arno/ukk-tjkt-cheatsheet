#!/bin/bash
# ARNOLOKA UKK Cheatsheet - Quick Installer
# Usage: curl -sL URL/install.sh | bash

SCRIPT_URL="https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/cheatsheet.sh"
SCRIPT_PATH="$HOME/ukk-cheatsheet.sh"

echo "📥 Downloading cheatsheet script..."
curl -sL "$SCRIPT_URL" -o "$SCRIPT_PATH"

if [ -f "$SCRIPT_PATH" ]; then
    chmod +x "$SCRIPT_PATH"
    echo "✅ Installed successfully!"
    echo ""
    echo "🚀 To run the cheatsheet:"
    echo "   ~/ukk-cheatsheet.sh"
    echo ""
    echo "💡 Or create alias:"
    echo "   echo 'alias ukk=~/ukk-cheatsheet.sh' >> ~/.bashrc"
    echo "   source ~/.bashrc"
    echo ""
    echo "Running now..."
    echo ""
    "$SCRIPT_PATH"
else
    echo "❌ Failed to download script"
    exit 1
fi
