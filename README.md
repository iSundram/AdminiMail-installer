<!-- TITLE & BADGES -->
<h1 align="center">📬 AdminiMail-installer</h1>
<p align="center">
  <b>Instant, unattended setup for the AdminiMail stack on any fresh Debian/Ubuntu server.</b><br>
  <sub>Powered by Bash, PM2, Node 20 LTS, PostgreSQL 15, and Redis 6 — no manual copy-pasting required.</sub>
</p>

<p align="center">
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/iSundram/AdminiMail-installer?color=brightgreen">
  <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/iSundram/AdminiMail-installer?color=blue">
  <img alt="License" src="https://img.shields.io/github/license/iSundram/AdminiMail-installer">
  <img alt="OS" src="https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-blue">
  <img alt="Shell" src="https://img.shields.io/badge/shell-bash-green">
  <img alt="Node.js" src="https://img.shields.io/badge/node.js-20%20LTS-brightgreen">
  <img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/iSundram/AdminiMail-installer">
  <img alt="GitHub stars" src="https://img.shields.io/github/stars/iSundram/AdminiMail-installer?style=social">
</p>

## 📚 Table of Contents

- [What is AdminiMail?](#-what-is-adminimail)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Architecture Overview](#-architecture-overview)
- [Manual Installation](#-manual-installation)
- [Installation Process](#-installation-process)
- [Configuration & Customization](#-configuration--customization)
- [Environment Variables](#-environment-variables)
- [Domain Setup & HTTPS](#-domain-setup--https)
- [Security Best Practices](#-security-best-practices)
- [Performance Optimization](#-performance-optimization)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [Maintenance](#-maintenance)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

## 🎯 What is AdminiMail?

AdminiMail is a comprehensive email marketing platform designed for businesses and organizations to manage their email campaigns efficiently. This installer automates the complete setup process, deploying a production-ready instance with:

- **Frontend Application**: User-friendly web interface for campaign management
- **Worker Service**: Background processing for email sending and queue management
- **Database Layer**: PostgreSQL for data persistence and Redis for caching
- **Process Management**: PM2 for service monitoring and auto-restart capabilities

The platform provides features like campaign creation, subscriber management, analytics, template design, and automated email sequences - all wrapped in a modern, responsive interface.

## 🌟 Features

| ✅ Feature | Description |
|------------|-------------|
| **One-line install** | Spins up Node 20 LTS (via **NVM**), **pnpm**, PostgreSQL, Redis, Git |
| **Secure by default** | Prompts once for a Postgres password, generates unique secrets |
| **Hands-free app deploy** | Clones the AdminiMail repo, installs dependencies, creates DB schema |
| **Always-on service** | Runs AdminiMail under **PM2** (auto-restart, log rotation, reboot-safe) |
| **Idempotent execution** | Safe to re-run: detects existing install and upgrades in-place |
| **Clean rollback** | All files live in `~/AdminiMail` & PM2 — easy to remove if needed |
| **Production-ready** | Optimized configuration for production environments |
| **Multi-service setup** | Configures frontend, worker, database, and cache layers |

## 📋 Prerequisites

Before running the installer, ensure your system meets these requirements:

### System Requirements

| Component | Requirement |
|-----------|-------------|
| **Operating System** | Debian 10/11 or Ubuntu 20.04/22.04 LTS (fresh VPS recommended) |
| **Memory** | Minimum 2 GB RAM (4 GB recommended for production) |
| **CPU** | Minimum 1 vCPU (2+ vCPUs recommended for production) |
| **Storage** | At least 10 GB free disk space |
| **Network** | Open TCP ports 3000 (frontend) and 8787 (worker) |
| **Privileges** | sudo/root access required |

### Software Dependencies

The installer will automatically install these components:

- **Node.js 20 LTS** (via NVM)
- **pnpm** (package manager)
- **PostgreSQL 15** (database)
- **Redis 6** (caching and sessions)
- **PM2** (process manager)
- **Git** (version control)
- **Build tools** (gcc, make, python3)

### Network Configuration

Ensure the following ports are available:

- **Port 3000**: AdminiMail frontend application
- **Port 8787**: AdminiMail worker service
- **Port 5432**: PostgreSQL database (localhost only)
- **Port 6379**: Redis cache (localhost only)

## 🏗️ Architecture Overview

AdminiMail follows a modern microservices architecture:

```
┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │     Worker      │
│   (Port 3000)   │    │   (Port 8787)   │
│                 │    │                 │
│ • User Interface│    │ • Email Queue   │
│ • Campaign Mgmt │    │ • Job Processing│
│ • Analytics     │    │ • SMTP Handling │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
         ┌───────────▼───────────┐
         │     Data Layer        │
         │                       │
         │ ┌─────────┐ ┌───────┐ │
         │ │PostgreSQL│ │ Redis │ │
         │ │(Port 5432)│ │(6379) │ │
         │ └─────────┘ └───────┘ │
         └───────────────────────┘
```

### Technology Stack

- **Frontend Framework**: Modern React/Next.js application
- **Backend Runtime**: Node.js 20 LTS with TypeScript
- **Database**: PostgreSQL 15 for persistent data storage
- **Cache**: Redis 6 for session management and job queues
- **Process Manager**: PM2 for service orchestration
- **Package Manager**: pnpm for efficient dependency management

## 🚀 Quick Start

> **📋 Copy icon:** Click the clipboard in the corner of each code block on GitHub to copy.<br>
> **⚠️ Important:** The installer must run as **root** (or with `sudo`).

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/iSundram/AdminiMail-installer/main/install.sh | sudo bash
```

After approximately 2-3 minutes, you'll see:

```
🎉 AdminiMail installation complete!

• Frontend:  http://<server-ip>:3000
• Worker:    http://<server-ip>:8787

🛠 You can view logs using: pm2 logs adminimail
```

### First Steps

1. **Open the frontend URL** in your browser
2. **Create an admin account** during initial setup
3. **Configure your SMTP settings** for email sending
4. **Start creating your first email campaign**

### Verification

Check that all services are running:

```bash
# Check PM2 status
pm2 status

# View application logs
pm2 logs adminimail

# Check database connection
sudo -u postgres psql -d zerodotemail -c "SELECT version();"

# Check Redis connection
redis-cli ping
```

## 🔧 Manual Installation

If you prefer to clone and run the installer manually:

```bash
# Clone the repository
git clone https://github.com/iSundram/AdminiMail-installer.git

# Navigate to the directory
cd AdminiMail-installer

# Make the script executable
chmod +x install.sh

# Run the installer
sudo ./install.sh
```

### Interactive Setup Process

The script will prompt you for:

1. **PostgreSQL password** - Used for the database superuser and stored in `.env`
2. **Git branch** - Default is `main` (usually no need to change)
3. **Firewall configuration** - Optional UFW setup for ports 3000/8787

Everything else is handled automatically.

## 📂 Installation Process

The installer performs these steps automatically:

### 1. System Preparation
- Updates APT package repositories
- Installs essential build tools and dependencies
- Configures system for Node.js and database services

### 2. Runtime Environment Setup
- Installs NVM (Node Version Manager)
- Downloads and configures Node.js 20 LTS
- Installs pnpm package manager globally
- Sets up proper PATH variables

### 3. Database Services
- Installs PostgreSQL 15 with contrib modules
- Installs Redis 6 server
- Enables services for automatic startup
- Creates database user and schema

### 4. Application Deployment
- Clones AdminiMail repository to `~/AdminiMail`
- Installs all JavaScript/TypeScript dependencies
- Generates secure environment configuration
- Applies database migrations automatically

### 5. Service Configuration
- Builds the application for production
- Configures PM2 process manager
- Starts services with auto-restart
- Saves PM2 configuration for system reboot

## 🛠️ Configuration & Customization

### Port Configuration

To change default ports, edit the installer script before running:

```bash
# Edit install.sh
nano install.sh

# Find these variables and modify as needed:
FRONT_PORT=3000
WORKER_PORT=8787
```

### Advanced Deployment Options

For production deployments, consider these customizations:

```bash
# Set custom database name
DB_NAME="custom_adminimail_db"

# Configure custom application directory
APP_DIR="/opt/adminimail"

# Set custom user for application
APP_USER="adminimail"
```

## 🔐 Environment Variables

The installer automatically generates a `.env` file with these key variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://postgres:password@localhost:5432/zerodotemail` |
| `BETTER_AUTH_SECRET` | Authentication secret key | Auto-generated 32-byte hex string |
| `JWT_SECRET` | JWT signing secret | Auto-generated 32-byte hex string |
| `FRONT_PORT` | Frontend application port | `3000` |
| `WORKER_PORT` | Worker service port | `8787` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` |
| `NODE_ENV` | Environment mode | `production` |

### Custom Environment Configuration

To add custom environment variables:

```bash
# Navigate to AdminiMail directory
cd ~/AdminiMail

# Edit the .env file
nano .env

# Add your custom variables
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=your_username
SMTP_PASS=your_password

# Restart the application
pm2 restart adminimail
```

## 🌐 Domain Setup & HTTPS

### Step 1: DNS Configuration

Point your domain to your server:

```bash
# Example DNS records
A     mail.yourdomain.com    →  YOUR_SERVER_IP
CNAME www.mail.yourdomain.com  →  mail.yourdomain.com
```

### Step 2: Nginx Reverse Proxy

Install and configure Nginx:

```bash
# Install Nginx
sudo apt install nginx -y

# Create configuration file
sudo nano /etc/nginx/sites-available/adminimail
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name mail.yourdomain.com;

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
# Enable the configuration
sudo ln -s /etc/nginx/sites-available/adminimail /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### Step 3: SSL Certificate with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
sudo certbot --nginx -d mail.yourdomain.com

# Auto-renewal is configured automatically
```

## 🛡️ Security Best Practices

### 1. Firewall Configuration

Configure UFW for basic security:

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (adjust port if needed)
sudo ufw allow 22

# Allow HTTP and HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Allow AdminiMail ports (if needed externally)
sudo ufw allow 3000
sudo ufw allow 8787

# Check status
sudo ufw status
```

### 2. Database Security

Secure PostgreSQL installation:

```bash
# Connect to PostgreSQL
sudo -u postgres psql

-- Change default postgres user password
ALTER USER postgres PASSWORD 'strong_new_password';

-- Remove public schema privileges
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- Exit PostgreSQL
\q
```

### 3. Application Security

- **Change default secrets**: Update `BETTER_AUTH_SECRET` and `JWT_SECRET` in production
- **Regular updates**: Keep the system and AdminiMail updated
- **Monitor logs**: Regularly check PM2 and system logs
- **Backup strategy**: Implement regular database backups

### 4. Redis Security

Secure Redis configuration:

```bash
# Edit Redis configuration
sudo nano /etc/redis/redis.conf

# Add these security settings:
# requirepass your_strong_password
# bind 127.0.0.1
# protected-mode yes

# Restart Redis
sudo systemctl restart redis
```

## ⚡ Performance Optimization

### 1. System-Level Optimizations

```bash
# Increase file descriptor limits
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Optimize sysctl parameters
echo "net.core.somaxconn = 65536" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 65536" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### 2. PostgreSQL Optimization

Edit PostgreSQL configuration:

```bash
sudo nano /etc/postgresql/15/main/postgresql.conf
```

Add these optimizations:

```ini
# Memory settings (adjust for your RAM)
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB

# Checkpoint settings
checkpoint_segments = 8
checkpoint_completion_target = 0.9

# Connection settings
max_connections = 200
```

### 3. PM2 Cluster Mode

Enable cluster mode for better performance:

```bash
# Stop current instance
pm2 stop adminimail

# Start in cluster mode
pm2 start ecosystem.config.js

# Save configuration
pm2 save
```

Create `ecosystem.config.js`:

```javascript
module.exports = {
  apps: [{
    name: 'adminimail',
    script: 'npm',
    args: 'start',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production'
    }
  }]
}
```

### 4. Redis Optimization

Optimize Redis for better performance:

```bash
sudo nano /etc/redis/redis.conf
```

Add these settings:

```ini
# Memory optimization
maxmemory 512mb
maxmemory-policy allkeys-lru

# Persistence optimization
save ""
appendonly yes
appendfsync everysec
```

## 🔧 Troubleshooting

### Common Installation Issues

#### 1. Permission Denied Errors
```bash
# Ensure script has execute permissions
chmod +x install.sh

# Run with sudo
sudo ./install.sh
```

#### 2. Port Already in Use
```bash
# Check what's using the ports
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :8787

# Kill processes if needed
sudo kill -9 <PID>
```

#### 3. Database Connection Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check if database exists
sudo -u postgres psql -l | grep zerodotemail

# Reset database password
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'newpassword';"
```

#### 4. Node.js/NVM Issues
```bash
# Reload NVM
source ~/.nvm/nvm.sh

# Install specific Node version
nvm install 20
nvm use 20
nvm alias default 20
```

### Service Management Issues

#### PM2 Service Not Starting
```bash
# Check PM2 status
pm2 status

# View detailed logs
pm2 logs adminimail --lines 50

# Restart service
pm2 restart adminimail

# Reset PM2
pm2 kill
pm2 resurrect
```

#### Memory Issues
```bash
# Check memory usage
free -h
pm2 monit

# Restart if memory leak detected
pm2 restart adminimail
```

### Network and Connectivity Issues

#### Can't Access Web Interface
```bash
# Check if services are listening
sudo ss -tlnp | grep :3000
sudo ss -tlnp | grep :8787

# Check firewall
sudo ufw status

# Check application logs
pm2 logs adminimail
```

#### Database Connection Timeout
```bash
# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-15-main.log

# Test database connection
sudo -u postgres psql -d zerodotemail -c "SELECT NOW();"
```

## ❓ FAQ

### General Questions

**Q: What is the difference between AdminiMail and other email marketing platforms?**
A: AdminiMail is self-hosted, giving you complete control over your data and email infrastructure. It's cost-effective for high-volume sending and provides enterprise-grade features without monthly subscriptions.

**Q: Can I use this on a shared hosting environment?**
A: No, this installer requires root access and is designed for VPS/dedicated servers. Shared hosting typically doesn't allow the required system modifications.

**Q: How much does it cost to run AdminiMail?**
A: Only your server costs! AdminiMail is open-source. A $5-10/month VPS can handle thousands of subscribers.

### Technical Questions

**Q: Can I change the database from PostgreSQL to MySQL?**
A: The current installer is specifically designed for PostgreSQL. While AdminiMail might support other databases, you'd need to modify the installation process significantly.

**Q: How do I backup my AdminiMail data?**
A: Create regular PostgreSQL backups:
```bash
# Create backup
sudo -u postgres pg_dump zerodotemail > backup_$(date +%Y%m%d).sql

# Restore from backup
sudo -u postgres psql zerodotemail < backup_20240101.sql
```

**Q: Can I run multiple AdminiMail instances on the same server?**
A: Yes, but you'll need to modify ports and database names for each instance to avoid conflicts.

**Q: How do I update AdminiMail to the latest version?**
A: Use the update command:
```bash
cd ~/AdminiMail
git pull
pnpm install
pnpm build
pm2 restart adminimail
```

### Configuration Questions

**Q: How do I configure SMTP for sending emails?**
A: Edit the `.env` file in `~/AdminiMail` and add your SMTP credentials, then restart the service.

**Q: Can I use a different domain for the worker service?**
A: Yes, configure your reverse proxy to route different domains to ports 3000 and 8787.

**Q: How do I increase email sending limits?**
A: This depends on your SMTP provider. Configure rate limiting in the AdminiMail settings panel.

## 🔄 Maintenance

### Regular Maintenance Tasks

| Task | Frequency | Command |
|------|-----------|---------|
| **Update AdminiMail** | Weekly | `cd ~/AdminiMail && git pull && pnpm install && pnpm build && pm2 restart adminimail` |
| **View logs** | As needed | `pm2 logs adminimail` |
| **Restart service** | As needed | `pm2 restart adminimail` |
| **Database backup** | Daily | `sudo -u postgres pg_dump zerodotemail > backup_$(date +%Y%m%d).sql` |
| **System updates** | Weekly | `sudo apt update && sudo apt upgrade -y` |
| **Cleanup old logs** | Monthly | `pm2 flush adminimail` |
| **Check disk space** | Weekly | `df -h` |
| **Monitor memory** | Daily | `pm2 monit` |

### Advanced Maintenance

#### Complete System Reset
```bash
# Stop all services
pm2 stop adminimail
pm2 delete adminimail

# Remove application
rm -rf ~/AdminiMail

# Remove databases (CAUTION: This deletes all data!)
sudo -u postgres dropdb zerodotemail

# Remove installed packages (optional)
sudo apt purge postgresql redis-server -y
```

#### Upgrade Node.js Version
```bash
# Install new Node.js version
nvm install node # Latest version
nvm install 18   # Specific version

# Switch to new version
nvm use node
nvm alias default node

# Rebuild applications
cd ~/AdminiMail
rm -rf node_modules
pnpm install
pnpm build
pm2 restart adminimail
```

#### Database Maintenance
```bash
# Analyze database performance
sudo -u postgres psql zerodotemail -c "ANALYZE;"

# Vacuum database
sudo -u postgres psql zerodotemail -c "VACUUM FULL;"

# Check database size
sudo -u postgres psql zerodotemail -c "SELECT pg_size_pretty(pg_database_size('zerodotemail'));"
```

## 🗺️ Roadmap

### Near-term Goals (Q1 2024)
- [ ] **Automated Nginx + Let's Encrypt configuration**
- [ ] **ARM64 (Raspberry Pi) support**
- [ ] **Docker containerization option**
- [ ] **Backup and restore scripts**
- [ ] **Health check endpoints**

### Medium-term Goals (Q2-Q3 2024)
- [ ] **Multi-server deployment support**
- [ ] **Redis Cluster configuration**
- [ ] **PostgreSQL replica setup**
- [ ] **Systemd unit alternative to PM2**
- [ ] **Monitoring dashboard integration**

### Long-term Goals (Q4 2024+)
- [ ] **Kubernetes deployment manifests**
- [ ] **CI/CD pipeline integration**
- [ ] **Multi-region deployment**
- [ ] **Advanced security hardening**
- [ ] **Performance benchmarking tools**

### Community Contributions

We welcome contributions in these areas:
- **Operating system support** (CentOS, RHEL, Alpine)
- **Cloud provider integrations** (AWS, GCP, Azure)
- **Automation improvements**
- **Documentation enhancements**
- **Testing and bug reports**

## 🤝 Contributing

We welcome contributions to make AdminiMail-installer better! Here's how you can help:

### Getting Started

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly** on a fresh VPS
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Contribution Guidelines

- **Test your changes** on multiple Ubuntu/Debian versions
- **Follow bash scripting best practices**
- **Update documentation** for any new features
- **Ensure backward compatibility**
- **Write clear commit messages**

### Types of Contributions

- **🐛 Bug fixes**: Fix installation or runtime issues
- **✨ New features**: Add support for new OS versions or features
- **📚 Documentation**: Improve README, add examples
- **🧪 Testing**: Add test scripts or CI/CD improvements
- **🔧 Optimization**: Performance or security improvements

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/AdminiMail-installer.git

# Create test environment (recommended: fresh VM)
vagrant up  # If you use Vagrant

# Test the installer
sudo ./install.sh
```

### Reporting Issues

When reporting bugs, please include:

- **Operating system and version**
- **Full error messages**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **System logs** (if relevant)

## 📄 License

AdminiMail-installer is released under the **MIT License**.

```
MIT License

Copyright (c) 2025 iSundram

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
  <strong>Made with ❤️ by <a href="https://github.com/iSundram">iSundram</a></strong><br>
  <sub>⭐ Star this repo if you found it helpful!</sub>
</p>