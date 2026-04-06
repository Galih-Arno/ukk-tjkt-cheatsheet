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

SETTING ETHER 3 DI ROUTER2 (menambahkan firewall security)
- ip firewall – filter rules (+) – chain(input) – connection state(estabilised,related) 
action(accept)

- ip firewall – filter rules (+) – chain(forward) – connection state(estabilised,related) 
action(accept)

- chain(input) – connection state(invalid) action(drop)
- chain(forward) – connection state(invalid) action(drop)
  
- Chain(forward) - src-address(192.168.20.0/24) – dst-address(192.168.10.0/24) action 
(drop) – comment (block vlan 20 to vlan10)
- Chain(forward) - src-address(192.168.30.0/24) – dst-address(192.168.10.0/24) action 
(accept) – comment (allow vlan 30 to vlan10)

- Chain (input) - src-address(192.168.10.0/24) - protocol(tcp) - dst-port(22,8291) -
action(accept)
- Chain (input) - src-address(192.168.30.0/24) - protocol(tcp) - dst-port(22,8291) -
action(accept)
- Chain (input)) - protocol(tcp) - dst-port(22,8291) -action(drop)
- Chain (input)- protocol(tcp) - dst-port(22,8291)-src-address-list(bf_blacklist) – action (drop)
  
- Chain (input)- protocol(tcp) - dst-port(22,8291)-connection-state (new) – action (add-src-to-
addres-list- addres-list(bf_stage1) – addres-list-timeout(00:01:00)

- Chain (input)- protocol(tcp) - dst-port(22,8291)-src-address-list(bf_stage1) – action (add-src-
to-addres-list- addres-list(bf_stage2) – addres-list-timeout(00:01:00)

- Chain (input)- protocol(tcp) - dst-port(22,8291)-src-address-list(bf_stage2) – action (add-src-
to-addres-list- addres-list(bf_blacklist) – addres-list-timeout(24:00:00



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
