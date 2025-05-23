# Docker SoftEther VPN Setup

This project provides a streamlined way to deploy a multi-protocol SoftEther VPN server using Docker and the `siomiz/softethervpn` image.

## 🌟 Features

- ✅ Supports OpenVPN, L2TP/IPsec, SSTP, and more
- 🔧 Easy customization with `.env`
- 📦 Preconfigured Docker Compose setup
- 🧠 Interactive installer script (`install.sh`)
- ♻️ Persistent configuration using volumes

## 📂 File Structure

- `docker-compose.example.yaml`: Template for the VPN Docker stack
- `install.sh`: Interactive setup and deployment script (Linux/macOS)
- `.env.example`: Environment variable sample file
- `LICENSE`: MIT License

## 📦 Prerequisites

Ensure the following are installed before running the setup:

- **Docker** must be installed and running on your system.  
  [Install Docker →](https://docs.docker.com/get-docker/)

- **Docker Compose** must be available:
  ```bash
  docker-compose --version
  ```

- **Linux Only**: Make sure `dos2unix` is installed to fix line endings:
  ```bash
  sudo apt install dos2unix
  ```

- **Git** (for cloning the repository):
  ```bash
  sudo apt install git       # Debian/Ubuntu
  sudo yum install git       # CentOS/RHEL
  brew install git           # macOS
  ```

## 🚀 Quick Start

### 1. Clone and Run

```bash
git clone https://github.com/amir377/docker-softethervpn.git
cd docker-softethervpn
chmod +x install.sh && dos2unix install.sh && ./install.sh
```

### 2. Follow Prompts

You will be asked to provide:

- VPN container name
- Docker network name
- VPN Pre-Shared Key (PSK)
- VPN users (`username:password` format)
- Server & Hub admin passwords

### 3. Access Your VPN

Your VPN server will automatically expose common ports:
- OpenVPN: `1194/udp`, `1194/tcp`
- SSTP / Web: `443/tcp`
- Admin panel: `5555/tcp`
- L2TP/IPSec: `500/udp`, `4500/udp`
- Legacy / Custom: `992/tcp`, `82/tcp`

## 🔐 Security

Always use a strong PSK and admin passwords. Never expose this config without secure firewalls and user access rules.

## 🧾 License

This project is licensed under the [MIT License](LICENSE).