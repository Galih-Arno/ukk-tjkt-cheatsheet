═══════════════════════════════════════════
SERVER CONFIG: WEB SERVER + HTTPS
═══════════════════════════════════════════

Target: Ubuntu Server 24.04 LTS
Domain: www.lab-smk.xyz
Certificate: Self-Signed (untuk UKK)

───────────────────────────────────────

1. INSTALL APACHE2
───────────────────────────────────────

    sudo apt update
    sudo apt install apache2 -y

Test default page:

    curl http://localhost

Harus return HTML Apache default

───────────────────────────────────────

2. ENABLE SSL MODULE
───────────────────────────────────────

    sudo a2enmod ssl
    sudo systemctl restart apache2

───────────────────────────────────────

3. BUAT SELF-SIGNED CERTIFICATE
───────────────────────────────────────

Buat directory SSL:

    sudo mkdir -p /etc/apache2/ssl

Generate certificate (valid 365 hari):

    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/apache2/ssl/apache.key \
      -out /etc/apache2/ssl/apache.crt \
      -subj "/C=ID/ST=Indonesia/L=SMK/O=Lab/CN=www.lab-smk.xyz"

Penjelasan Parameter:
  • -x509      : Output format certificate
  • -nodes     : No password untuk private key
  • -days 365  : Validitas 1 tahun
  • -newkey    : RSA key 2048-bit
  • -subj      : Subject DN otomatis

───────────────────────────────────────

4. AKTIFKAN SSL SITE
───────────────────────────────────────

Enable default-ssl configuration:

    sudo a2ensite default-ssl

Restart Apache:

    sudo systemctl restart apache2

───────────────────────────────────────

5. VERIFIKASI HTTPS
───────────────────────────────────────

Test HTTPS lokal:

    curl -k https://localhost

Harus return HTML Apache default

Test dari browser (PC Admin):

    Buka: https://www.lab-smk.xyz

Harus muncul: Apache default page + icon gembok
(Warning sertifikat self-signed = NORMAL untuk lab)

Test DNS resolution + HTTPS:

    nslookup www.lab-smk.xyz

Harus: 192.168.30.10

    curl -k https://www.lab-smk.xyz | head -5

Harus return HTML

───────────────────────────────────────

6. OPTIONAL: GANTI DEFAULT PAGE
───────────────────────────────────────

Edit default page:

    sudo nano /var/www/html/index.html

Contoh konten sederhana:

    <!DOCTYPE html>
    <html>
    <head><title>Lab SMK - UKK 2026</title></head>
    <body>
      <h1>Selamat Datang di Lab TJKT</h1>
      <p>Server: www.lab-smk.xyz</p>
      <p>Status: Online</p>
    </body>
    </html>

───────────────────────────────────────

⚠️ TROUBLESHOOTING
───────────────────────────────────────

Problem: curl SSL handshake failed
Solusi:  Pastikan sudo a2ensite default-ssl sudah dijalankan

Problem: Browser warning "Not Secure"
Solusi:  NORMAL untuk self-signed certificate

Problem: HTTPS tidak accessible dari client
Solusi:  Cek firewall: sudo ufw allow 443/tcp

Problem: DNS tidak resolve ke server
Solusi:  Cek Bind9: nslookup www.lab-smk.xyz

───────────────────────────────────────

📌 CATATAN: Self-signed certificate aman untuk 
lingkungan lab/UKK. Untuk production, gunakan 
Let's Encrypt atau CA resmi.

═══════════════════════════════════════════
