# ⚠️ Troubleshooting Quick Fix

> **Panduan Cepat Perbaikan Masalah Umum UKK**

---

## 🌐 Network & Internet

### Server Tidak Bisa Internet
```bash
# 1. Cek gateway di Netplan
cat /etc/netplan/00-installer-config.yaml
# Pastikan: via: 192.168.30.1 (BUKAN 10.1!)

# 2. Apply ulang
sudo netplan apply

# 3. Test
ping 192.168.30.1  # Gateway
ping 8.8.8.8       # Internet
```

### Router Tidak Dapat IP WAN
```routeros
# Cek ether1 status
/interface ethernet print where name=ether1
# Harus: status=link-ok

# Tambah DHCP client jika kosong
/ip dhcp-client
add interface=ether1 disabled=no

# Verifikasi
/ip address print where interface=ether1
# Harus muncul IP dari ISP
```

### DNS Tidak Resolve
```bash
# Cek resolv.conf
cat /etc/resolv.conf
# Harus ada: nameserver 127.0.0.1 atau 8.8.8.8

# Test DNS publik
nslookup google.com 8.8.8.8

# Jika Bind9 error, restart
sudo systemctl restart bind9
```

---

## 🔥 Firewall & Isolasi

### VLAN 20 Masih Bisa Akses VLAN 10
```routeros
# 1. Cek urutan rules (harus sesuai!)
/ip firewall filter print

# 2. Pastikan rule block aktif
/ip firewall filter set [find comment="Block Siswa ke Guru"] disabled=no

# 3. Pastikan allow established di paling atas
/ip firewall filter move [find comment="Allow Established"] 0

# 4. Test ulang
# Dari VLAN 20: ping 192.168.10.1 → Harus TIMEOUT
```

### Tidak Bisa SSH/Winbox dari Admin PC
```routeros
# Cek rule management access
/ip firewall filter print where dst-port=22,8291

# Pastikan VLAN 10 di-allow
add chain=input src-address=192.168.10.0/24 protocol=tcp dst-port=22,8291 action=accept

# Test dari PC Admin
ssh admin@192.168.10.1
```

### Log Firewall Tidak Muncul
```routeros
# Pastikan rule log disabled=no
/ip firewall filter set [find comment~"Log"] disabled=no

# Test trigger log
# Dari VLAN 20: ping 192.168.10.1
# Cek log:
/log print where message~"FWD-DROP"
```

---

## 💻 Server Services

### Zabbix Server Tidak Start
```bash
# 1. Cek log error
sudo tail -50 /var/log/zabbix/zabbix_server.log

# 2. Jika "users table empty", import schema ulang
sudo mysql -u root -p -e "SET GLOBAL log_bin_trust_function_creators = 1;"
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -uzabbix -pZabbix@12345678 zabbix
sudo mysql -u root -p -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# 3. Restart service
sudo systemctl restart zabbix-server
```

### Apache HTTPS Tidak Accessible
```bash
# 1. Cek SSL enabled
sudo apache2ctl -M | grep ssl
# Harus: ssl_module

# 2. Cek default-ssl site enabled
ls /etc/apache2/sites-enabled/ | grep ssl
# Harus: default-ssl.conf

# 3. Restart Apache
sudo systemctl restart apache2

# 4. Test
curl -k https://localhost
```

### Bind9 Zone Not Loaded
```bash
# 1. Test syntax
sudo named-checkconf
sudo named-checkzone lab-smk.xyz /etc/bind/db.lab-smk.xyz

# 2. Cek permission file zone
ls -la /etc/bind/db.lab-smk.xyz
# Harus: root:bind, 640

# 3. Restart Bind9
sudo systemctl restart bind9
```

---

## 🔄 Switch VLAN

### Switch Tidak Bisa Di-Ping
```routeros
# 1. Cek bridge VLAN table - CPU access
/interface bridge vlan print
# Pastikan: tagged=ether1,bridge1 untuk VLAN 30

# 2. Jika bridge1 tidak di tagged, tambah:
/interface bridge vlan
set [find vlan-ids=30] tagged=ether1,bridge1

# 3. Test ping dari Server
ping 192.168.30.2
```

### Client Tidak Dapat DHCP
```routeros
# 1. Cek DHCP server aktif
/ip dhcp-server print
# Harus: disabled=no untuk dhcp10 & dhcp20

# 2. Cek VLAN interface aktif
/interface vlan print
# Harus: running untuk VLAN10 & VLAN20

# 3. Cek bridge port PVID
/interface bridge port print
# Pastikan: pvid=10 untuk port 2-3, pvid=20 untuk port 4-7
```

---

## ☁️ Cloud Cheatsheet Access

### curl/raw.githubusercontent.com Timeout
```bash
# 1. Test koneksi dasar
ping -c 2 raw.githubusercontent.com

# 2. Test DNS
nslookup raw.githubusercontent.com

# 3. Jika DNS error, gunakan IP langsung
curl -s https://185.199.111.133/Galih-Arno/ukk-tjkt-cheatsheet/main/README.md | less

# 4. Fallback: gunakan file offline dari USB
cp /mnt/UKK-Cheatsheet.md ~/
less ~/UKK-Cheatsheet.md
```

### Script cheat.sh Tidak Jalan
```bash
# 1. Cek executable permission
ls -la ~/UKK-Tools/cheat.sh
# Harus: -rwxr-xr-x

# 2. Jika tidak executable:
chmod +x ~/UKK-Tools/cheat.sh

# 3. Cek alias di .bashrc
grep cheat ~/.bashrc
# Harus: alias cheat='~/UKK-Tools/cheat.sh'

# 4. Reload bash
source ~/.bashrc
```

---

## 🆘 Emergency Contacts

```
📞 Instructor Lab: [Nama/No HP]
📞 Tech Support: [Nama/No HP]  
📞 ISP Support: [No HP/Email]
🌐 GitHub Status: https://www.githubstatus.com/
```

---

> 💡 **Pro Tip:** Selalu screenshot error message sebelum fix. Ini bukti troubleshooting untuk dokumentasi UKK!
