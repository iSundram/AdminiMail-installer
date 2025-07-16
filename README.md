<!-- TITLE & BADGES -->
<h1 align="center">📬 AdminiMail Installer</h1>
<p align="center">
  <b>One-Command Setup for Complete Email Infrastructure</b><br>
  <sub>Automated installer for AdminiMail stack with Node.js, PostgreSQL, Redis, and PM2 process management</sub>
</p>

<p align="center">
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/iSundram/AdminiMail-installer?color=brightgreen">
  <img alt="License" src="https://img.shields.io/github/license/iSundram/AdminiMail-installer">
  <img alt="Platform" src="https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-blue">
  <img alt="Shell Script" src="https://img.shields.io/badge/shell-bash-blue">
  <img alt="Node.js Version" src="https://img.shields.io/badge/node.js-20%20LTS-green">
  <img alt="PostgreSQL" src="https://img.shields.io/badge/postgresql-15-blue">
  <img alt="Redis" src="https://img.shields.io/badge/redis-6-red">
</p>

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Architecture](#-architecture)
- [Manual Installation](#-manual-installation)
- [Configuration](#-configuration)
- [Maintenance](#-maintenance)
- [Domain & HTTPS Setup](#-domain--https-setup)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [Performance Optimization](#-performance-optimization)
- [Uninstallation](#-uninstallation)
- [Contributing](#-contributing)
- [Roadmap](#-roadmap)
- [License](#-license)

## 🌟 Overview

AdminiMail Installer is an automated deployment script that sets up a complete, production-ready email infrastructure in minutes. It handles everything from system dependencies to application deployment, ensuring a seamless installation experience.

**What is AdminiMail?**
AdminiMail is a modern, self-hosted email management platform built with Node.js and TypeScript. It provides a complete email solution with web interface, worker processes, and robust backend infrastructure.

## ✨ Features

| Feature | Description |
|---------|-------------|
| **🚀 One-Command Install** | Complete setup with a single command - no manual configuration required |
| **🔒 Secure by Default** | Generates unique secrets, prompts for secure passwords, and follows security best practices |
| **📦 Full Stack Setup** | Installs and configures Node.js 20 LTS, PostgreSQL 15, Redis 6, and all dependencies |
| **⚡ Process Management** | Uses PM2 for reliable process management with auto-restart and log rotation |
| **🔄 Idempotent Installation** | Safe to re-run - detects existing installations and performs upgrades gracefully |
| **🎯 Production Ready** | Optimized configuration for production environments with proper service management |
| **📊 Monitoring Ready** | Built-in logging and monitoring capabilities through PM2 |
| **🛡️ Firewall Integration** | Optional UFW firewall configuration for enhanced security |

## 📋 Prerequisites

### System Requirements

| Requirement | Specification |
|-------------|---------------|
| **Operating System** | Debian 10/11 or Ubuntu 20.04/22.04 LTS |
| **RAM** | Minimum 2 GB (4 GB recommended for production) |
| **CPU** | Minimum 1 vCPU (2+ vCPUs recommended) |
| **Storage** | Minimum 10 GB available space |
| **Network** | Internet connection for downloading packages |
| **Privileges** | Root access or sudo privileges |

### Required Ports

| Port | Service | Purpose |
|------|---------|---------|
| `3000` | Frontend | Web interface access |
| `8787` | Worker | Background job processing |
| `22` | SSH | Server administration (should already be open) |

### Pre-Installation Checklist

- [ ] Fresh server installation (recommended)
- [ ] Root or sudo access confirmed
- [ ] Server accessible via SSH
- [ ] Ports 3000 and 8787 available
- [ ] Domain name pointed to server (optional, for HTTPS setup)

## 🚀 Quick Start

> **⚠️ Important:** Run this installer on a fresh server as **root** or with `sudo` privileges.

### One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/iSundram/AdminiMail-installer/main/install.sh | sudo bash
```

### What Happens Next

1. **System Setup** (~30 seconds): Updates packages and installs dependencies
2. **Node.js Installation** (~60 seconds): Installs Node.js 20 LTS via NVM
3. **Database Setup** (~30 seconds): Configures PostgreSQL and Redis
4. **Application Deployment** (~60 seconds): Downloads and builds AdminiMail
5. **Service Start** (~10 seconds): Launches AdminiMail with PM2

### Expected Output

After ~3-5 minutes, you'll see:

```
🎉 AdminiMail installation complete!

• Frontend:  http://<your-server-ip>:3000
• Worker:    http://<your-server-ip>:8787

🛠 You can view logs using: pm2 logs adminimail
```

### First Access

1. Open `http://<your-server-ip>:3000` in your web browser
2. Create your admin account
3. Start managing your email infrastructure!

## 🏗️ Architecture

AdminiMail follows a modern microservices architecture:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Worker        │    │   Database      │
│   (Port 3000)   │────│   (Port 8787)   │────│   PostgreSQL    │
│   Web Interface │    │   Job Queue     │    │   + Redis       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Runtime** | Node.js 20 LTS | JavaScript execution environment |
| **Package Manager** | pnpm | Fast, efficient package management |
| **Database** | PostgreSQL 15 | Primary data storage |
| **Cache/Queue** | Redis 6 | Caching and job queuing |
| **Process Manager** | PM2 | Production process management |
| **Build Tool** | TypeScript | Type-safe development |

### File Structure

```
~/AdminiMail/           # Main application directory
├── .env               # Environment configuration
├── package.json       # Node.js dependencies
├── prisma/           # Database schema and migrations
├── src/              # Application source code
├── public/           # Static web assets
└── dist/             # Compiled application (after build)
```

## 🔧 Manual Installation

If you prefer to clone and run the installer manually:

```bash
# Clone the installer repository
git clone https://github.com/iSundram/AdminiMail-installer.git
cd AdminiMail-installer

# Make the script executable
chmod +x install.sh

# Run the installer
sudo ./install.sh
```

### Installation Process

The installer will prompt you for:

1. **PostgreSQL Password**: Used for the `postgres` superuser and stored in `.env`
2. **Git Branch** (optional): Default is `main`
3. **Firewall Configuration** (optional): Opens ports 3000/8787 via UFW

Everything else is automated.

### What the Script Does

1. **System Updates**: Updates APT repositories and installs core packages
2. **Node.js Setup**: Installs NVM, Node.js 20 LTS, and pnpm
3. **Database Installation**: Installs and configures PostgreSQL 15 and Redis 6
4. **Application Deployment**: Clones AdminiMail repository to `~/AdminiMail`
5. **Database Configuration**: Creates database and applies schema
6. **Environment Setup**: Generates `.env` with secure secrets and database URL
7. **Dependency Installation**: Runs `pnpm install` for all dependencies
8. **Application Build**: Compiles TypeScript and builds production assets
9. **Service Management**: Starts AdminiMail with PM2 and configures auto-restart

## ⚙️ Configuration

### Environment Variables

The installer automatically configures these key environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://postgres:password@localhost:5432/zerodotemail` |
| `BETTER_AUTH_SECRET` | Authentication secret (auto-generated) | `32-character hex string` |
| `JWT_SECRET` | JWT signing secret (auto-generated) | `32-character hex string` |
| `FRONT_PORT` | Frontend service port | `3000` |
| `WORKER_PORT` | Worker service port | `8787` |

### Customizing Ports

To change default ports, edit the `install.sh` script before running:

```bash
# Edit these variables in install.sh
FRONT_PORT=3000    # Change frontend port
WORKER_PORT=8787   # Change worker port
```

## 🛠️ Maintenance

### Common Tasks

| Task | Command |
|------|---------|
| **Update AdminiMail** | `cd ~/AdminiMail && git pull && pnpm install && pnpm build && pm2 restart adminimail` |
| **View Live Logs** | `pm2 logs adminimail` |
| **Restart Service** | `pm2 restart adminimail` |
| **Stop Service** | `pm2 stop adminimail` |
| **Check Service Status** | `pm2 status adminimail` |
| **View Service Info** | `pm2 info adminimail` |

### Log Management

```bash
# View real-time logs
pm2 logs adminimail --follow

# View specific number of log lines
pm2 logs adminimail --lines 100

# Clear logs
pm2 flush adminimail
```

### Database Maintenance

```bash
# Connect to PostgreSQL
sudo -u postgres psql -d zerodotemail

# Backup database
pg_dump -U postgres -h localhost zerodotemail > backup.sql

# Restore database
psql -U postgres -h localhost zerodotemail < backup.sql
```

## 🌐 Domain & HTTPS Setup

### Step 1: DNS Configuration

Point your domain's A record to your server's IP address:

```
Type: A
Name: mail (or your desired subdomain)
Value: your.server.ip.address
TTL: 300 (or default)
```

### Step 2: Install Nginx and Certbot

```bash
# Install Nginx
sudo apt install nginx

# Install Certbot for Let's Encrypt
sudo apt install certbot python3-certbot-nginx
```

### Step 3: Configure Nginx

Create a configuration file for your domain:

```bash
sudo nano /etc/nginx/sites-available/adminimail
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/adminimail /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Step 4: Obtain SSL Certificate

```bash
sudo certbot --nginx -d your-domain.com
```

## 🔒 Security

### Built-in Security Features

- **Secure Secrets**: Auto-generated cryptographically secure secrets
- **Database Security**: PostgreSQL with password authentication
- **Local Services**: Redis runs on localhost only
- **Process Isolation**: PM2 process management with user separation

### Security Best Practices

1. **Change Default Passwords**: Update the PostgreSQL password after installation
2. **Enable Firewall**: Use UFW to restrict access to necessary ports only
3. **Regular Updates**: Keep the system and AdminiMail updated
4. **SSL/TLS**: Always use HTTPS in production
5. **Backup Encryption**: Encrypt database backups
6. **Monitor Logs**: Regularly review application and system logs

### Firewall Configuration

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (if not already configured)
sudo ufw allow 22

# Allow AdminiMail ports
sudo ufw allow 3000
sudo ufw allow 8787

# Check firewall status
sudo ufw status
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Installation Fails

**Problem**: Installation script fails or exits unexpectedly

**Solutions**:
1. Check if you're running as root or with sudo
2. Ensure internet connectivity is available
3. Verify the server meets minimum requirements
4. Check available disk space: `df -h`

#### Service Won't Start

**Problem**: PM2 fails to start AdminiMail

**Solutions**:
```bash
# Check PM2 status
pm2 status

# Check detailed logs
pm2 logs adminimail

# Try manual start
cd ~/AdminiMail
pnpm start
```

#### Database Connection Issues

**Problem**: Cannot connect to PostgreSQL

**Solutions**:
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Test database connection
sudo -u postgres psql -c "SELECT version();"

# Check database exists
sudo -u postgres psql -l | grep zerodotemail
```

#### Port Already in Use

**Problem**: Ports 3000 or 8787 are already occupied

**Solutions**:
```bash
# Check what's using the ports
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :8787

# Kill processes using the ports (if safe to do so)
sudo fuser -k 3000/tcp
sudo fuser -k 8787/tcp
```

#### Out of Memory

**Problem**: Installation fails due to insufficient memory

**Solutions**:
1. Add swap space:
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

2. Or upgrade to a server with more RAM

### Debug Mode

Enable verbose logging during installation:

```bash
bash -x install.sh
```

### Getting Help

If you encounter issues:

1. Check the [troubleshooting section](#-troubleshooting)
2. Review PM2 logs: `pm2 logs adminimail`
3. Check system logs: `journalctl -u postgresql` or `journalctl -u redis`
4. Open an issue on [GitHub](https://github.com/iSundram/AdminiMail-installer/issues)

## ❓ FAQ

### General Questions

**Q: What is AdminiMail?**
A: AdminiMail is a modern, self-hosted email management platform that provides a complete email infrastructure with web interface and background processing capabilities.

**Q: How long does installation take?**
A: Typically 3-5 minutes on a fresh server with good internet connectivity.

**Q: Can I run this on an existing server?**
A: While possible, it's recommended to use a fresh server to avoid conflicts with existing services.

**Q: What happens if I run the installer twice?**
A: The installer is idempotent - it will detect existing installations and perform upgrades safely.

### Technical Questions

**Q: Can I change the default ports?**
A: Yes, edit the `FRONT_PORT` and `WORKER_PORT` variables in `install.sh` before running it.

**Q: How do I backup my data?**
A: Use PostgreSQL's `pg_dump` command to backup the database, and backup the `~/AdminiMail` directory for application files.

**Q: Can I use an external database?**
A: Yes, modify the `DATABASE_URL` in the `.env` file to point to your external PostgreSQL instance.

**Q: How do I monitor resource usage?**
A: Use `pm2 monit` for real-time monitoring, or integrate with monitoring tools like Grafana.

### Security Questions

**Q: Is AdminiMail secure?**
A: Yes, it includes secure defaults, auto-generated secrets, and follows security best practices. Always use HTTPS in production.

**Q: How do I update AdminiMail?**
A: Run the update command: `cd ~/AdminiMail && git pull && pnpm install && pnpm build && pm2 restart adminimail`

## ⚡ Performance Optimization

### Server Optimization

1. **Increase PM2 Instances**: For multi-core servers
```bash
pm2 delete adminimail
pm2 start "pnpm start" --name adminimail --instances max
```

2. **Database Tuning**: Optimize PostgreSQL configuration
```bash
sudo nano /etc/postgresql/15/main/postgresql.conf
```

Add these optimizations:
```
shared_buffers = 256MB          # 1/4 of total RAM
effective_cache_size = 1GB      # 3/4 of total RAM
work_mem = 4MB
maintenance_work_mem = 64MB
```

3. **Redis Optimization**: Configure Redis for better performance
```bash
sudo nano /etc/redis/redis.conf
```

### Application Optimization

1. **Enable Production Mode**: Ensure NODE_ENV is set to production
2. **Database Indexing**: AdminiMail includes optimized database indexes
3. **Asset Compression**: Enable gzip compression in Nginx

### Monitoring Performance

```bash
# Monitor PM2 processes
pm2 monit

# Check database performance
sudo -u postgres psql -d zerodotemail -c "SELECT * FROM pg_stat_activity;"

# Monitor system resources
htop
iotop
```

## 🗑️ Uninstallation

### Complete Removal

To completely remove AdminiMail and all associated services:

```bash
# Stop and remove PM2 process
pm2 delete adminimail
pm2 save

# Remove AdminiMail directory
rm -rf ~/AdminiMail

# Remove Node.js (if not needed for other applications)
nvm deactivate
rm -rf ~/.nvm

# Remove databases (⚠️ This will delete all data)
sudo -u postgres dropdb zerodotemail
sudo -u postgres dropuser postgres

# Remove services (optional - only if not needed for other applications)
sudo apt remove --purge postgresql postgresql-contrib redis-server -y
sudo apt autoremove -y

# Remove PM2 (if not needed for other applications)
npm uninstall -g pm2
```

### Partial Removal

To keep the system packages but remove only AdminiMail:

```bash
# Stop and remove AdminiMail service
pm2 delete adminimail
pm2 save

# Remove application files
rm -rf ~/AdminiMail

# Keep PostgreSQL and Redis but remove the database
sudo -u postgres dropdb zerodotemail
```

## 🤝 Contributing

We welcome contributions to improve AdminiMail Installer! Here's how you can help:

### Development Setup

1. Fork the repository
2. Clone your fork:
```bash
git clone https://github.com/your-username/AdminiMail-installer.git
cd AdminiMail-installer
```

3. Make your changes
4. Test on a fresh VM or container
5. Submit a pull request

### Contribution Guidelines

- **Test Thoroughly**: Always test changes on fresh Debian/Ubuntu installations
- **Document Changes**: Update README.md for any new features or changes
- **Follow Style**: Maintain consistent bash scripting style
- **Security First**: Consider security implications of any changes

### Areas for Contribution

- Support for additional Linux distributions
- Improved error handling and recovery
- Performance optimizations
- Documentation improvements
- Security enhancements

### Reporting Issues

When reporting issues, please include:

- Operating system and version
- Server specifications
- Full error output
- Steps to reproduce

## 🗺️ Roadmap

### Upcoming Features

- [ ] **Multi-Distribution Support**
  - CentOS/RHEL support
  - Alpine Linux support
  - ARM64/Raspberry Pi compatibility

- [ ] **Enhanced Security**
  - Automated SSL certificate management
  - Integration with fail2ban
  - Enhanced firewall configuration

- [ ] **Monitoring & Observability**
  - Built-in metrics collection
  - Health check endpoints
  - Integration with monitoring tools

- [ ] **Deployment Options**
  - Docker container support
  - Kubernetes deployment manifests
  - Systemd service alternative to PM2

- [ ] **Advanced Features**
  - Automated backup configuration
  - High availability setup
  - Load balancer integration

### Community Requests

- GitHub Actions for automated testing
- Ansible playbook version
- Terraform integration
- Cloud provider templates (AWS, GCP, Azure)

### Contributing to Roadmap

Have ideas for new features? [Open an issue](https://github.com/iSundram/AdminiMail-installer/issues) to discuss your suggestions!

## 📄 License

AdminiMail Installer is released under the **MIT License**.

```
MIT License

Copyright (c) 2025 Sundram Kumar Tiwari

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Feel free to fork, adapt, and share. A backlink is appreciated but not required.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/iSundram">iSundram</a><br>
  <sub>⭐ Star this repository if it helped you!</sub>
</p>