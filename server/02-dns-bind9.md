# ═══════════════════════════════════════════
# SERVER CONFIG: DNS SERVER (BIND9)
# ═══════════════════════════════════════════
# Target: Ubuntu Server 24.04 LTS
# Domain: lab-smk.xyz
# Hardening: Disable recursion untuk VLAN 20 (Siswa)
# ───────────────────────────────────────

# 1. INSTALL BIND9
# ───────────────────────────────────────
sudo apt update
sudo apt install bind9 -y
# ───────────────────────────────────────

# 2. KONFIGURASI ZONE FILE
# ───────────────────────────────────────
# Edit named.conf.local:
sudo nano /etc/bind/named.conf.local

# Tambahkan di akhir file:

    zone "lab-smk.xyz" {
        type master;
        file "/etc/bind/db.lab-smk.xyz";
    };

# Buat Zone File:
sudo cp /etc/bind/db.local /etc/bind/db.lab-smk.xyz
sudo nano /etc/bind/db.lab-smk.xyz

# Hapus semua isi, ganti dengan:

    @   IN  SOA     ns1.lab-smk.xyz. admin.lab-smk.xyz. (
                    1         ; Serial
                    3600      ; Refresh
                    1800      ; Retry
                    604800    ; Expire
                    86400 )   ; Negative Cache TTL
    ;
    @   IN  NS      ns1.lab-smk.xyz.
    @   IN  A       192.168.30.10
    ns1 IN  A       192.168.30.10
    www IN  A       192.168.30.10
    monitor IN A    192.168.30.10

# ───────────────────────────────────────

# 3. HARDENING: DISABLE RECURSION VLAN 20
# ───────────────────────────────────────
# Edit named.conf.options:
sudo nano /etc/bind/named.conf.options

# Cari blok options { ... }; tambahkan: allow-recursion {192.168.10.0/24;192.168.30.0/24;localhost;localnets;};
# COBA PERHATIKAN POSISI PENULISANNYA - karena file sudah ada penulisannya jangan di ubah
# ________________________________________
options {
# 	directory "/var/cache/bind"; // jangan dihapus
# 	// ... (komentar-komentar)
#    // CARI BAGIAN INI
    
# 	dnssec-validation auto; // jangan dihapus
# 	// ⚠️tambahkan ini saja disini👇👇👇👇👇
    allow-recursion {192.168.10.0/24;192.168.30.0/24;localhost;localnets;}; 
	
#    listen-on-v6 { any; }; // jangan dihapus
};

# ⚠️ VLAN 20 (192.168.20.0/24) TIDAK ditulis = DIBLOKIR
# ───────────────────────────────────────

# 4. TEST & RESTART BIND9
# ───────────────────────────────────────

# Test syntax konfigurasi:
sudo named-checkconf

# Test zone file:
sudo named-checkzone lab-smk.xyz /etc/bind/db.lab-smk.xyz
# Harus return: "OK"

# Restart service:
sudo systemctl restart bind9

# Cek status:
sudo systemctl status bind9
# Harus: Active: active (running) ✅
# ───────────────────────────────────────

# 5. VERIFIKASI DNS
# ───────────────────────────────────────
# Test query lokal:
nslookup www.lab-smk.xyz 127.0.0.1
# Harus return: Address: 192.168.30.10

nslookup monitor.lab-smk.xyz 127.0.0.1
# Harus return: Address: 192.168.30.10

# Test dari client VLAN 10/30 (harus resolve):
nslookup www.lab-smk.xyz 192.168.30.10

# Test dari client VLAN 20 (harus blocked external):
nslookup google.com 192.168.30.10
# Harus: REFUSED atau timeout (recursion disabled)
───────────────────────────────────────

# ⚠️ TROUBLESHOOTING
# ───────────────────────────────────────
# Problem: named-checkconf error
# Solusi:  Cek syntax: titik koma (;), kurung kurawal {}

# Problem: Zone not loaded
# Solusi:  Pastikan file /etc/bind/db.lab-smk.xyz ada
#          Cek permission: root:bind, 640

# Problem: nslookup timeout
# Solusi:  Cek firewall: sudo ufw allow 53/tcp & 53/udp

# Problem: Recursion masih jalan di VLAN 20
# Solusi:  Pastikan 192.168.20.0/24 TIDAK ada di allow-recursion
# ───────────────────────────────────────

# 📌 CATATAN: Serial number di zone file harus 
# di-increment setiap edit. Format: YYYYMMDDNN
╭∩╮( •̀_•́ )╭∩╮ 🤟GG-Arno
