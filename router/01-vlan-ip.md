# 🎯 Router Config: VLAN & IP Address

> **Target:** MikroTik RouterOS v7.x

---

## VLAN Interface (Trunk di ether2)

```routeros
/interface vlan
add name=VLAN10 vlan-id=10 interface=ether2 comment="Guru_Admin"
add name=VLAN20 vlan-id=20 interface=ether2 comment="Siswa"
add name=VLAN30 vlan-id=30 interface=ether2 comment="Server"
```

## IP Address Gateway

```routeros
/ip address
add address=192.168.10.1/24 interface=VLAN10 comment="Gateway Guru"
add address=192.168.20.1/24 interface=VLAN20 comment="Gateway Siswa"
add address=192.168.30.1/24 interface=VLAN30 comment="Gateway Server"
```

## Verifikasi

```routeros
# Cek VLAN aktif
/interface vlan print

# Cek IP address
/ip address print

# Test ping antar VLAN (dari router)
/ping 192.168.10.1
/ping 192.168.20.1
/ping 192.168.30.1
```

---

> ⚠️ **Note:** Pastikan ether2 terhubung ke Switch via kabel trunk.
