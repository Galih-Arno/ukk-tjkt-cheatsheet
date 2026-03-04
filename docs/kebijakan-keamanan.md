# 📄 Kebijakan Keamanan Informasi
## SMK XYZ - Laboratorium Jaringan

> **Dokumen:** Kebijakan_Keamanan_NamaSiswa.docx  
> **Versi:** 1.0  
> **Tanggal:** 2026-03-04

---

## 1. Password Policy

- Minimal 8 karakter
- Kombinasi huruf besar, huruf kecil, angka, dan simbol
- Wajib diganti setiap 90 hari
- Dilarang menggunakan password default (admin, password, 123456)
- Password tidak boleh ditulis di tempat terbuka

---

## 2. Pembagian Akses VLAN

| VLAN | Nama | Akses Yang Diizinkan | Akses Yang Dilarang |
|------|------|---------------------|-------------------|
| 10 | Guru_Admin | Semua VLAN, Internet, Server | - |
| 20 | Siswa | Internet, Server (VLAN 30) | ❌ VLAN 10 (Guru) |
| 30 | Server | VLAN 10 (monitoring), Internet | ❌ Inisiasi ke VLAN 20 |

**Implementasi Teknis:**
- Firewall rule: Block `src=192.168.20.0/24` → `dst=192.168.10.0/24`
- Logging aktif untuk semua dropped traffic
- Management access (SSH/Winbox) hanya dari VLAN 10 & 30

---

## 3. Kebijakan Penggunaan Internet

- Hanya untuk keperluan pembelajaran dan tugas UKK
- Blokir akses ke situs judi, pornografi, malware via firewall
- Logging aktivitas browsing untuk audit keamanan
- Dilarang download file ilegal atau torrent

---

## 4. Kebijakan Backup Konfigurasi

### Router & Switch (MikroTik)
```routeros
# Export konfigurasi mingguan
/export file=backup-$(date +%Y%m%d)
# Simpan file .rsc ke external storage
```

### Server (Ubuntu)
```bash
# Backup database Zabbix
sudo mysqldump -uzabbix -p zabbix > ~/backup-zabbix-$(date +%Y%m%d).sql

# Backup konfigurasi Bind9 & Apache
sudo tar -czf ~/backup-services-$(date +%Y%m%d).tar.gz /etc/bind /etc/apache2

# Simpan backup ke external storage atau cloud
```

### Frekuensi Backup
- Harian: Database Zabbix
- Mingguan: Konfigurasi Router/Switch
- Bulanan: Full system backup

---

## 5. SOP Penanganan Insiden Keamanan

### A. Serangan Brute Force (Login Gagal Berulang)
1.  **Deteksi:** Cek log firewall dengan prefix "INPUT-DROP" atau "blacklist"
2.  **Tindakan:**
    - Blokir IP source di address-list blacklist
    - Reset password admin jika berhasil tembus
    - Enable account lockout policy
3.  **Dokumentasi:** Catat waktu, IP, user yang diserang, dan tindakan yang diambil

### B. Server Down / Service Tidak Responding
1.  **Deteksi:** Alert Zabbix atau laporan user
2.  **Tindakan:**
    - Cek konektivitas: `ping gateway`, `ping 8.8.8.8`
    - Cek status service: `systemctl status apache2/bind9/zabbix-server`
    - Restart service jika needed: `sudo systemctl restart <service>`
3.  **Eskalasi:** Jika >15 menit tidak selesai, lapor Kepala Lab

### C. VLAN Isolasi Terlanggar
1.  **Deteksi:** User VLAN 20 bisa akses resource VLAN 10
2.  **Tindakan:**
    - Cek urutan firewall rules: `allow established` harus paling atas
    - Verifikasi rule block aktif: `disabled=no`
    - Test ulang isolasi
3.  **Dokumentasi:** Catat root cause dan perbaikan

### D. Alur Eskalasi
```
Junior Admin (Siswa) 
       ↓
Senior Admin / Instructor Lab 
       ↓
Kepala Lab Jaringan 
       ↓
Vendor / ISP Support (jika eksternal issue)
```

---

## 6. Monitoring & Alerting

- Zabbix monitoring: CPU, Memory, Disk, Network traffic
- Alert via email jika:
  - CPU usage >90% selama 5 menit
  - Service down >2 menit
  - Disk usage >85%
- Review log firewall harian untuk deteksi anomaly

---

> **Disetujui Oleh:**  
> Nama: ___________________  
> Jabatan: Kepala Lab Jaringan  
> Tanggal: ___________________
