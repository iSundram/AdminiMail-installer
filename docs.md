# AdminiMail-installer Technical Documentation

This document provides comprehensive technical documentation for the AdminiMail-installer project, complementing the README with deeper technical insights and detailed implementation guidance.

## Table of Contents

- [Technical Architecture](#technical-architecture)
- [Installation Deep Dive](#installation-deep-dive)
- [Configuration Reference](#configuration-reference)
- [API Documentation](#api-documentation)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Development Guide](#development-guide)
- [Maintenance & Operations](#maintenance--operations)
- [Security Documentation](#security-documentation)
- [FAQ & Common Scenarios](#faq--common-scenarios)

---

## Technical Architecture

### System Architecture Overview

The AdminiMail-installer is an automated deployment script that orchestrates the installation of a complete email management stack. The architecture consists of several interconnected components:

```
┌─────────────────────────────────────────────────────────────────┐
│                    AdminiMail Stack Architecture                │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │   Frontend  │    │   Worker    │    │     Process         │  │
│  │   :3000     │◄───┤   :8787     │◄───┤     Manager         │  │
│  │             │    │             │    │     (PM2)           │  │
│  └─────────────┘    └─────────────┘    └─────────────────────┘  │
│         │                   │                      │            │
│         │                   │                      │            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │ PostgreSQL  │    │    Redis    │    │    File System      │  │
│  │   :5432     │    │   :6379     │    │   ~/AdminiMail      │  │
│  │ Database    │    │   Cache     │    │   Application       │  │
│  └─────────────┘    └─────────────┘    └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Component Interaction Diagrams

#### Installation Flow
```
[install.sh] → [System Update] → [NVM Installation] → [Node.js 20 LTS]
     │                                                      │
     ▼                                                      ▼
[PostgreSQL 15] → [Redis 6] → [Git Clone] → [Dependencies] → [PM2 Startup]
     │                              │               │             │
     ▼                              ▼               ▼             ▼
[Database Setup] → [Environment Config] → [Build Process] → [Service Start]
```

#### Runtime Communication Flow
```
User Request → Frontend (:3000) → Worker (:8787) → Database/Cache
     │              │                    │              │
     ▼              ▼                    ▼              ▼
Browser ← HTTP Response ← API Response ← Data Layer ← Storage
```

### Technology Stack Explanation

| Component | Version | Purpose | Installation Method |
|-----------|---------|---------|-------------------|
| **Node.js** | 20 LTS | JavaScript runtime for frontend and worker | NVM (Node Version Manager) |
| **pnpm** | Latest | Fast, disk space efficient package manager | npm global install |
| **PostgreSQL** | 15 | Primary database for application data | APT package manager |
| **Redis** | 6 | In-memory cache and session storage | APT package manager |
| **PM2** | Latest | Production process manager | npm global install |
| **NVM** | 0.39.3 | Node.js version management | curl installation script |

### Database Schema and Relationships

The installer creates a PostgreSQL database with the following structure:

```sql
-- Database: zerodotemail
-- User: postgres (superuser privileges)
-- Connection: postgresql://postgres:${PASSWORD}@localhost:5432/zerodotemail

-- Schema is managed by the AdminiMail application using Prisma ORM
-- Tables are auto-generated during the `pnpm db:push` step
```

### Service Dependencies and Communication Flow

```
System Boot
    │
    ├── PostgreSQL Service (systemd)
    ├── Redis Service (systemd)
    └── PM2 (user-level daemon)
            │
            └── AdminiMail Application
                    │
                    ├── Frontend Server (:3000)
                    └── Worker Server (:8787)
```

**Dependency Chain:**
1. Operating System (Debian/Ubuntu)
2. System packages (curl, git, build-essential, libpq-dev)
3. PostgreSQL and Redis services
4. Node.js runtime environment
5. Application dependencies
6. PM2 process manager
7. AdminiMail application services

---

## Installation Deep Dive

### Pre-installation System Checks

Before running the installer, ensure your system meets these requirements:

```bash
# Check OS version
lsb_release -a

# Verify system resources
free -h  # Minimum 2GB RAM
df -h    # Sufficient disk space (minimum 10GB free)

# Check network connectivity
curl -I https://github.com
curl -I https://registry.npmjs.org

# Verify sudo privileges
sudo -v
```

### Detailed Step-by-Step Installation Process

#### Phase 1: System Preparation
```bash
# 1. Update package lists
apt update -y

# 2. Install essential build tools and libraries
apt install -y curl git build-essential libpq-dev postgresql postgresql-contrib redis-server
```

#### Phase 2: Node.js Environment Setup
```bash
# 3. Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# 4. Load NVM into current session
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

# 5. Install and configure Node.js 20 LTS
nvm install 20
nvm use 20
nvm alias default 20

# 6. Install pnpm package manager
npm install -g pnpm
```

#### Phase 3: Database Configuration
```bash
# 7. Configure PostgreSQL
sudo -u postgres psql <<EOF
CREATE USER postgres WITH PASSWORD '${DB_PASSWORD}' SUPERUSER;
CREATE DATABASE zerodotemail;
GRANT ALL PRIVILEGES ON DATABASE zerodotemail TO postgres;
EOF
```

#### Phase 4: Application Deployment
```bash
# 8. Clone AdminiMail repository
git clone https://github.com/Mail-0/Zero.git ~/AdminiMail
cd ~/AdminiMail

# 9. Install dependencies
pnpm install

# 10. Configure environment
cp .env.example .env
# Update .env with database URL and secrets
```

#### Phase 5: Database Schema and Application Build
```bash
# 11. Initialize database schema
pnpm db:push

# 12. Build application
pnpm build

# 13. Install and configure PM2
npm install -g pm2
pm2 start "pnpm start" --name adminimail
pm2 save
pm2 startup
```

### Post-installation Verification Steps

```bash
# Verify services are running
systemctl status postgresql
systemctl status redis-server
pm2 status

# Check application accessibility
curl -I http://localhost:3000
curl -I http://localhost:8787

# Verify database connectivity
psql -h localhost -U postgres -d zerodotemail -c "SELECT version();"

# Check Redis connectivity
redis-cli ping

# Review application logs
pm2 logs adminimail
```

### Environment Configuration Options

The installer supports several environment customizations through the script:

```bash
# Custom ports (modify install.sh before running)
FRONT_PORT=3000  # Frontend port
WORKER_PORT=8787 # Worker port

# Database configuration
DB_NAME=zerodotemail
DB_USER=postgres
# DB_PASSWORD is prompted during installation

# Application repository
REPO_URL="https://github.com/Mail-0/Zero.git"
REPO_BRANCH="main"  # Can be modified for different branches
```

### Advanced Installation Scenarios

#### Custom Port Configuration
```bash
# Edit install.sh before running
sed -i 's/3000/8080/g' install.sh  # Change frontend port
sed -i 's/8787/9090/g' install.sh  # Change worker port
```

#### Different OS Versions Support
- **Ubuntu 20.04/22.04**: Fully supported
- **Debian 10/11**: Fully supported
- **Other Debian-based**: May require package adjustments

#### Multiple Instance Installation
```bash
# For multiple instances, modify the installation directory
git clone https://github.com/Mail-0/Zero.git ~/AdminiMail-2
# Update ports and database names accordingly
```

---

## Configuration Reference

### Complete Environment Variables Documentation

The application uses the following environment variables (stored in `~/AdminiMail/.env`):

```bash
# Database Configuration
DATABASE_URL=postgresql://postgres:${PASSWORD}@localhost:5432/zerodotemail
# Format: postgresql://user:password@host:port/database

# Security Configuration
BETTER_AUTH_SECRET=<auto-generated-32-char-hex>
# Used for authentication token encryption

JWT_SECRET=<auto-generated-32-char-hex>
# Used for JSON Web Token signing

# Application URLs (auto-configured based on system)
NEXT_PUBLIC_FRONTEND_URL=http://localhost:3000
NEXT_PUBLIC_WORKER_URL=http://localhost:8787

# Optional Configuration
NODE_ENV=production
PORT=3000
WORKER_PORT=8787
```

### Configuration File Explanations

#### .env File Structure
```bash
# Required variables (set by installer)
DATABASE_URL=postgresql://postgres:password@localhost:5432/zerodotemail
BETTER_AUTH_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
JWT_SECRET=x1y2z3a4b5c6d7e8f9g0h1i2j3k4l5m6

# Optional variables (with defaults)
NEXT_PUBLIC_FRONTEND_URL=http://localhost:3000
NEXT_PUBLIC_WORKER_URL=http://localhost:8787
NODE_ENV=production
```

### Service Configuration Details

#### PostgreSQL Configuration
- **Location**: `/etc/postgresql/15/main/postgresql.conf`
- **Data Directory**: `/var/lib/postgresql/15/main`
- **Default Port**: 5432
- **Authentication**: md5 (password-based)

#### Redis Configuration
- **Location**: `/etc/redis/redis.conf`
- **Data Directory**: `/var/lib/redis`
- **Default Port**: 6379
- **Bind Address**: 127.0.0.1 (localhost only)

#### PM2 Configuration
```json
{
  "apps": [{
    "name": "adminimail",
    "script": "pnpm start",
    "cwd": "/home/user/AdminiMail",
    "env": {
      "NODE_ENV": "production"
    },
    "error_file": "~/.pm2/logs/adminimail-error.log",
    "out_file": "~/.pm2/logs/adminimail-out.log",
    "log_file": "~/.pm2/logs/adminimail.log"
  }]
}
```

### Security Configuration Guidelines

#### Database Security
```sql
-- Ensure strong password
ALTER USER postgres WITH PASSWORD 'complex_password_123!@#';

-- Restrict connections to localhost
-- Edit /etc/postgresql/15/main/pg_hba.conf
local   all   postgres   md5
host    all   postgres   127.0.0.1/32   md5
```

#### Redis Security
```bash
# Edit /etc/redis/redis.conf
bind 127.0.0.1
requirepass your_redis_password
```

#### Application Security
```bash
# Regenerate secrets for production
BETTER_AUTH_SECRET=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 32)
```

### Performance Tuning Parameters

#### PostgreSQL Tuning
```sql
-- Edit postgresql.conf
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

#### Redis Tuning
```bash
# Edit redis.conf
maxmemory 512mb
maxmemory-policy allkeys-lru
```

#### Node.js Tuning
```bash
# Set environment variables
NODE_OPTIONS="--max-old-space-size=2048"
UV_THREADPOOL_SIZE=8
```

---

## API Documentation

### Frontend API Endpoints

The AdminiMail frontend provides a web interface accessible at `http://localhost:3000`. Key endpoints include:

#### Authentication Endpoints
```
POST /api/auth/login
POST /api/auth/register
POST /api/auth/logout
GET  /api/auth/session
```

#### Email Management Endpoints
```
GET    /api/emails          # List emails
POST   /api/emails          # Send email
GET    /api/emails/:id      # Get specific email
DELETE /api/emails/:id      # Delete email
```

### Worker Service Endpoints

The worker service runs on port 8787 and handles background tasks:

#### Health Check
```bash
curl http://localhost:8787/health
# Response: { "status": "ok", "timestamp": "2025-01-16T..." }
```

#### Job Processing
```
POST /api/jobs/email        # Queue email job
GET  /api/jobs/status/:id   # Check job status
```

### Authentication Mechanisms

The application uses **Better Auth** for authentication:

1. **Session-based authentication** for web interface
2. **JWT tokens** for API access
3. **Secure cookie storage** with httpOnly flag

#### Example Authentication Flow
```bash
# 1. Login request
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'

# 2. Response with session cookie
Set-Cookie: session=abc123...; HttpOnly; Secure; SameSite=Strict

# 3. Authenticated requests
curl -H "Cookie: session=abc123..." http://localhost:3000/api/emails
```

### Request/Response Examples

#### Send Email API
```bash
# Request
curl -X POST http://localhost:3000/api/emails \
  -H "Content-Type: application/json" \
  -H "Cookie: session=abc123..." \
  -d '{
    "to": "recipient@example.com",
    "subject": "Test Email",
    "body": "This is a test email",
    "html": "<p>This is a <b>test</b> email</p>"
  }'

# Response
{
  "id": "email_123",
  "status": "queued",
  "created_at": "2025-01-16T10:00:00Z"
}
```

### Error Codes and Handling

| HTTP Code | Error Type | Description |
|-----------|------------|-------------|
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Authentication required |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 429 | Rate Limited | Too many requests |
| 500 | Server Error | Internal server error |

#### Error Response Format
```json
{
  "error": {
    "code": "INVALID_EMAIL",
    "message": "Invalid email address format",
    "details": {
      "field": "to",
      "value": "invalid-email"
    }
  }
}
```

---

## Advanced Usage

### Custom Deployment Scenarios

#### Multi-Server Deployment
For production environments, consider separating services across multiple servers:

```bash
# Database Server
sudo ./install.sh --database-only

# Application Server
sudo ./install.sh --app-only --db-host=db.example.com

# Redis Server
sudo ./install.sh --redis-only
```

#### Docker Deployment
Create a Dockerfile for containerized deployment:

```dockerfile
FROM node:20-slim
RUN apt-get update && apt-get install -y postgresql-client redis-tools
COPY . /app
WORKDIR /app
RUN npm install -g pnpm pm2
RUN pnpm install && pnpm build
CMD ["pm2-runtime", "start", "ecosystem.config.js"]
```

### Scaling Considerations

#### Horizontal Scaling
```bash
# Load balancer configuration (nginx)
upstream adminimail_frontend {
    server 10.0.1.10:3000;
    server 10.0.1.11:3000;
    server 10.0.1.12:3000;
}

upstream adminimail_worker {
    server 10.0.2.10:8787;
    server 10.0.2.11:8787;
}
```

#### Database Scaling
```sql
-- Read replicas for PostgreSQL
CREATE SUBSCRIPTION adminimail_replica
CONNECTION 'host=master.db.example.com port=5432 user=replicator dbname=zerodotemail'
PUBLICATION adminimail_pub;
```

#### Vertical Scaling
```bash
# PM2 cluster mode
pm2 start ecosystem.config.js --env production
```

```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'adminimail',
    script: 'pnpm start',
    instances: 'max',
    exec_mode: 'cluster'
  }]
};
```

### Backup and Restore Procedures

#### Database Backup
```bash
#!/bin/bash
# backup-database.sh
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h localhost -U postgres zerodotemail > backup_${DATE}.sql
gzip backup_${DATE}.sql
```

#### Application Backup
```bash
#!/bin/bash
# backup-application.sh
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf adminimail_backup_${DATE}.tar.gz -C ~ AdminiMail
```

#### Restore Procedures
```bash
# Restore database
gunzip backup_20250116_120000.sql.gz
psql -h localhost -U postgres zerodotemail < backup_20250116_120000.sql

# Restore application
tar -xzf adminimail_backup_20250116_120000.tar.gz -C ~
cd ~/AdminiMail
pnpm install
pm2 restart adminimail
```

### Migration Guidelines

#### Version Updates
```bash
#!/bin/bash
# update-adminimail.sh
cd ~/AdminiMail
pm2 stop adminimail

# Backup current version
cp -r ~/AdminiMail ~/AdminiMail_backup_$(date +%Y%m%d)

# Update code
git pull origin main
pnpm install
pnpm build

# Update database schema
pnpm db:push

# Restart services
pm2 start adminimail
pm2 save
```

#### Database Migrations
```bash
# Manual migration example
psql -h localhost -U postgres zerodotemail <<EOF
-- Migration script
ALTER TABLE users ADD COLUMN last_login TIMESTAMP;
CREATE INDEX idx_users_last_login ON users(last_login);
EOF
```

### Integration with External Services

#### SMTP Configuration
```bash
# Add to .env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_SECURE=true
```

#### Webhook Integration
```bash
# Configure webhooks in .env
WEBHOOK_URL=https://your-webhook-endpoint.com
WEBHOOK_SECRET=your-webhook-secret
```

---

## Troubleshooting Guide

### Common Installation Issues and Solutions

#### Issue: Node.js Installation Fails
```bash
# Error: nvm command not found
# Solution: Manual NVM installation
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
```

#### Issue: PostgreSQL Connection Refused
```bash
# Error: Connection refused on port 5432
# Solution: Check PostgreSQL service
sudo systemctl status postgresql
sudo systemctl start postgresql

# Verify port binding
sudo netstat -tlnp | grep 5432
```

#### Issue: Permission Denied Errors
```bash
# Error: Permission denied during installation
# Solution: Ensure proper sudo privileges
sudo chown -R $USER:$USER ~/AdminiMail
sudo chmod +x install.sh
```

### Service Debugging Techniques

#### PostgreSQL Debugging
```bash
# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-15-main.log

# Test database connection
psql -h localhost -U postgres -d zerodotemail -c "SELECT 1;"

# Check active connections
psql -h localhost -U postgres -c "SELECT * FROM pg_stat_activity;"
```

#### Redis Debugging
```bash
# Check Redis status
redis-cli ping

# Monitor Redis operations
redis-cli monitor

# Check Redis logs
sudo tail -f /var/log/redis/redis-server.log
```

#### PM2 Debugging
```bash
# Check PM2 status
pm2 status

# View detailed logs
pm2 logs adminimail --lines 100

# Monitor resource usage
pm2 monit

# Restart with verbose logging
pm2 restart adminimail --log-type
```

### Log File Locations and Analysis

#### System Logs
```bash
# Installation logs
/var/log/apt/history.log
/var/log/dpkg.log

# Service logs
/var/log/postgresql/postgresql-15-main.log
/var/log/redis/redis-server.log
```

#### Application Logs
```bash
# PM2 logs
~/.pm2/logs/adminimail-out.log
~/.pm2/logs/adminimail-error.log

# Application logs
~/AdminiMail/logs/application.log
```

#### Log Analysis Examples
```bash
# Check for database connection issues
grep "connection" ~/.pm2/logs/adminimail-error.log

# Monitor error patterns
tail -f ~/.pm2/logs/adminimail-error.log | grep -i error

# Analyze performance issues
grep "slow" /var/log/postgresql/postgresql-15-main.log
```

### Performance Troubleshooting

#### High CPU Usage
```bash
# Check process CPU usage
top -p $(pgrep -f adminimail)

# PM2 process monitoring
pm2 monit

# Solution: Enable cluster mode
pm2 delete adminimail
pm2 start ecosystem.config.js
```

#### Memory Issues
```bash
# Check memory usage
free -h
ps aux | grep node

# Solution: Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"
pm2 restart adminimail
```

#### Database Performance
```sql
-- Check slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC LIMIT 10;

-- Check database size
SELECT pg_size_pretty(pg_database_size('zerodotemail'));
```

### Database Connection Issues

#### Connection Pool Exhaustion
```bash
# Check active connections
psql -h localhost -U postgres -c "
SELECT count(*) as active_connections 
FROM pg_stat_activity 
WHERE state = 'active';"

# Solution: Increase connection limit
# Edit /etc/postgresql/15/main/postgresql.conf
max_connections = 200
```

#### Authentication Failures
```bash
# Check authentication method
sudo cat /etc/postgresql/15/main/pg_hba.conf

# Reset password
sudo -u postgres psql
ALTER USER postgres PASSWORD 'new_password';
```

### Port Conflicts Resolution

#### Check Port Usage
```bash
# Check if ports are in use
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :8787

# Find processes using ports
sudo lsof -i :3000
sudo lsof -i :8787
```

#### Resolve Port Conflicts
```bash
# Kill conflicting processes
sudo kill -9 $(sudo lsof -t -i:3000)

# Change application ports
# Edit ~/AdminiMail/.env
PORT=8080
WORKER_PORT=9090
```

---

## Development Guide

### Local Development Setup

#### Prerequisites for Development
```bash
# Install development tools
sudo apt install -y git curl build-essential

# Clone the installer repository
git clone https://github.com/iSundram/AdminiMail-installer.git
cd AdminiMail-installer
```

#### Development Environment Configuration
```bash
# Create development branch
git checkout -b feature/new-feature

# Make script executable
chmod +x install.sh

# Test installation in development mode
./install.sh --dev-mode
```

### Contributing Guidelines

#### Code Style and Standards
```bash
# Shell script linting
sudo apt install shellcheck
shellcheck install.sh

# Follow POSIX shell standards
# Use set -euo pipefail for error handling
# Add comments for complex operations
```

#### Git Workflow
```bash
# 1. Fork the repository
# 2. Create feature branch
git checkout -b feature/description

# 3. Make changes and test
# 4. Commit with descriptive messages
git commit -m "feat: add support for Ubuntu 24.04"

# 5. Push and create pull request
git push origin feature/description
```

#### Testing Procedures
```bash
# Test on different OS versions
docker run -it ubuntu:20.04 bash
docker run -it ubuntu:22.04 bash
docker run -it debian:11 bash

# Test with different configurations
# Test rollback procedures
# Test upgrade scenarios
```

### Code Structure Overview

#### Repository Structure
```
AdminiMail-installer/
├── install.sh          # Main installation script
├── README.md           # User documentation
├── docs.md            # Technical documentation
├── LICENSE            # MIT license
└── .git/              # Git repository data
```

#### Install Script Structure
```bash
# install.sh breakdown
├── Header and license
├── ASCII art and introduction
├── User input collection
├── System preparation
├── Node.js installation
├── Database setup
├── Application deployment
├── Service configuration
└── Completion message
```

### Testing Procedures

#### Unit Testing (Manual)
```bash
# Test individual components
test_nvm_installation() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    source ~/.bashrc
    nvm --version
}

test_postgresql_setup() {
    sudo systemctl status postgresql
    psql -h localhost -U postgres -c "SELECT version();"
}
```

#### Integration Testing
```bash
# Full installation test
./test-full-installation.sh

# Rollback test
./test-rollback.sh

# Upgrade test
./test-upgrade.sh
```

#### Automated Testing Framework
```bash
#!/bin/bash
# tests/integration-test.sh

# Setup test environment
setup_test_env() {
    docker run -d --name test-container ubuntu:22.04
}

# Run installation
run_installation_test() {
    docker exec test-container ./install.sh <<< "test_password"
}

# Verify installation
verify_installation() {
    docker exec test-container pm2 status
    docker exec test-container curl -I http://localhost:3000
}

# Cleanup
cleanup_test_env() {
    docker stop test-container
    docker rm test-container
}
```

### Build Process Explanation

Since this is a shell script installer, the "build" process involves:

1. **Script Validation**: Using shellcheck for syntax validation
2. **Documentation Generation**: Auto-generating documentation from comments
3. **Testing**: Running integration tests across different environments
4. **Packaging**: Creating release archives with checksums

```bash
# Build pipeline example
#!/bin/bash
# build.sh

# Validate shell script
shellcheck install.sh

# Generate documentation
# (if using automated documentation tools)

# Run tests
./tests/run-all-tests.sh

# Create release package
tar -czf adminimail-installer-v1.0.0.tar.gz install.sh README.md docs.md LICENSE
sha256sum adminimail-installer-v1.0.0.tar.gz > checksums.txt
```

---

## Maintenance & Operations

### Regular Maintenance Tasks

#### Daily Maintenance
```bash
#!/bin/bash
# daily-maintenance.sh

# Check service status
pm2 status
systemctl status postgresql
systemctl status redis-server

# Check disk space
df -h | grep -E "/$|/var|/tmp"

# Check log file sizes
find ~/.pm2/logs -name "*.log" -size +100M

# Backup logs
logrotate /etc/logrotate.d/adminimail
```

#### Weekly Maintenance
```bash
#!/bin/bash
# weekly-maintenance.sh

# Update system packages
sudo apt update && sudo apt upgrade -y

# Clean package cache
sudo apt autoremove -y
sudo apt autoclean

# Database maintenance
psql -h localhost -U postgres zerodotemail -c "VACUUM ANALYZE;"

# Check for security updates
unattended-upgrade --dry-run
```

#### Monthly Maintenance
```bash
#!/bin/bash
# monthly-maintenance.sh

# Full database backup
pg_dump -h localhost -U postgres zerodotemail | gzip > monthly_backup_$(date +%Y%m).sql.gz

# Application backup
tar -czf monthly_app_backup_$(date +%Y%m).tar.gz ~/AdminiMail

# Clean old backups (keep 6 months)
find ~/backups -name "*.sql.gz" -mtime +180 -delete
find ~/backups -name "*.tar.gz" -mtime +180 -delete

# Security audit
lynis audit system
```

### Update Procedures

#### Application Updates
```bash
#!/bin/bash
# update-application.sh

echo "Starting AdminiMail update..."

# Stop application
pm2 stop adminimail

# Backup current version
cp -r ~/AdminiMail ~/AdminiMail_backup_$(date +%Y%m%d)

# Update application
cd ~/AdminiMail
git stash  # Save local changes
git pull origin main

# Update dependencies
pnpm install

# Run database migrations
pnpm db:push

# Build application
pnpm build

# Start application
pm2 start adminimail

echo "Update completed successfully!"
```

#### System Updates
```bash
#!/bin/bash
# system-update.sh

# Update system packages
sudo apt update
sudo apt upgrade -y

# Update Node.js (if needed)
nvm install 20 --reinstall-packages-from=current
nvm alias default 20

# Update global packages
npm update -g pnpm pm2

# Restart services
sudo systemctl restart postgresql
sudo systemctl restart redis-server
pm2 restart all
```

### Monitoring and Alerting

#### System Monitoring Script
```bash
#!/bin/bash
# monitor.sh

# Check service availability
check_service() {
    local service=$1
    local port=$2
    
    if curl -f -s http://localhost:$port/health > /dev/null; then
        echo "✅ $service is healthy"
    else
        echo "❌ $service is down"
        # Send alert
        mail -s "$service is down" admin@example.com < /dev/null
    fi
}

check_service "Frontend" 3000
check_service "Worker" 8787

# Check database
if psql -h localhost -U postgres -d zerodotemail -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Database is healthy"
else
    echo "❌ Database is down"
fi

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "❌ Disk usage is high: ${DISK_USAGE}%"
fi
```

#### PM2 Monitoring
```bash
# Install PM2 monitoring
pm2 install pm2-logrotate

# Configure log rotation
pm2 set pm2-logrotate:max_size 100M
pm2 set pm2-logrotate:retain 7

# Setup PM2 monitoring dashboard
pm2 plus
```

### Performance Optimization

#### Database Optimization
```sql
-- Optimize PostgreSQL configuration
-- Edit /etc/postgresql/15/main/postgresql.conf

-- Memory settings
shared_buffers = 25% of total RAM
effective_cache_size = 75% of total RAM
work_mem = Total RAM / max_connections

-- Connection settings
max_connections = 100
```

#### Application Optimization
```bash
# Node.js optimization
export NODE_OPTIONS="--max-old-space-size=2048"
export UV_THREADPOOL_SIZE=8

# PM2 cluster mode
pm2 delete adminimail
pm2 start ecosystem.config.js --env production
```

#### Redis Optimization
```bash
# Edit /etc/redis/redis.conf
maxmemory 512mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

### Security Updates

#### Automated Security Updates
```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Configure automatic security updates
sudo dpkg-reconfigure -plow unattended-upgrades

# Edit /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
```

#### Manual Security Checks
```bash
#!/bin/bash
# security-check.sh

# Check for security updates
apt list --upgradable | grep -i security

# Check for vulnerable packages
sudo apt install debsecan
debsecan --format packages --only-fixed

# Check file permissions
find ~/AdminiMail -type f -perm /o+w
find ~/.pm2 -type f -perm /o+w

# Check for suspicious processes
ps aux | grep -v "^root\|^$USER" | awk '{print $1}' | sort | uniq
```

---

## Security Documentation

### Security Best Practices

#### System Security
```bash
# Firewall configuration
sudo ufw enable
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow 3000  # Frontend
sudo ufw allow 8787  # Worker (optional, for internal access)

# Disable root login
sudo passwd -l root

# Configure fail2ban
sudo apt install fail2ban
sudo systemctl enable fail2ban
```

#### Network Security
```bash
# Restrict PostgreSQL access
# Edit /etc/postgresql/15/main/pg_hba.conf
local   all   postgres   md5
host    all   postgres   127.0.0.1/32   md5
# Remove any 0.0.0.0/0 entries

# Restrict Redis access
# Edit /etc/redis/redis.conf
bind 127.0.0.1
protected-mode yes
```

### Authentication Setup

#### Multi-Factor Authentication
```bash
# Add to .env for enhanced security
ENABLE_2FA=true
2FA_ISSUER=AdminiMail
2FA_WINDOW=2
```

#### Session Security
```bash
# Configure secure session settings
SESSION_SECURE=true
SESSION_HTTPONLY=true
SESSION_SAMESITE=Strict
SESSION_MAXAGE=86400  # 24 hours
```

#### API Key Management
```bash
# Generate API keys
API_KEY=$(openssl rand -hex 32)
echo "API_KEY=$API_KEY" >> .env

# Rotate keys regularly
./scripts/rotate-api-keys.sh
```

### SSL/TLS Configuration

#### Let's Encrypt with Nginx
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d mail.yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

#### Nginx Configuration
```nginx
# /etc/nginx/sites-available/adminimail
server {
    listen 443 ssl http2;
    server_name mail.yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/mail.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mail.yourdomain.com/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # Frontend proxy
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Worker API proxy
    location /api/worker {
        proxy_pass http://localhost:8787;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name mail.yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

### Firewall Configuration

#### UFW (Uncomplicated Firewall)
```bash
# Basic firewall setup
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow essential services
sudo ufw allow ssh
sudo ufw allow 80   # HTTP
sudo ufw allow 443  # HTTPS

# Application specific (if exposing directly)
sudo ufw allow from 10.0.0.0/8 to any port 3000
sudo ufw allow from 10.0.0.0/8 to any port 8787

# Enable firewall
sudo ufw enable
```

#### Advanced Firewall Rules
```bash
# Rate limiting for SSH
sudo ufw limit ssh

# Allow specific IP ranges
sudo ufw allow from 192.168.1.0/24 to any port 22

# Block common attack patterns
sudo ufw deny from 192.168.1.100  # Block specific IP
```

### Database Security

#### PostgreSQL Security Hardening
```sql
-- Create application-specific user (instead of using postgres superuser)
CREATE USER adminimail_app WITH PASSWORD 'strong_password_here';
GRANT CONNECT ON DATABASE zerodotemail TO adminimail_app;
GRANT USAGE ON SCHEMA public TO adminimail_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO adminimail_app;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO adminimail_app;
```

#### Database Connection Security
```bash
# Update .env to use application user
DATABASE_URL=postgresql://adminimail_app:strong_password@localhost:5432/zerodotemail

# Enable SSL for database connections
# Edit postgresql.conf
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
```

#### Data Encryption
```sql
-- Enable data encryption for sensitive fields
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Example encrypted field
ALTER TABLE users ADD COLUMN encrypted_data TEXT;
UPDATE users SET encrypted_data = pgp_sym_encrypt(sensitive_data, 'encryption_key');
```

### Application Security Measures

#### Input Validation
```javascript
// Example validation middleware (in application code)
const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
};

const sanitizeInput = (input) => {
    return input.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
};
```

#### Security Headers
```bash
# Add to Nginx configuration
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline';" always;
```

#### Secrets Management
```bash
# Use environment variables for secrets
# Never commit secrets to version control

# Rotate secrets regularly
#!/bin/bash
# rotate-secrets.sh
NEW_AUTH_SECRET=$(openssl rand -hex 32)
NEW_JWT_SECRET=$(openssl rand -hex 32)

sed -i "s/BETTER_AUTH_SECRET=.*/BETTER_AUTH_SECRET=$NEW_AUTH_SECRET/" .env
sed -i "s/JWT_SECRET=.*/JWT_SECRET=$NEW_JWT_SECRET/" .env

pm2 restart adminimail
```

#### Security Auditing
```bash
# Regular security audits
#!/bin/bash
# security-audit.sh

# Check for security updates
apt list --upgradable | grep -i security

# Scan for vulnerabilities
sudo apt install lynis
sudo lynis audit system

# Check open ports
nmap -sT -O localhost

# Check file permissions
find ~/AdminiMail -type f -perm /o+w
find ~/.pm2 -type f -perm /o+w

# Check for suspicious processes
ps aux | awk '{print $11}' | sort | uniq -c | sort -nr
```

---

## FAQ & Common Scenarios

### Frequently Asked Questions

#### Q: Can I run AdminiMail on a server with existing PostgreSQL?
**A:** Yes, but ensure the existing PostgreSQL version is 15 or later. The installer will create a new database `zerodotemail` and won't interfere with existing databases.

```bash
# Check PostgreSQL version
psql --version

# If version is < 15, upgrade first
sudo apt install postgresql-15
```

#### Q: How do I change the default ports after installation?
**A:** Edit the environment file and restart the application:

```bash
cd ~/AdminiMail
# Edit .env file
nano .env
# Change PORT and WORKER_PORT values

# Restart application
pm2 restart adminimail
```

#### Q: Can I install multiple instances of AdminiMail?
**A:** Yes, but you'll need to modify the installation directory and ports:

```bash
# Clone to different directory
git clone https://github.com/Mail-0/Zero.git ~/AdminiMail-2

# Create separate database
sudo -u postgres createdb zerodotemail2

# Update .env with different ports and database
# Start with different PM2 app name
pm2 start "pnpm start" --name adminimail-2
```

#### Q: How do I completely uninstall AdminiMail?
**A:** Follow these steps to remove everything:

```bash
# Stop and remove PM2 process
pm2 delete adminimail
pm2 save

# Remove application directory
rm -rf ~/AdminiMail

# Remove database (optional)
sudo -u postgres dropdb zerodotemail

# Remove packages (optional, may affect other apps)
sudo apt remove nodejs postgresql redis-server -y
```

#### Q: Why is the installation failing with "permission denied"?
**A:** Ensure you're running the installer as root or with sudo:

```bash
# Correct way to run
sudo ./install.sh

# Or with curl
curl -fsSL https://raw.githubusercontent.com/iSundram/AdminiMail-installer/main/install.sh | sudo bash
```

### Common Use Cases

#### Corporate Email Server Setup
```bash
# 1. Install on corporate network
sudo ./install.sh

# 2. Configure corporate domain
# Edit .env
DOMAIN=mail.company.com
SMTP_HOST=smtp.company.com

# 3. Setup SSL with company certificate
# Copy certificates to nginx
sudo cp company.crt /etc/ssl/certs/
sudo cp company.key /etc/ssl/private/

# 4. Configure firewall for corporate network
sudo ufw allow from 192.168.0.0/16 to any port 3000
```

#### Development Environment Setup
```bash
# 1. Clone installer for development
git clone https://github.com/iSundram/AdminiMail-installer.git
cd AdminiMail-installer

# 2. Create development version
cp install.sh install-dev.sh

# 3. Modify for development (different ports, debug mode)
sed -i 's/3000/3001/g' install-dev.sh
sed -i 's/8787/8788/g' install-dev.sh

# 4. Run development installation
./install-dev.sh
```

#### Multi-Tenant Setup
```bash
# Tenant 1
./install.sh
# Database: zerodotemail_tenant1
# Ports: 3000, 8787

# Tenant 2
# Modify install.sh for different database and ports
sed -i 's/zerodotemail/zerodotemail_tenant2/g' install.sh
sed -i 's/3000/3010/g' install.sh
sed -i 's/8787/8797/g' install.sh
./install.sh
```

### Integration Examples

#### Integration with Existing Nginx
```nginx
# Add to existing nginx.conf
upstream adminimail {
    server localhost:3000;
}

server {
    listen 80;
    server_name mail.example.com;
    
    location / {
        proxy_pass http://adminimail;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### Integration with Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  adminimail:
    build: .
    ports:
      - "3000:3000"
      - "8787:8787"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/zerodotemail
    depends_on:
      - db
      - redis
      
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: zerodotemail
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      
  redis:
    image: redis:6-alpine
    
volumes:
  postgres_data:
```

#### Integration with Monitoring (Prometheus)
```bash
# Install PM2 metrics
pm2 install pm2-prometheus-exporter

# Configure Prometheus
# Add to prometheus.yml
scrape_configs:
  - job_name: 'adminimail'
    static_configs:
      - targets: ['localhost:9209']
```

### Third-Party Service Setup

#### Email Provider Integration
```bash
# SendGrid integration
echo "SENDGRID_API_KEY=your_api_key" >> .env
echo "SENDGRID_FROM_EMAIL=noreply@yourdomain.com" >> .env

# Mailgun integration
echo "MAILGUN_API_KEY=your_api_key" >> .env
echo "MAILGUN_DOMAIN=mg.yourdomain.com" >> .env

# AWS SES integration
echo "AWS_ACCESS_KEY_ID=your_access_key" >> .env
echo "AWS_SECRET_ACCESS_KEY=your_secret_key" >> .env
echo "AWS_REGION=us-east-1" >> .env
```

#### Cloud Storage Integration
```bash
# AWS S3 for file uploads
echo "AWS_S3_BUCKET=your-bucket-name" >> .env
echo "AWS_S3_REGION=us-east-1" >> .env

# Google Cloud Storage
echo "GCS_BUCKET=your-bucket-name" >> .env
echo "GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json" >> .env
```

#### Authentication Provider Integration
```bash
# Google OAuth
echo "GOOGLE_CLIENT_ID=your_client_id" >> .env
echo "GOOGLE_CLIENT_SECRET=your_client_secret" >> .env

# GitHub OAuth
echo "GITHUB_CLIENT_ID=your_client_id" >> .env
echo "GITHUB_CLIENT_SECRET=your_client_secret" >> .env

# LDAP/Active Directory
echo "LDAP_URL=ldap://ldap.company.com" >> .env
echo "LDAP_BIND_DN=cn=admin,dc=company,dc=com" >> .env
echo "LDAP_BIND_CREDENTIALS=admin_password" >> .env
```

#### Backup Service Integration
```bash
# AWS S3 backup
#!/bin/bash
# backup-to-s3.sh
DATE=$(date +%Y%m%d_%H%M%S)

# Database backup
pg_dump -h localhost -U postgres zerodotemail | gzip > backup_${DATE}.sql.gz

# Upload to S3
aws s3 cp backup_${DATE}.sql.gz s3://your-backup-bucket/database/

# Application backup
tar -czf app_backup_${DATE}.tar.gz ~/AdminiMail
aws s3 cp app_backup_${DATE}.tar.gz s3://your-backup-bucket/application/

# Cleanup local backups
rm backup_${DATE}.sql.gz app_backup_${DATE}.tar.gz
```

---

## Conclusion

This comprehensive documentation provides detailed technical information for the AdminiMail-installer project. For quick setup, refer to the [README.md](README.md). For specific implementation questions, consult the relevant sections above.

For support and contributions, please visit the [GitHub repository](https://github.com/iSundram/AdminiMail-installer).

---

*Last updated: January 2025*
*Version: 1.0.0*