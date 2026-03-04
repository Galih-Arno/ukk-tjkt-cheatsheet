# ═══════════════════════════════════════════
# SWITCH CONFIG: BRIDGE VLAN FILTERING
# ═══════════════════════════════════════════
# Target: MikroTik RouterOS v7.x
# Port Mapping:
#  • ether1 = Trunk ke Router
#  • ether2 = Access VLAN 10 (Guru/Admin)
#  • ether3 = Access VLAN 20 (Siswa)
#  • ether4 = Access VLAN 30 (Server)
# ───────────────────────────────────────

# 1. RESET & BRIDGE SETUP
# ───────────────────────────────────────
# Reset konfigurasi bersih:
/system reset-configuration no-defaults=yes skip-backup=yes

# Login ulang: admin / (kosong)

# Set identitas:
/system identity set name="Switch-UKK"

# Buat Bridge dengan VLAN Filtering:
/interface bridge
add name=bridge1 vlan-filtering=yes comment="Main Bridge"
# ───────────────────────────────────────

# 2. BRIDGE PORTS (MAPPING FISIK KE VLAN)
# ───────────────────────────────────────
/interface bridge port

# ether1 = Trunk ke Router
add bridge=bridge1 interface=ether1 frame-types=admit-only-vlan-tagged comment="Trunk to Router"

# ether2 = Access VLAN 10
add bridge=bridge1 interface=ether2 pvid=10 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 10 - Port 2"

# ether3 = Access VLAN 20
add bridge=bridge1 interface=ether3 pvid=20 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 20 - Port 3"

# ether4 = Access VLAN 30 (Server)
add bridge=bridge1 interface=ether4 pvid=30 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 30 - Server Port 4"

# Verifikasi:
/interface bridge port print

# Pastikan setiap port punya pvid yang sesuai
# ───────────────────────────────────────

# 3. VLAN INTERFACES (UNTUK MANAGEMENT)
# ───────────────────────────────────────
/interface vlan
add name=VLAN10-Switch vlan-id=10 interface=bridge1
add name=VLAN20-Switch vlan-id=20 interface=bridge1
add name=VLAN30-Switch vlan-id=30 interface=bridge1
# ───────────────────────────────────────

# 4. BRIDGE VLAN TABLE (⚠️ PENTING: CPU ACCESS!)
# ───────────────────────────────────────
/interface bridge vlan

# VLAN 10: Trunk + CPU access (bridge1 di tagged)
add bridge=bridge1 tagged=ether1,bridge1 vlan-ids=10 comment="VLAN 10 Trunk"

# VLAN 20: Trunk + CPU access
add bridge=bridge1 tagged=ether1,bridge1 vlan-ids=20 comment="VLAN 20 Trunk"

# VLAN 30: Trunk + CPU access (untuk management IP)
add bridge=bridge1 tagged=ether1,bridge1 vlan-ids=30 comment="VLAN 30 Trunk + CPU"

# ⚠️ PENTING: tagged=...,bridge1 mengizinkan CPU Switch 
#    sendiri masuk ke VLAN tersebut. Tanpa ini, 
#    management IP tidak akan reachable!
# ───────────────────────────────────────

# 5. IP MANAGEMENT & SNMP
# ───────────────────────────────────────

# IP Management di VLAN 30:
/ip address
add address=192.168.30.2/24 interface=VLAN30-Switch comment="Switch Mgmt"

# Route ke Router:
/ip route
add gateway=192.168.30.1 distance=1 comment="To Router"

# DNS:
/ip dns
set servers=192.168.30.10,8.8.8.8 allow-remote-requests=no

# SNMP untuk Zabbix:
/snmp
set enabled=yes contact="Admin UKK" location="Lab SMK"

/snmp community
set [find name=public] disabled=yes
add name="zabbix-monitor" address=192.168.30.10/32 security=authorized read-access=yes
# ───────────────────────────────────────

# 6. VERIFIKASI SWITCH
# ───────────────────────────────────────
# Cek bridge VLAN table:
/interface bridge vlan print

# Test ping dari Switch ke Router:
/ping 192.168.30.1 interface=VLAN30-Switch
# Harus: Reply ✅

# Test ping dari Server ke Switch:
# Dari Server Ubuntu: ping 192.168.30.2
# Harus: Reply ✅
# ───────────────────────────────────────

# ⚠️ TROUBLESHOOTING
# ───────────────────────────────────────
# Problem: Switch tidak bisa di-ping
# Solusi:  bridge1 tidak di tagged di bridge vlan
#          Tambah bridge1 di tagged=ether1,bridge1

# Problem: Client tidak dapat IP DHCP
# Solusi:  Cek PVID port salah atau VLAN filtering error
#          Cek /interface bridge port print pvid sesuai

# Problem: VLAN tidak terisolasi
# Solusi:  Bridge VLAN table tidak lengkap
#          Pastikan semua VLAN IDs ada

# Problem: Trunk tidak jalan
# Solusi:  ether1 tidak admit-only-vlan-tagged
#          Cek frame-types setting di bridge port
# ───────────────────────────────────────

# ⚠️ CATATAN: Setelah aktifkan vlan-filtering=yes, 
# akses ke Switch mungkin putus jika konfigurasi 
# CPU access salah. Selalu test via MAC Address 
# Winbox jika perlu rollback.

╭∩╮( •̀_•́ )╭∩╮ 🤟GG-Arno
