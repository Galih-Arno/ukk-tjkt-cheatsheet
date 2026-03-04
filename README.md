# 📘 UKK TJKT 2026 - Cloud Cheatsheet
> **Maintainer:** [@Galih-Arno](https://github.com/Galih-Arno)  
> **Last Update:** 2026-03-04  
> **Access:** CLI • Browser • Mobile

---

## 🔄 Quick Access

### Via CLI (Server Ubuntu)
```bash
# Baca langsung via less
curl -s https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/README.md | less

# Download untuk offline access
wget https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/README.md -O ~/ukk-cheat.md
less ~/ukk-cheat.md

# Search keyword di dalam less: tekan / lalu ketik keyword
```

### Via Browser / Mobile
👉 [https://github.com/Galih-Arno/ukk-tjkt-cheatsheet](https://github.com/Galih-Arno/ukk-tjkt-cheatsheet)

---

## 📚 Menu Konten

### 🎯 Router Config (MikroTik)
| File | Deskripsi | Raw URL |
|------|-----------|---------|
| [01-vlan-ip.md](router/01-vlan-ip.md) | VLAN Interface & IP Gateway | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/router/01-vlan-ip.md) |
| [02-dhcp-nat.md](router/02-dhcp-nat.md) | DHCP Server, NAT, Route | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/router/02-dhcp-nat.md) |
| [03-firewall.md](router/03-firewall.md) | 🔥 Firewall Rules Lengkap | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/router/03-firewall.md) |

### 🔄 Switch Config (MikroTik)
| File | Deskripsi | Raw URL |
|------|-----------|---------|
| [01-bridge-vlan.md](switch/01-bridge-vlan.md) | Bridge VLAN Filtering + Port Mapping | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/switch/01-bridge-vlan.md) |

### 💻 Server Config (Ubuntu 24.04)
| File | Deskripsi | Raw URL |
|------|-----------|---------|
| [01-netplan.md](server/01-netplan.md) | Network Setup (Gateway 192.168.30.1!) | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/server/01-netplan.md) |
| [02-dns-bind9.md](server/02-dns-bind9.md) | DNS Server + Hardening Recursion | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/server/02-dns-bind9.md) |
| [03-web-https.md](server/03-web-https.md) | Apache Web Server + Self-Signed SSL | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/server/03-web-https.md) |
| [04-zabbix-setup.md](server/04-zabbix-setup.md) | Zabbix 7.0 Monitoring Setup | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/server/04-zabbix-setup.md) |

### 🧪 Testing & Verification
| File | Deskripsi | Raw URL |
|------|-----------|---------|
| [01-verify-commands.md](testing/01-verify-commands.md) | Testing Commands Lengkap + Checklist | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/testing/01-verify-commands.md) |

### 📄 Documentation
| File | Deskripsi | Raw URL |
|------|-----------|---------|
| [kebijakan-keamanan.md](docs/kebijakan-keamanan.md) | Template Kebijakan Keamanan | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/docs/kebijakan-keamanan.md) |
| [troubleshooting.md](docs/troubleshooting.md) | Quick Fix Common Issues | [Raw](https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/docs/troubleshooting.md) |

---

## 💡 Tips Penggunaan

### Di Terminal (less)
```
/keyword    → Search teks
n           → Next search result
q           → Quit
```

### Download Semua File (Offline Mode)
```bash
mkdir -p ~/ukk-offline
cd ~/ukk-offline
wget -r -np -nH --cut-dirs=3 -R "index.html*" \
  https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/
```

### Update Cheatsheet
```bash
# Hapus cache lama
rm -f ~/ukk-cheat.md

# Download versi terbaru
curl -s https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/README.md -o ~/ukk-cheat.md
```

---

> ⚠️ **PENTING:** Selalu test koneksi internet di awal ujian:
> ```bash
> ping -c 2 raw.githubusercontent.com
> curl -I https://raw.githubusercontent.com/Galih-Arno/ukk-tjkt-cheatsheet/main/README.md
> ```

> 🆘 **Emergency:** Jika cloud down, gunakan backup USB atau file offline yang sudah didownload.
