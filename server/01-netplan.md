═══════════════════════════════════════════
SERVER CONFIG: NETWORK SETUP (NETPLAN)
═══════════════════════════════════════════

Target: Ubuntu Server 24.04 LTS

⚠️ PENTING: GATEWAY HARUS 192.168.30.1
           (BUKAN 192.168.10.1!)

───────────────────────────────────────

1. CEK NAMA INTERFACE
───────────────────────────────────────

Jalankan perintah:

    ip a

Output contoh:

    2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP>
       inet 192.168.30.10/24 ...

Catat nama interface (misal: enp0s25)

───────────────────────────────────────

2. EDIT NETPLAN CONFIGURATION
───────────────────────────────────────

    sudo nano /etc/netplan/00-installer-config.yaml

Paste konten ini (sesuaikan nama interface):

    network:
      version: 2
      ethernets:
        enp0s25:
          dhcp4: no
          addresses: [192.168.30.10/24]
          routes:
            - to: default
              via: 192.168.30.1
          nameservers:
            addresses: [127.0.0.1, 8.8.8.8]

⚠️ GANTI "enp0s25" dengan nama interface Anda!
   Cek dengan perintah: ip a

───────────────────────────────────────

3. APPLY CONFIGURATION
───────────────────────────────────────

    sudo netplan apply

Jika ada error, cek syntax:

    sudo netplan --debug apply

───────────────────────────────────────

4. VERIFIKASI
───────────────────────────────────────

Cek routing table:

    ip route show

Harus muncul:

    default via 192.168.30.1 dev enp0s25

Test ping gateway:

    ping 192.168.30.1

Harus: Reply ✅

Test ping internet:

    ping 8.8.8.8

Harus: Reply ✅

───────────────────────────────────────

⚠️ TROUBLESHOOTING
───────────────────────────────────────

Problem: Gateway tidak reachable
Solusi:  Pastikan via: 192.168.30.1 (bukan 10.1!)

Problem: Internet tidak jalan
Solusi:  Cek Router NAT & Default Route

Problem: DNS tidak resolve
Solusi:  Cek /etc/resolv.conf, pastikan nameserver terisi

═══════════════════════════════════════════
