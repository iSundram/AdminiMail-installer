# AdminiMail-installer Technical Documentation

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

## Technical Architecture

### System Architecture Overview

AdminiMail follows a microservices architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                    Load Balancer                        │
│                   (Nginx/Reverse Proxy)                 │
└─────────────────┬───────────────────────────────────────┘
                  │
         ┌────────▼────────┐
         │   Frontend App  │
         │   (React/Next)  │
         │   Port 3000     │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │   Worker API    │
         │   (Node.js)     │
         │   Port 8787     │
         └────────┬────────┘
                  │
    ┌─────────────▼─────────────┐
    │       Data Layer          │
    │  ┌─────────┐ ┌─────────┐  │
    │  │PostgreSQL│ │  Redis  │  │
    │  │Port 5432 │ │Port 6379│  │
    │  └─────────┘ └─────────┘  │
    └───────────────────────────┘
```

### Component Responsibilities

#### Frontend Application (Port 3000)
- **User Interface**: React-based web application
- **Campaign Management**: Create, edit, and manage email campaigns
- **Subscriber Management**: Import, export, and segment subscribers
- **Analytics Dashboard**: Campaign performance metrics
- **Template Designer**: Visual email template editor
- **User Authentication**: Login, registration, and session management

#### Worker Service (Port 8787)
- **Email Queue Processing**: Background job processing for email sending
- **SMTP Integration**: Communication with email service providers
- **Template Rendering**: Convert templates to HTML emails
- **Delivery Tracking**: Monitor email delivery status
- **Rate Limiting**: Manage sending rates per provider limits
- **Webhook Handling**: Process bounce and delivery notifications

#### PostgreSQL Database
- **User Data**: Account information and authentication
- **Campaign Data**: Email campaigns, templates, and content
- **Subscriber Lists**: Contact information and segments
- **Analytics Data**: Email performance metrics
- **System Configuration**: Application settings and preferences

#### Redis Cache
- **Session Storage**: User session data
- **Job Queue**: Background task queue for email processing
- **Rate Limiting**: API rate limit counters
- **Temporary Data**: Cache for frequently accessed data

## Installation Deep Dive

### Pre-installation System Checks

The installer performs comprehensive system validation:

```bash
#!/bin/bash
# System compatibility check
check_system() {
    # OS Detection
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ $ID != "ubuntu" && $ID != "debian" ]]; then
            echo "❌ Unsupported OS: $ID"
            exit 1
        fi
    fi
    
    # Memory check
    total_mem=$(free -m | awk 'NR==2{printf "%.0f", $2}')
    if [[ $total_mem -lt 1800 ]]; then
        echo "⚠️  Warning: Low memory ($total_mem MB). 2GB+ recommended"
    fi
    
    # Disk space check
    available_space=$(df / | awk 'NR==2{print $4}')
    if [[ $available_space -lt 10485760 ]]; then # 10GB in KB
        echo "❌ Insufficient disk space. 10GB+ required"
        exit 1
    fi
}
```

### Detailed Installation Flow

#### Phase 1: System Preparation
```bash
# Update package repositories
apt update -y

# Install essential packages
apt install -y \
    curl \
    git \
    build-essential \
    libpq-dev \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
```

#### Phase 2: Runtime Environment
```bash
# Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Load NVM in current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 20 LTS
nvm install 20
nvm use 20
nvm alias default 20

# Install pnpm package manager
npm install -g pnpm@latest
```

#### Phase 3: Database Services
```bash
# Install PostgreSQL 15
apt install -y postgresql-15 postgresql-contrib-15

# Install Redis 6
apt install -y redis-server

# Configure PostgreSQL
sudo -u postgres psql << EOF
CREATE USER postgres WITH PASSWORD '${DB_PASSWORD}' SUPERUSER;
CREATE DATABASE zerodotemail;
GRANT ALL PRIVILEGES ON DATABASE zerodotemail TO postgres;
