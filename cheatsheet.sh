#!/bin/bash
# Ultra-simple version - no clear, no colors issue

REPO="https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main"

while true; do
    echo ""
    echo "═══════════════════════════════════════════"
    echo "  ARNOLOKA UKK Cheatsheet - Simple Version"
    echo "═══════════════════════════════════════════"
    echo "[1] Router VLAN    [5] Server Netplan"
    echo "[2] Router DHCP    [6] Server DNS"
    echo "[3] Router FW      [7] Server Web"
    echo "[4] Switch VLAN    [8] Server Zabbix"
    echo "[9] Testing        [Q] Quit"
    echo ""
    echo -n "Pilih menu: "
    read menu
    
    case $menu in
        1) curl -s $REPO/router/01-vlan-ip.md | less ;;
        2) curl -s $REPO/router/02-dhcp-nat.md | less ;;
        3) curl -s $REPO/router/03-firewall.md | less ;;
        4) curl -s $REPO/switch/01-bridge-vlan.md | less ;;
        5) curl -s $REPO/server/01-netplan.md | less ;;
        6) curl -s $REPO/server/02-dns-bind9.md | less ;;
        7) curl -s $REPO/server/03-web-https.md | less ;;
        8) curl -s $REPO/server/04-zabbix-setup.md | less ;;
        9) curl -s $REPO/testing/01-verify-commands.md | less ;;
        [Qq]) echo "Good luck!"; exit 0 ;;
        *) echo "Invalid choice" ;;
    esac
done
