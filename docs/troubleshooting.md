# ═══════════════════════════════════════════
# TROUBLESHOOTING QUICK FIX
# ═══════════════════════════════════════════
# Panduan Cepat Perbaikan Masalah Umum UKK
# ───────────────────────────────────────

# NETWORK & INTERNET
# ───────────────────────────────────────

# SERVER TIDAK BISA INTERNET
# ───────────────────────────────────────

# 1. Cek gateway di Netplan:

    cat /etc/netplan/00-installer-config.yaml
    
#    Pastikan: via: 192.168.30.1 (BUKAN 10.1!)

# 2. Apply ulang:

     sudo netplan apply

# 3. Test:

   ping 192.168.30.1  # Gateway
   ping 8.8.8.8       # Internet

# ROUTER TIDAK DAPAT IP WAN
# ───────────────────────────────────────

# 1. Cek ether1 status:

    /interface ethernet print where name=ether1
    
#    Harus: status=link-ok

# 2. Tambah DHCP client jika kosong:

    /ip dhcp-client
    add interface=ether1 disabled=no

# 3. Verifikasi:

    /ip address print where interface=ether1
    
#    Harus muncul IP dari ISP

# DNS TIDAK RESOLVE
# ───────────────────────────────────────

# 1. Cek resolv.conf:

    cat /etc/resolv.conf
    
#     Harus ada: nameserver 127.0.0.1 atau 8.8.8.8

# 2. Test DNS publik:

    nslookup google.com 8.8.8.8

# 3. Jika Bind9 error, restart:

    sudo systemctl restart bind9

# ───────────────────────────────────────

# FIREWALL & ISOLASI
# ───────────────────────────────────────

# VLAN 20 MASIH BISA AKSES VLAN 10
# ───────────────────────────────────────

# 1. Cek urutan rules:

    /ip firewall filter print

# 2. Pastikan rule block aktif:

    /ip firewall filter set [find comment="Block Siswa ke Guru"] disabled=no

# 3. Pastikan allow established di paling atas:

    /ip firewall filter move [find comment="Allow Established"] 0

# 4. Test ulang:
   
#    Dari VLAN 20: ping 192.168.10.1 → HARUS TIMEOUT

# TIDAK BISA SSH/WINBOX DARI ADMIN PC
# ───────────────────────────────────────

# 1. Cek rule management access:

    /ip firewall filter print where dst-port=22,8291

# 2. Pastikan VLAN 10 di-allow:

    add chain=input src-address=192.168.10.0/24 \
        protocol=tcp dst-port=22,8291 action=accept

# 3. Test dari PC Admin:

    ssh admin@192.168.10.1

# LOG FIREWALL TIDAK MUNCUL
# ───────────────────────────────────────

# 1. Pastikan rule log disabled=no:

    /ip firewall filter set [find comment~"Log"] disabled=no

# 2. Test trigger log:
   
#     Dari VLAN 20: ping 192.168.10.1
   
# 3. Cek log:

    /log print where message~"FWD-DROP"

# ───────────────────────────────────────

# SERVER SERVICES
# ───────────────────────────────────────

# ZABBIX SERVER TIDAK START
# ───────────────────────────────────────

# 1. Cek log error:

    sudo tail -50 /var/log/zabbix/zabbix_server.log

# 2. Jika "users table empty", import schema ulang:

    sudo mysql -u root -p -e \
      "SET GLOBAL log_bin_trust_function_creators = 1;"
    
    sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | \
      sudo mysql -uzabbix -pZabbix@12345678 zabbix
    
    sudo mysql -u root -p -e \
      "SET GLOBAL log_bin_trust_function_creators = 0;"

# 3. Restart service:

    sudo systemctl restart zabbix-server

# APACHE HTTPS TIDAK ACCESSIBLE
# ───────────────────────────────────────

# 1. Cek SSL enabled:

    sudo apache2ctl -M | grep ssl
    
#    Harus: ssl_module

# 2. Cek default-ssl site enabled:

    ls /etc/apache2/sites-enabled/ | grep ssl
    
#    Harus: default-ssl.conf

# 3. Restart Apache:

    sudo systemctl restart apache2

# 4. Test:

    curl -k https://localhost

# BIND9 ZONE NOT LOADED
# ───────────────────────────────────────

# 1. Test syntax:

    sudo named-checkconf
    sudo named-checkzone lab-smk.xyz /etc/bind/db.lab-smk.xyz

# 2. Cek permission file zone:

    ls -la /etc/bind/db.lab-smk.xyz
    
#    Harus: root:bind, 640

# 3. Restart Bind9:

    sudo systemctl restart bind9

# ───────────────────────────────────────

# SWITCH VLAN
# ───────────────────────────────────────
 
# SWITCH TIDAK BISA DI-PING
# ───────────────────────────────────────

# 1. Cek bridge VLAN table - CPU access:

    /interface bridge vlan print
    
#    Pastikan: tagged=ether1,bridge1 untuk VLAN 30

# 2. Jika bridge1 tidak di tagged, tambah:

    /interface bridge vlan
    set [find vlan-ids=30] tagged=ether1,bridge1

# 3. Test ping dari Server:

    ping 192.168.30.2

# CLIENT TIDAK DAPAT DHCP
# ───────────────────────────────────────

# 1. Cek DHCP server aktif:

    /ip dhcp-server print
    
#    Harus: disabled=no untuk dhcp10 & dhcp20

# 2. Cek VLAN interface aktif:

    /interface vlan print
    
#    Harus: running untuk VLAN10 & VLAN20

# 3. Cek bridge port PVID:

    /interface bridge port print
    
#    Pastikan: pvid=10 untuk port 2, pvid=20 untuk port 3

# ───────────────────────────────────────

# CLOUD CHEATSHEET ACCESS
# ───────────────────────────────────────

# CURL/RAW.GITHUBUSERCONTENT.COM TIMEOUT
# ───────────────────────────────────────

# 1. Test koneksi dasar:

    ping -c 2 raw.githubusercontent.com

# 2. Test DNS:

    nslookup raw.githubusercontent.com

# 3. Jika DNS error, gunakan IP langsung:

    curl -s https://185.199.111.133/Galih-Arno/ukk-tjkt-cheatsheet/main/README.md | less

# 4. Fallback: gunakan file offline dari USB:

    cp /mnt/UKK-Cheatsheet.md ~/
    less ~/UKK-Cheatsheet.md

# SCRIPT CHEATSHEET.SH TIDAK JALAN
# ───────────────────────────────────────

# 1. Cek executable permission:

    ls -la ~/UKK-Tools/cheatsheet.sh
    
#    Harus: -rwxr-xr-x

# 2. Jika tidak executable:

    chmod +x ~/UKK-Tools/cheatsheet.sh

# 3. Cek alias di .bashrc:

    grep cheat ~/.bashrc
    
#    Harus: alias cheat='~/UKK-Tools/cheatsheet.sh'

# 4. Reload bash:

    source ~/.bashrc

# ───────────────────────────────────────

EMERGENCY CONTACTS
───────────────────────────────────────

Instructor Lab:   [Tanyakan Pada Gurumu]
Tech Support:     [ArnoLogika]

───────────────────────────────────────

💡 PRO TIP: Selalu screenshot error message sebelum 
fix. Ini bukti troubleshooting untuk dokumentasi UKK!

═══════════════════════════════════════════
