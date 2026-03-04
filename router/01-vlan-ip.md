═══════════════════════════════════════════
ROUTER CONFIG: VLAN & IP ADDRESS
═══════════════════════════════════════════

Target: MikroTik RouterOS v7.x
Trunk Interface: ether2 → Switch

───────────────────────────────────────

1. Reset & Persiapan
_______________________________________

# Reset konfigurasi bersih
/system reset-configuration no-defaults=yes skip-backup=yes

# Login ulang: admin / (kosong)
# Set identitas

/system identity set name="Router-UKK"
_______________________________________

2. VLAN INTERFACE
───────────────────────────────────────

/interface vlan
add name=VLAN10 vlan-id=10 interface=ether2 comment="Guru_Admin"
add name=VLAN20 vlan-id=20 interface=ether2 comment="Siswa"
add name=VLAN30 vlan-id=30 interface=ether2 comment="Server"

# Cek:

    /interface vlan print

# Harus muncul: VLAN10, VLAN20, VLAN30 dengan interface=ether2

───────────────────────────────────────

2. IP ADDRESS GATEWAY
───────────────────────────────────────

/ip address
add address=192.168.10.1/24 interface=VLAN10 comment="Gateway Guru"
add address=192.168.20.1/24 interface=VLAN20 comment="Gateway Siswa"
add address=192.168.30.1/24 interface=VLAN30 comment="Gateway Server"

# Cek:

    /ip address print

# Harus muncul 3 entry dengan interface VLAN10/20/30

───────────────────────────────────────

3. TEST KONEKTIVITAS
───────────────────────────────────────

# Ping gateway sendiri:

    /ping 192.168.10.1
    /ping 192.168.20.1
    /ping 192.168.30.1

# Harus: Reply ✅

# Ping ke Switch (jika sudah dikonfigurasi):

    /ping 192.168.30.2

# Harus: Reply ✅

───────────────────────────────────────

⚠️ TROUBLESHOOTING
───────────────────────────────────────

Problem: VLAN tidak muncul di print
Solusi:  Pastikan interface=ether2 dan ether2 aktif

Problem: Ping gateway timeout
Solusi:  Cek /ip address print - pastikan IP terassign

Problem: Tidak bisa ping dari client
Solusi:  Pastikan client dapat IP DHCP atau set static

╭∩╮( •̀_•́ )╭∩╮ 🤟GG-Arno
═════════════════════════════════════════
