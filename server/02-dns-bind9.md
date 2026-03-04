# 💻 Server Config: DNS Server (Bind9)

> **Target:** Ubuntu Server 24.04 LTS  
> **Domain:** lab-smk.xyz  
> **Hardening:** Disable recursion untuk VLAN 20 (Siswa)

---

## 1. Install Bind9

```bash
sudo apt update
sudo apt install bind9 -y
```

---

## 2. Konfigurasi Zone File

### Edit named.conf.local
```bash
sudo nano /etc/bind/named.conf.local
```

**Tambahkan di akhir file:**
```
zone "lab-smk.xyz" {
    type master;
    file "/etc/bind/db.lab-smk.xyz";
};
```

### Buat Zone File
```bash
# Copy template
sudo cp /etc/bind/db.local /etc/bind/db.lab-smk.xyz

# Edit zone file
sudo nano /etc/bind/db.lab-smk.xyz
```

**Hapus semua isi, ganti dengan:**
```
@   IN  SOA     ns1.lab-smk.xyz. admin.lab-smk.xyz. (
                1         ; Serial
                3600      ; Refresh
                1800      ; Retry
                604800    ; Expire
                86400 )   ; Negative Cache TTL
;
@   IN  NS      ns1.lab-smk.xyz.
@   IN  A       192.168.30.10
ns1 IN  A       192.168.30.10
www IN  A       192.168.30.10
monitor IN A    192.168.30.10
```

---

## 3. Hardening: Disable Recursion untuk VLAN 20

```bash
sudo nano /etc/bind/named.conf.options
```

**Cari blok `options { ... };` dan tambahkan:**
```
allow-recursion {
    192.168.10.0/24;    // VLAN Guru/Admin - BOLEH recursive query
    192.168.30.0/24;    // VLAN Server - BOLEH recursive query
    localhost;
    localnets;
};
// ⚠️ VLAN 20 (192.168.20.0/24) TIDAK ditulis = DIBLOKIR
```

**Contoh lengkap options block:**
```
options {
    directory "/var/cache/bind";
    
    // ... setting lain ...
    
    allow-recursion {
        192.168.10.0/24;
        192.168.30.0/24;
        localhost;
        localnets;
    };
    
    dnssec-validation auto;
    listen-on-v6 { any; };
};
```

---

## 4. Test & Restart Bind9

```bash
# Test syntax konfigurasi
sudo named-checkconf

# Test zone file
sudo named-checkzone lab-smk.xyz /etc/bind/db.lab-smk.xyz
# Harus return: "OK"

# Restart service
sudo systemctl restart bind9

# Cek status
sudo systemctl status bind9
# Harus: Active: active (running) ✅
```

---

## 5. Verifikasi DNS

```bash
# Test query lokal
nslookup www.lab-smk.xyz 127.0.0.1
# Harus return: Address: 192.168.30.10

nslookup monitor.lab-smk.xyz 127.0.0.1
# Harus return: Address: 192.168.30.10

# Test dari client VLAN 10/30 (harus resolve)
nslookup www.lab-smk.xyz 192.168.30.10

# Test dari client VLAN 20 (harus blocked untuk external query)
nslookup google.com 192.168.30.10
# Harus: REFUSED atau timeout (karena recursion disabled)
```

---

## ⚠️ Troubleshooting Bind9

| Masalah | Solusi |
|---------|--------|
| `named-checkconf: error` | Cek syntax: titik koma `;`, kurung kurawal `{}` |
| Zone not loaded | Pastikan file `/etc/bind/db.lab-smk.xyz` ada dan permission benar |
| nslookup timeout | Cek firewall: `sudo ufw allow 53/tcp` dan `sudo ufw allow 53/udp` |
| Recursion masih jalan di VLAN 20 | Pastikan `192.168.20.0/24` TIDAK ada di `allow-recursion` |

### Quick Fix Permission
```bash
# Pastikan file zone bisa dibaca bind
sudo chown root:bind /etc/bind/db.lab-smk.xyz
sudo chmod 640 /etc/bind/db.lab-smk.xyz
sudo systemctl restart bind9
```

---

> 📌 **Catatan:** Serial number di zone file harus di-increment setiap kali edit zone. Format: YYYYMMDDNN (misal: 2026030401).
