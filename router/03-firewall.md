# ═══════════════════════════════════════════
# ROUTER CONFIG: FIREWALL RULES LENGKAP
# ═══════════════════════════════════════════

# Target: MikroTik RouterOS v7.x

# ⚠️ URUTAN RULES SANGAT PENTING!
#   MikroTik proses rules dari ATAS ke BAWAH

#───────────────────────────────────────

# POLICY KEAMANAN (SOAL UKK)
# ───────────────────────────────────────

# | Policy              | Source          | Destination   | Action |
# |---------------------|-----------------|---------------|--------|
# | Isolasi Siswa       | VLAN 20         | VLAN 10       | DROP   |
# | Server Boleh Guru   | VLAN 30         | VLAN 10       | ACCEPT |
# | Management Access   | VLAN 10 & 30    | Router        | ACCEPT |
# | Logging             | Semua dropped   | -             | LOG    |

# ───────────────────────────────────────

# FIREWALL FILTER RULES (COPY-PASTE URUTAN INI!)
# ───────────────────────────────────────

/ip firewall filter

# 1. ALLOW ESTABLISHED/RELATED (PALING ATAS - WAJIB!)
add chain=forward connection-state=established,related action=accept comment="Allow Established"
add chain=input connection-state=established,related action=accept comment="Allow Input Established"

# 2. ISOLASI VLAN (Soal 4a & 4b)
add chain=forward src-address=192.168.20.0/24 dst-address=192.168.10.0/24 action=drop comment="Block Siswa ke Guru"
add chain=forward src-address=192.168.30.0/24 dst-address=192.168.10.0/24 action=accept comment="Allow Server ke Guru"

# 3. ANTI BRUTE FORCE (Soal 4c)
add chain=input protocol=tcp dst-port=22,8291 connection-state=new src-address-list=!allowed_ips action=add-src-to-address-list address-list=blacklist timeout=1h comment="Anti Brute Force"
add chain=input src-address-list=blacklist action=drop comment="Drop Blacklist"

# 4. LOGGING AKTIVITAS PENTING (Soal 4d)
add chain=forward action=log log-prefix="FWD-DROP " disabled=no comment="Log Forward Drop"
add chain=input action=log log-prefix="INPUT-DROP " disabled=no comment="Log Input Drop"

# 5. SECURE MANAGEMENT ACCESS (Soal 4e)
add chain=input src-address=192.168.10.0/24 protocol=tcp dst-port=22,8291 action=accept comment="Allow VLAN 10 Mgmt"
add chain=input src-address=192.168.30.0/24 protocol=tcp dst-port=22,8291 action=accept comment="Allow VLAN 30 Mgmt"
add chain=input protocol=tcp dst-port=22,8291 action=drop comment="Drop Others Mgmt"

# 6. ALLOW SNMP DARI SERVER (Untuk Zabbix)
add chain=input src-address=192.168.30.10/32 protocol=udp dst-port=161 action=accept comment="Allow SNMP from Zabbix"

# ───────────────────────────────────────

# VERIFIKASI FIREWALL
# ───────────────────────────────────────

# Cek urutan rules:

    /ip firewall filter print

# Test isolasi VLAN:

#    Dari PC VLAN 20: ping 192.168.10.1 → HARUS TIMEOUT ✅
#    Dari PC VLAN 30: ping 192.168.10.1 → HARUS REPLY ✅

# Cek logging aktif:

    /log print

# Harus ada entry dengan prefix "FWD-DROP" saat test isolasi

# ───────────────────────────────────────

# TEST ISOLASI (WAJIB UNTUK UKK!)
# ───────────────────────────────────────

# Dari PC VLAN 20 (Siswa) - colok ke Switch Port 3:

    ping 192.168.10.1

# HARUS: Request Timed Out / Destination Host Unreachable
# ✅ Ini tandanya firewall isolasi BERHASIL!

# Dari PC VLAN 30 (Server):

    ping 192.168.10.1

# HARUS: Reply (diizinkan firewall)

# Dari Router, cek log:

    /log print where message~"FWD-DROP"

# Harus ada entry saat PC VLAN 20 ping ke VLAN 10

# ───────────────────────────────────────

# ⚠️ TROUBLESHOOTING
# ───────────────────────────────────────

# Problem: Internet mati setelah tambah firewall
# Solusi:  Rule "allow established" tidak di paling atas
#          Pindah ke urutan 1

# Problem: VLAN 20 masih bisa akses VLAN 10
# Solusi:  Cek rule block aktif (disabled=no)
#          Pastikan urutan benar (block sebelum allow umum)

# Problem: Tidak bisa SSH dari Admin PC
# Solusi:  Cek rule management access
#          Pastikan src-address=192.168.10.0/24 sesuai IP Admin

# Problem: Log tidak muncul
# Solusi:  Ubah disabled=no di rule log

# Problem: Zabbix tidak bisa monitoring SNMP
# Solusi:  Tambah rule allow SNMP dari 192.168.30.10

# ───────────────────────────────────────

# ⚠️ PENTING: JANGAN UBAH URUTAN RULES TANPA PAHAM!
#   Rule pertama yang MATCH akan dieksekusi.
#   Jika allow established tidak di atas, koneksi bisa putus!

═══════════════════════════════════════════
╭∩╮( •̀_•́ )╭∩╮ 🤟GG-Arno
