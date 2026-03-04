═══════════════════════════════════════════
KEBIJAKAN KEAMANAN INFORMASI
SMK XYZ - LABORATORIUM JARINGAN
═══════════════════════════════════════════

Dokumen: Kebijakan_Keamanan_NamaSiswa.docx
Versi: 1.0
Tanggal: 2026-03-04

───────────────────────────────────────

1. PASSWORD POLICY
───────────────────────────────────────

• Minimal 8 karakter
• Kombinasi huruf besar, huruf kecil, angka, simbol
• Wajib diganti setiap 90 hari
• Dilarang menggunakan password default 
  (admin, password, 123456)
• Password tidak boleh ditulis di tempat terbuka

───────────────────────────────────────

2. PEMBAGIAN AKSES VLAN
───────────────────────────────────────

| VLAN | Nama        | Akses Diizinkan        | Akses Dilarang      |
|------|-------------|------------------------|---------------------|
| 10   | Guru_Admin  | Semua VLAN, Internet   | -                   |
| 20   | Siswa       | Internet, Server       | VLAN 10 (Guru)      |
| 30   | Server      | VLAN 10 (monitoring)   | Inisiasi ke VLAN 20 |

Implementasi Teknis:
  • Firewall rule: Block src=192.168.20.0/24 → dst=192.168.10.0/24
  • Logging aktif untuk semua dropped traffic
  • Management access (SSH/Winbox) hanya dari VLAN 10 & 30

───────────────────────────────────────

3. KEBIJAKAN PENGGUNAAN INTERNET
───────────────────────────────────────

• Hanya untuk keperluan pembelajaran dan tugas UKK
• Blokir akses ke situs judi, pornografi, malware via firewall
• Logging aktivitas browsing untuk audit keamanan
• Dilarang download file ilegal atau torrent

───────────────────────────────────────

4. KEBIJAKAN BACKUP KONFIGURASI
───────────────────────────────────────

A. Router & Switch (MikroTik)
───────────────────────────────────────

Export konfigurasi mingguan:

    /export file=backup-$(date +%Y%m%d)

Simpan file .rsc ke external storage

B. Server (Ubuntu)
───────────────────────────────────────

Backup database Zabbix:

    sudo mysqldump -uzabbix -p zabbix > \
      ~/backup-zabbix-$(date +%Y%m%d).sql

Backup konfigurasi Bind9 & Apache:

    sudo tar -czf ~/backup-services-$(date +%Y%m%d).tar.gz \
      /etc/bind /etc/apache2

Simpan backup ke external storage atau cloud

C. Frekuensi Backup
───────────────────────────────────────

  • Harian: Database Zabbix
  • Mingguan: Konfigurasi Router/Switch
  • Bulanan: Full system backup

───────────────────────────────────────

5. SOP PENANGANAN INSIDEN KEAMANAN
───────────────────────────────────────

A. Serangan Brute Force (Login Gagal Berulang)
───────────────────────────────────────

Deteksi:
  Cek log firewall dengan prefix "INPUT-DROP" atau "blacklist"

Tindakan:
  1. Blokir IP source di address-list blacklist
  2. Reset password admin jika berhasil tembus
  3. Enable account lockout policy

Dokumentasi:
  Catat waktu, IP, user yang diserang, tindakan diambil

B. Server Down / Service Tidak Responding
───────────────────────────────────────

Deteksi:
  Alert Zabbix atau laporan user

Tindakan:
  1. Cek konektivitas: ping gateway, ping 8.8.8.8
  2. Cek status service: systemctl status apache2/bind9/zabbix-server
  3. Restart service jika needed

Eskalasi:
  Jika >15 menit tidak selesai, lapor Kepala Lab

C. VLAN Isolasi Terlanggar
───────────────────────────────────────

Deteksi:
  User VLAN 20 bisa akses resource VLAN 10

Tindakan:
  1. Cek urutan firewall rules: allow established harus paling atas
  2. Verifikasi rule block aktif: disabled=no
  3. Test ulang isolasi

Dokumentasi:
  Catat root cause dan perbaikan

D. Alur Eskalasi
───────────────────────────────────────

Junior Admin (Siswa) 
       ↓
Senior Admin / Instructor Lab 
       ↓
Kepala Lab Jaringan 
       ↓
Vendor / ISP Support (jika eksternal issue)

───────────────────────────────────────

6. MONITORING & ALERTING
───────────────────────────────────────

• Zabbix monitoring: CPU, Memory, Disk, Network traffic
• Alert via email jika:
    - CPU usage >90% selama 5 menit
    - Service down >2 menit
    - Disk usage >85%
• Review log firewall harian untuk deteksi anomaly

───────────────────────────────────────

DISAPPROVED BY:

Nama: ___________________
Jabatan: Kepala Lab Jaringan
Tanggal: ___________________

═══════════════════════════════════════════
