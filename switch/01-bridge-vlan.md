# 🔄 Switch Config: Bridge VLAN Filtering

> **Target:** MikroTik RouterOS v7.x  
> **Port Mapping:** ether1=Trunk, ether2-3=VLAN10, ether4-7=VLAN20, ether8=VLAN30

---

## 1. Reset & Bridge Setup

```routeros
# Reset konfigurasi bersih
/system reset-configuration no-defaults=yes skip-backup=yes
# Login ulang: admin / (kosong)

# Set identitas
/system identity set name="Switch-UKK"
/user password

# Buat Bridge dengan VLAN Filtering
/interface bridge
add name=bridge1 vlan-filtering=yes comment="Main Bridge"
```

---

## 2. Bridge Ports (Mapping Fisik ke VLAN)

```routeros
/interface bridge port
# ether1 = Trunk ke Router (hanya terima tagged VLAN)
add bridge=bridge1 interface=ether1 frame-types=admit-only-vlan-tagged comment="Trunk to Router"

# ether2-3 = Access VLAN 10 (Guru/Admin)
add bridge=bridge1 interface=ether2 pvid=10 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 10 - Port 2"
add bridge=bridge1 interface=ether3 pvid=10 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 10 - Port 3"

# ether4-7 = Access VLAN 20 (Siswa)
add bridge=bridge1 interface=ether4 pvid=20 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 20 - Port 4"
add bridge=bridge1 interface=ether5 pvid=20 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 20 - Port 5"
add bridge=bridge1 interface=ether6 pvid=20 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 20 - Port 6"
add bridge=bridge1 interface=ether7 pvid=20 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 20 - Port 7"

# ether8 = Access VLAN 30 (Server)
add bridge=bridge1 interface=ether8 pvid=30 frame-types=admit-only-untagged-and-priority-tagged comment="Access VLAN 30 - Server Port 8"
```

### Verifikasi
```routeros
/interface bridge port print
# Pastikan setiap port punya pvid yang sesuai
```

---

## 3. VLAN Interfaces (Untuk Management Switch)

```routeros
/interface vlan
add name=VLAN10-Switch vlan-id=10 interface=bridge1
add name=VLAN20-Switch vlan-id=20 interface=bridge1
add name=VLAN30-Switch vlan-id=30 interface=bridge1
```

---

## 4. Bridge VLAN Table (⚠️ PENTING: CPU Access)

```routeros
/interface bridge vlan
# VLAN 10: Trunk + CPU access (bridge1 di tagged)
add bridge=bridge1 tagged=ether1,bridge1 vlan-ids=10 comment="VLAN 10 Trunk"

# VLAN 20: Trunk + CPU access
add bridge=bridge1 tagged=ether1,bridge1 vlan-ids=20 comment="VLAN 20 Trunk"

# VLAN 30: Trunk + CPU access (untuk management IP)
add bridge=bridge1 tagged=ether1,bridge1 vlan-ids=30 comment="VLAN 30 Trunk + CPU"
```

> ⚠️ **PENTING:** `tagged=...,bridge1` mengizinkan CPU Switch sendiri masuk ke VLAN tersebut. Tanpa ini, management IP tidak akan reachable!

---

## 5. IP Management & SNMP

```routeros
# IP Management di VLAN 30 (Server network)
/ip address
add address=192.168.30.2/24 interface=VLAN30-Switch comment="Switch Mgmt"

# Route ke Router
/ip route
add gateway=192.168.30.1 distance=1 comment="To Router"

# DNS
/ip dns
set servers=192.168.30.10,8.8.8.8 allow-remote-requests=no

# SNMP untuk Zabbix
/snmp
set enabled=yes contact="Admin UKK" location="Lab SMK"
/snmp community
set [find name=public] disabled=yes
add name="zabbix-monitor" address=192.168.30.10/32 security=authorized read-access=yes
```

---

## 6. Verifikasi Switch

```routeros
# Cek bridge VLAN table
/interface bridge vlan print

# Test ping dari Switch ke Router
/ping 192.168.30.1 interface=VLAN30-Switch
# Harus: Reply ✅

# Test ping dari Server ke Switch
# Dari Server Ubuntu: ping 192.168.30.2 → Harus Reply ✅
```

---

## ⚠️ Troubleshooting Switch

| Masalah | Kemungkinan Penyebab | Solusi |
|---------|---------------------|--------|
| Switch tidak bisa di-ping | `bridge1` tidak di tagged di bridge vlan | Tambah `bridge1` di `tagged=ether1,bridge1` |
| Client tidak dapat IP DHCP | PVID port salah atau VLAN filtering error | Cek `/interface bridge port print` pvid sesuai |
| VLAN tidak terisolasi | Bridge VLAN table tidak lengkap | Pastikan semua VLAN IDs ada di `/interface bridge vlan` |
| Trunk tidak jalan | ether1 tidak admit-only-vlan-tagged | Cek frame-types setting di bridge port |

---

> 📌 **Catatan:** Setelah aktifkan `vlan-filtering=yes`, akses ke Switch mungkin putus jika konfigurasi CPU access salah. Selalu test via MAC Address Winbox jika perlu rollback.
