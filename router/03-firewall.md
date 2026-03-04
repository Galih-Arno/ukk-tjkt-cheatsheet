# 🔥 Router Config: Firewall Rules Lengkap

> **Target:** MikroTik RouterOS v7.x  
> ⚠️ **URUTAN RULES SANGAT PENTING!** MikroTik proses dari atas ke bawah.

---

## 🎯 Policy Keamanan (Sesuai Soal)

| Policy | Source | Destination | Action |
|--------|--------|-------------|--------|
| Isolasi Siswa | VLAN 20 (192.168.20.0/24) | VLAN 10 (192.168.10.0/24) | ❌ DROP |
| Server Boleh Akses Guru | VLAN 30 (192.168.30.0/24) | VLAN 10 (192.168.10.0/24) | ✅ ACCEPT |
| Management Access | VLAN 10 & 30 | Router (SSH/Winbox) | ✅ ACCEPT |
| Logging | Semua dropped traffic | - | 📝 LOG |

---

## 📋 Firewall Filter Rules (Copy-Paste Urutan Ini!)

```routeros
/ip firewall filter

# ========================================
# 1. ALLOW ESTABLISHED/RELATED (PALING ATAS - WAJIB!)
# ========================================
# Izinkan traffic balasan dari koneksi yang sudah dibuat
add chain=forward connection-state=established,related action=accept comment="Allow Established"
add chain=input connection-state=established,related action=accept comment="Allow Input Established"

# ========================================
# 2. ISOLASI VLAN (Soal 4a & 4b)
# ========================================
# Block VLAN 20 (Siswa) → VLAN 10 (Guru)
add chain=forward src-address=192.168.20.0/24 dst-address=192.168.10.0/24 action=drop comment="Block Siswa ke Guru"

# Allow VLAN 30 (Server) → VLAN 10 (Guru)
add chain=forward src-address=192.168.30.0/24 dst-address=192.168.10.0/24 action=accept comment="Allow Server ke Guru"

# ========================================
# 3. ANTI BRUTE FORCE (Soal 4c)
# ========================================
# Deteksi login gagal SSH/Winbox, tambah ke blacklist
add chain=input protocol=tcp dst-port=22,8291 connection-state=new src-address-list=!allowed_ips action=add-src-to-address-list address-list=blacklist timeout=1h comment="Anti Brute Force Detect"
# Drop IP yang ada di blacklist
add chain=input src-address-list=blacklist action=drop comment="Drop Blacklist"

# ========================================
# 4. LOGGING AKTIVITAS PENTING (Soal 4d)
# ========================================
# Log traffic yang di-drop (disabled=no WAJIB!)
add chain=forward action=log log-prefix="FWD-DROP " disabled=no comment="Log Forward Drop"
add chain=input action=log log-prefix="INPUT-DROP " disabled=no comment="Log Input Drop"

# ========================================
# 5. SECURE MANAGEMENT ACCESS (Soal 4e)
# ========================================
# Allow SSH/Winbox hanya dari VLAN 10 (Admin) dan VLAN 30 (Server)
add chain=input src-address=192.168.10.0/24 protocol=tcp dst-port=22,8291 action=accept comment="Allow VLAN 10 Mgmt"
add chain=input src-address=192.168.30.0/24 protocol=tcp dst-port=22,8291 action=accept comment="Allow VLAN 30 Mgmt"
# Drop management access dari VLAN lain (termasuk VLAN 20/Siswa)
add chain=input protocol=tcp dst-port=22,8291 action=drop comment="Drop Others Mgmt"

# ========================================
# 6. ALLOW SNMP dari Server (Untuk Zabbix)
# ========================================
add chain=input src-address=192.168.30.10/32 protocol=udp dst-port=161 action=accept comment="Allow SNMP from Zabbix"
```

---

## 🔍 Verifikasi Firewall

```routeros
# Cek urutan rules (harus sesuai urutan di atas!)
/ip firewall filter print

# Test isolasi VLAN:
# Dari PC VLAN 20: ping 192.168.10.1 → Harus TIMEOUT ✅
# Dari PC VLAN 30: ping 192.168.10.1 → Harus REPLY ✅

# Cek logging aktif:
/log print
# Harus ada entry dengan prefix "FWD-DROP" saat test isolasi
```

---

## ⚠️ Troubleshooting Firewall

| Masalah | Kemungkinan Penyebab | Solusi |
|---------|---------------------|--------|
| Internet mati setelah tambah firewall | Rule `allow established` tidak di paling atas | Pindah ke urutan 1 |
| VLAN 20 masih bisa akses VLAN 10 | Rule block tidak aktif atau urutan salah | Cek `disabled=no`, pastikan rule block sebelum rule allow umum |
| Tidak bisa SSH dari Admin PC | Rule management access salah subnet | Cek `src-address=192.168.10.0/24` sesuai IP Admin |
| Log tidak muncul | `disabled=yes` di rule log | Ubah jadi `disabled=no` |
| Zabbix tidak bisa monitoring SNMP | Rule SNMP tidak ada atau salah IP | Tambah rule allow SNMP dari 192.168.30.10 |

---

## 🧪 Test Isolasi (WAJIB untuk UKK)

```bash
# Dari PC VLAN 20 (Siswa):
ping 192.168.10.1
# ❌ HARUS: Request Timed Out (diblokir firewall)

# Dari PC VLAN 30 (Server):
ping 192.168.10.1
# ✅ HARUS: Reply (diizinkan firewall)

# Dari Router, cek log:
/log print where message~"FWD-DROP"
# Harus ada entry saat PC VLAN 20 ping ke VLAN 10
```

---

> ⚠️ **PENTING:** Jangan ubah urutan rules tanpa paham konsekuensinya. MikroTik proses rules dari atas ke bawah, rule pertama yang match akan dieksekusi.
