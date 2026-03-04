# 🧪 Testing & Verification Commands

> **Target:** Semua komponen UKK  
> **Gunakan:** Jalankan berurutan, screenshot hasil untuk dokumentasi

---

## 📋 Checklist Testing Berurutan

### ✅ A. Konektivitas Dasar (Dari Server Ubuntu)

```bash
# 1. Ping Gateway Router (VLAN 30)
ping -c 4 192.168.30.1
# ✅ HARUS: 4 packets transmitted, 4 received, 0% loss

# 2. Ping Switch Management
ping -c 4 192.168.30.2
# ✅ HARUS: Reply

# 3. Ping Internet (IP Publik)
ping -c 4 8.8.8.8
# ✅ HARUS: Reply (jika Router NAT/Route sudah benar)

# 4. Test DNS Resolution
nslookup google.com
# ✅ HARUS: Resolve ke IP Google

nslookup www.lab-smk.xyz
# ✅ HARUS: Address: 192.168.30.10
```

---

### ✅ B. Isolasi VLAN (SOAL 4a & 4b - WAJIB!)

```bash
# Dari PC VLAN 20 (Siswa) - colok ke Switch Port 4-7:
ping -c 4 192.168.10.1
# ❌ HARUS: Request Timed Out / Destination Host Unreachable
# ✅ Ini tandanya firewall isolasi BERHASIL!

# Dari PC VLAN 30 (Server):
ping -c 4 192.168.10.1
# ✅ HARUS: Reply (diizinkan firewall)

# Verifikasi di Router:
# Winbox → Log → Harus ada entry "FWD-DROP" saat VLAN 20 ping ke VLAN 10
```

---

### ✅ C. DNS Server (Bind9)

```bash
# Test query lokal
nslookup www.lab-smk.xyz 127.0.0.1
# ✅ HARUS: Address: 192.168.30.10

nslookup monitor.lab-smk.xyz 127.0.0.1
# ✅ HARUS: Address: 192.168.30.10

# Test recursion blocking untuk VLAN 20:
# Dari PC VLAN 20:
nslookup google.com 192.168.30.10
# ❌ HARUS: REFUSED atau timeout (karena recursion disabled)
```

---

### ✅ D. Web HTTPS

```bash
# Test HTTPS lokal
curl -k https://localhost | head -5
# ✅ HARUS: Return HTML Apache

# Test dari browser PC Admin:
# Buka: https://www.lab-smk.xyz
# ✅ HARUS: Apache default page + icon gembok (warning self-signed = normal)

# Test DNS + HTTPS
nslookup www.lab-smk.xyz
curl -k https://www.lab-smk.xyz | grep -i "lab smk"
# ✅ HARUS: Return konten halaman
```

---

### ✅ E. Zabbix Monitoring

```bash
# Test agent lokal
zabbix_get -s localhost -k agent.ping
# ✅ HARUS: Return: 1

# Cek service status
sudo systemctl status zabbix-server zabbix-agent apache2
# ✅ HARUS: Active: active (running) untuk semua

# Cek port listening
sudo ss -tlnp | grep -E '10050|10051|80'
# ✅ HARUS: zabbix_agentd (10050), zabbix_server (10051), apache2 (80)
```

**Di Web Dashboard (http://192.168.30.10/zabbix):**
- ✅ Host Router-UKK: Status Green (tersedia)
- ✅ Host Server-UKK: Status Green (tersedia)
- ✅ Graph CPU Usage: Ada data bergerak
- ✅ Latest data: Ada update dalam 5 menit terakhir

---

### ✅ F. SNMP Test

```bash
# Install snmp tools (jika belum)
sudo apt install snmp -y

# Test SNMP ke Router dari Server
snmpwalk -v2c -c zabbix-monitor 192.168.30.1 system
# ✅ HARUS: Return system info MikroTik (sysDescr, sysUpTime, dll)

# Test SNMP ke Switch
snmpwalk -v2c -c zabbix-monitor 192.168.30.2 system
# ✅ HARUS: Return system info MikroTik
```

---

### ✅ G. Logging Firewall

```bash
# Di Router (via Winbox/Terminal):
/log print where message~"FWD-DROP"
# ✅ HARUS: Ada entry saat testing isolasi VLAN 20 → 10

# Di Server, cek UFW status
sudo ufw status verbose
# ✅ HARUS: Status: active, dengan rules 22,80,443,10050,53 allowed
```

---

## 📸 Screenshot Wajib untuk Dokumentasi

| No | Screenshot | Cara Ambil |
|----|-----------|-----------|
| 1 | Topologi Fisik | Foto kabel antar perangkat |
| 2 | VLAN Config Router | `/interface vlan print` di Terminal |
| 3 | Firewall Rules | `/ip firewall filter print` |
| 4 | Switch Port Mapping | `/interface bridge port print` |
| 5 | DNS Test | `nslookup www.lab-smk.xyz` output |
| 6 | HTTPS Web | Browser: https://www.lab-smk.xyz (tampil + gembok) |
| 7 | Zabbix Dashboard | Host Router & Server status Green + Graph CPU |
| 8 | Isolasi VLAN Test | Ping VLAN 20→10 (Timeout) vs 30→10 (Reply) |
| 9 | Firewall Log | Winbox Log dengan entry "FWD-DROP" |
| 10 | SNMP Test | `snmpwalk` output dari Server |

---

## ⚠️ Quick Troubleshooting

```bash
# Internet tidak jalan di Server?
ip route show  # Pastikan: default via 192.168.30.1
ping 192.168.30.1  # Test gateway
ping 8.8.8.8  # Test internet

# DNS tidak resolve?
cat /etc/resolv.conf  # Pastikan nameserver terisi
nslookup google.com 8.8.8.8  # Test DNS publik

# Zabbix host merah?
sudo ufw allow 10050/tcp  # Allow agent port
sudo systemctl restart zabbix-agent

# VLAN isolasi tidak bekerja?
/ip firewall filter print  # Cek urutan rules: allow established harus paling atas
```

---

> 📌 **Tips:** Jalankan testing berurutan dan screenshot tiap hasil. Jika ada error, catat solusinya untuk dokumentasi troubleshooting.
