# 💻 Server Config: Network Setup (Netplan)

> **Target:** Ubuntu Server 24.04 LTS  
> ⚠️ **GATEWAY HARUS 192.168.30.1** (bukan 192.168.10.1!)

---

## 1. Cek Nama Interface

```bash
# Lihat nama network interface
ip a

# Output contoh:
# 2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
#     inet 192.168.30.10/24 ...

# Catat nama interface (misal: enp0s25)
```

---

## 2. Edit Netplan Configuration

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

**Paste konten ini (sesuaikan nama interface):**

```yaml
network:
  version: 2
  ethernets:
    enp0s25:  # ⚠️ GANTI dengan nama interface Anda (cek 'ip a')
      dhcp4: no
      addresses: [192.168.30.10/24]
      routes:
        - to: default
          via: 192.168.30.1  # ⚠️ HARUS 30.1 (Gateway VLAN 30), BUKAN 10.1!
      nameservers:
        addresses: [127.0.0.1, 8.8.8.8]  # Lokal DNS first, fallback ke Google
```

### ⚠️ PENTING: Indentasi & Syntax
- Gunakan **SPASI** (bukan TAB) untuk indentasi
- YAML sensitif terhadap spasi: `addresses`, `routes`, `nameservers` harus sejajar
- Setelah edit, save: `Ctrl+O` → `Enter` → `Ctrl+X`

---

## 3. Apply Configuration

```bash
# Apply netplan
sudo netplan apply

# Jika error, debug dengan:
sudo netplan --debug apply
```

---

## 4. Verifikasi Network

```bash
# Cek IP address
ip a show enp0s25
# Harus muncul: inet 192.168.30.10/24

# Cek routing table
ip route show
# Harus muncul:
# default via 192.168.30.1 dev enp0s25
# 192.168.30.0/24 dev enp0s25 proto kernel scope link src 192.168.30.10

# Test ping gateway
ping 192.168.30.1
# Harus: Reply ✅

# Test ping internet
ping 8.8.8.8
# Harus: Reply ✅ (jika Router NAT sudah benar)
```

---

## 5. Test DNS Resolution

```bash
# Test DNS ke server lokal (Bind9)
nslookup www.lab-smk.xyz 127.0.0.1
# Harus return: Address: 192.168.30.10

# Test DNS ke Router (jika allow-remote-requests=yes)
nslookup google.com 192.168.30.1
# Harus return: IP Google
```

---

## ⚠️ Troubleshooting Netplan

| Masalah | Solusi |
|---------|--------|
| `Error in network definition` | Cek indentasi spasi, pastikan YAML valid |
| Gateway tidak reachable | Pastikan `via: 192.168.30.1` (bukan 10.1!) |
| Internet tidak jalan | Cek Router: `/ip route print` ada default route, NAT aktif |
| DNS timeout | Cek `/etc/resolv.conf`, pastikan nameserver terisi |

### Quick Fix Gateway Salah
```bash
# Jika terlanjur set gateway 192.168.10.1, perbaiki:
sudo nano /etc/netplan/00-installer-config.yaml
# Ubah: via: 192.168.10.1 → via: 192.168.30.1
sudo netplan apply
```

---

> 📌 **Catatan:** Netplan config hanya efektif setelah `sudo netplan apply`. Restart server tidak diperlukan.
