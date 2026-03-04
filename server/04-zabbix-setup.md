# 💻 Server Config: Zabbix 7.0 Monitoring

> **Target:** Ubuntu Server 24.04 LTS  
> **Backend:** MySQL  
> **Frontend:** Apache + PHP

---

## 1. Install Zabbix Repository & Packages

```bash
# Download & install Zabbix repo
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb

# Update package list
sudo apt update

# Install Zabbix packages + MySQL
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent default-mysql-server -y
```

---

## 2. Setup Database MySQL

```bash
# Start & enable MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Buat database & user untuk Zabbix
sudo mysql -u root -p <<EOF
DROP DATABASE IF EXISTS zabbix;
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
DROP USER IF EXISTS 'zabbix'@'localhost';
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'Zabbix@12345678';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF
```

---

## 3. Import Zabbix Schema (⚠️ TUNGGU 5-10 MENIT!)

```bash
# Set variable agar import bisa jalan
sudo mysql -u root -p -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# Import schema (proses ini bisa 5-10 menit, JANGAN INTERRUPT!)
echo "⏳ Importing Zabbix schema... (please wait)"
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -uzabbix -pZabbix@12345678 zabbix
echo "✅ Import completed!"

# Nonaktifkan variable
sudo mysql -u root -p -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Verifikasi import berhasil
mysql -uzabbix -pZabbix@12345678 zabbix -e "SELECT COUNT(*) as admin_count FROM users WHERE username='Admin';"
# Harus return: 1 (user Admin default)
```

---

## 4. Konfigurasi Zabbix Server

```bash
# Edit konfigurasi database connection
sudo nano /etc/zabbix/zabbix_server.conf
```

**Pastikan baris ini sesuai:**
```ini
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=Zabbix@12345678
DBPort=3306
```

---

## 5. Konfigurasi PHP Timezone

```bash
# Edit Apache config untuk Zabbix
sudo nano /etc/zabbix/apache.conf
```

**Tambahkan di dalam `<IfModule mod_php.c>`:**
```apache
php_value date.timezone Asia/Jakarta
```

---

## 6. Start & Enable Services

```bash
# Restart semua service terkait
sudo systemctl restart zabbix-server zabbix-agent apache2 mysql

# Enable agar start otomatis saat boot
sudo systemctl enable zabbix-server zabbix-agent apache2 mysql

# Verifikasi status
sudo systemctl status zabbix-server
# Harus: Active: active (running) ✅

sudo systemctl status apache2
# Harus: Active: active (running) ✅
```

---

## 7. Setup Web Frontend (Via Browser)

1.  **Buka browser di PC Admin:**
    ```
    http://192.168.30.10/zabbix
    ```
    atau
    ```
    http://monitor.lab-smk.xyz/zabbix
    ```

2.  **Zabbix Setup Wizard:**
    - Step 1-4: Next (default settings OK)
    - Step 5 (Database):
      ```
      Database type: MySQL
      Database host: localhost
      Database port: 3306
      Database name: zabbix
      User: zabbix
      Password: Zabbix@12345678
      ```
    - Step 6-7: Next → Finish

3.  **Login pertama:**
    ```
    Username: Admin  (huruf A BESAR, case-sensitive)
    Password: zabbix  (huruf kecil semua)
    ```

4.  **Segera ganti password Admin setelah login!**

---

## 8. Tambah Host ke Zabbix

### A. Host Router (via SNMP)
1.  **Navigation:** Data collection → Hosts → Create host
2.  **Tab Host:**
    ```
    Host name: Router-UKK
    Groups: Network devices
    Interfaces: IP=192.168.30.1, Connect to=SNMP, Community=zabbix-monitor
    ```
3.  **Tab Templates:** Link `Template Module Generic SNMP`
4.  **Klik Add**

### B. Host Server (via Zabbix Agent)
1.  **Create host lagi**
2.  **Tab Host:**
    ```
    Host name: Server-UKK
    Groups: Linux servers
    Interfaces: IP=192.168.30.10, Connect to=Agent
    ```
3.  **Tab Templates:** Link `Linux by Zabbix agent`
4.  **Klik Add**

---

## 9. Buat Graph CPU (WAJIB untuk UKK)

1.  **Klik host Server-UKK → Graphs → Create graph**
2.  **Tab Graph:**
    ```
    Name: CPU Usage
    Width: 900, Height: 200
    Graph type: Normal
    ✓ Show working time
    ✓ Show triggers
    ```
3.  **Tab Items → Add:**
    ```
    Item: CPU user time (cari "CPU")
    Draw style: Line
    Color: Biru
    ```
4.  **Klik Add → Save**

---

## 10. Verifikasi Zabbix

```bash
# Test agent lokal
zabbix_get -s localhost -k agent.ping
# Harus return: 1

# Cek port listening
sudo ss -tlnp | grep -E '10050|10051'
# Harus ada: zabbix_agentd (10050), zabbix_server (10051)

# Cek log jika ada error
sudo tail -20 /var/log/zabbix/zabbix_server.log
```

**Di Web Dashboard:**
- Host Router-UKK: Status ✅ Green
- Host Server-UKK: Status ✅ Green
- Graph CPU: Ada data bergerak

---

## ⚠️ Troubleshooting Zabbix

| Masalah | Solusi |
|---------|--------|
| `zabbix-server: cannot start` | Cek log: `sudo tail -50 /var/log/zabbix/zabbix_server.log` |
| `Access denied for user 'zabbix'` | Pastikan password di `/etc/zabbix/zabbix_server.conf` sama dengan MySQL |
| `Table 'zabbix.users' doesn't exist` | Import schema ulang (tunggu 5-10 menit!) |
| Host status merah (Not available) | Cek firewall: `sudo ufw allow 10050/tcp` (agent), `sudo ufw allow 161/udp` (SNMP) |
| Login gagal "Incorrect user" | Username: `Admin` (A besar), Password: `zabbix` (kecil) |

### Quick Fix Database Connection
```bash
# Test koneksi database manual
mysql -uzabbix -pZabbix@12345678 zabbix -e "SELECT 'Connection OK';"
# Jika gagal, reset password user zabbix:
sudo mysql -u root -p -e "ALTER USER 'zabbix'@'localhost' IDENTIFIED BY 'Zabbix@12345678'; FLUSH PRIVILEGES;"
```

---

> 📌 **Catatan:** Import schema adalah step paling lama. Jangan kill prosesnya. Jika error, drop database dan ulangi dari Step 2.
