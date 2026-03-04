# 🎯 Router Config: DHCP, NAT & Internet

> **Target:** MikroTik RouterOS v7.x  
> **WAN Interface:** ether1 (ke ISP/Modem)

---

## 1. DHCP Client (WAN - ether1)

```routeros
# Dapatkan IP otomatis dari ISP/Modem
/ip dhcp-client
add interface=ether1 disabled=no comment="WAN-ISP"

# Verifikasi dapat IP
/ip address print where interface=ether1
# Harus muncul IP seperti: 192.168.1.x/24
```

---

## 2. DHCP Server (VLAN 10 & 20)

```routeros
# Buat IP Pool
/ip pool
add name=Pool10 ranges=192.168.10.2-192.168.10.254
add name=Pool20 ranges=192.168.20.2-192.168.20.254

# Aktifkan DHCP Server
/ip dhcp-server
add address-pool=Pool10 interface=VLAN10 name=dhcp10 disabled=no
add address-pool=Pool20 interface=VLAN20 name=dhcp20 disabled=no

# Konfigurasi Network DHCP
/ip dhcp-server network
add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=192.168.30.10
add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=192.168.30.10
```

### Verifikasi
```routeros
/ip dhcp-server print
/ip dhcp-server network print
# Client di VLAN 10/20 harus dapat IP otomatis
```

---

## 3. NAT Masquerade (Internet Sharing)

```routeros
/ip firewall nat
add chain=srcnat out-interface=ether1 action=masquerade comment="NAT Internet"
```

### Verifikasi
```routeros
/ip firewall nat print
# Harus ada rule dengan action=masquerade, out-interface=ether1
```

---

## 4. Default Route (Gateway Internet)

```routeros
# Route semua traffic unknown ke ether1 (ISP)
/ip route
add dst-address=0.0.0.0/0 gateway=ether1 distance=1 comment="Default Internet"
```

### Verifikasi
```routeros
/ip route print
# Harus ada: 0.0.0.0/0 via gateway ISP
```

---

## 5. DNS Router

```routeros
/ip dns
set servers=8.8.8.8,1.1.1.1 allow-remote-requests=yes
```

### Test DNS dari Router
```routeros
/tool dns-query name=google.com server=8.8.8.8
# Harus return: status=completed + IP address
```

---

## 6. Test Internet dari Router

```routeros
# Test ping ke IP publik
/ping 8.8.8.8 interface=ether1
# Harus: Reply ✅

# Test DNS resolution
/ping google.com interface=ether1
# Harus: Resolve + Reply ✅
```

---

## ⚠️ Troubleshooting

| Masalah | Solusi |
|---------|--------|
| ether1 tidak dapat IP | Cek kabel ke modem, `/ip dhcp-client print` status harus "bound" |
| Client tidak dapat DHCP | Cek `/ip dhcp-server print` disabled=no, cek VLAN interface aktif |
| Ping 8.8.8.8 timeout | Cek `/ip route print` ada default route, cek NAT rule |
| DNS tidak resolve | Cek `/ip dns print` servers terisi, allow-remote-requests=yes |

---

> 📌 **Catatan:** NAT hanya bekerja jika ada default route. Pastikan `/ip route` ada entry `0.0.0.0/0`.
