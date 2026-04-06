# ═══════════════════════════════════════════
# ROUTER CONFIG: DHCP, NAT & INTERNET
# ═══════════════════════════════════════════
# Target: MikroTik RouterOS v7.x
# WAN Interface: ether1 (ke ISP/Modem)
# ────────────────────────────────────────────────────────────

# 1. DHCP SERVER (VLAN 10 & 20)
# ───────────────────────────────────────
# Kongurasi DHCP SETUP
Dhcp setup untuk guru dan siswa, tinggal nexf next aja masa masih lupa

# Konfigurasi Network DHCP
/ip dhcp-server network
add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=192.168.30.10
add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=192.168.30.10
# ───────────────────────────────────────

# 3. NAT MASQUERADE (INTERNET SHARING)
# ───────────────────────────────────────
/ip firewall nat
add chain=srcnat out-interface=ether1 action=masquerade comment="NAT Internet"

# Cek:
/ip firewall nat print
# Harus ada rule dengan action=masquerade, out-interface=ether1
# ───────────────────────────────────────

# 4. DEFAULT ROUTE (GATEWAY INTERNET PENTING)
# ───────────────────────────────────────
/ip route
add dst-address=0.0.0.0/0 gateway=192.168.1.1 distance=1 comment="Default Internet"

# Cek:
/ip route print
# Harus ada: 0.0.0.0/0 via gateway ISP
# ───────────────────────────────────────

# 5. DNS ROUTER
# ───────────────────────────────────────
/ip dns
set servers=8.8.8.8,1.1.1.1 allow-remote-requests=yes 

# Tambahkan DNS Static untuk buka di browser dengan nama domain 
/ip dns ~> static ~> tambah ~> name=www.lab-smk.xyz address=192.168.30.10

Tambahkan lagi untuk monitor, lakukan hal yang sama
name=monitor.lab-smk.xyz address=192.168.30.10
───────────────────────────────────────

# 6. TEST INTERNET DARI ROUTER
# ───────────────────────────────────────
# Test ping ke IP publik:
/ping 8.8.8.8  
# Harus: Reply ✅

# Test DNS resolution:
/ping google.com
# Harus: Resolve + Reply ✅
# ───────────────────────────────────────
_______________________________________

# ⚠️ TROUBLESHOOTING
# ───────────────────────────────────────
# Problem: ether1 tidak dapat IP
# Solusi:  Cek kabel ke modem, /ip dhcp-client print status "bound"

# Problem: Client tidak dapat DHCP
# Solusi:  Cek /ip dhcp-server print disabled=no

# Problem: Ping 8.8.8.8 timeout
# Solusi:  Cek /ip route print ada default route, cek NAT rule

# Problem: DNS tidak resolve
# Solusi:  Cek /ip dns print servers terisi

═══════════════════════════════════════════
╭∩╮( •̀_•́ )╭∩╮ 🤟GG-Arno
