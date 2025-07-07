#!/bin/bash

#──────────────────────────────────────────────
# 📬 AdminiMail – Automated Installer Script
# Copyright (c) 2025 iSundram
# Licensed under the MIT License
#──────────────────────────────────────────────

set -euo pipefail

# ASCII Art Logo
cat << "EOF"

██████╗  █████╗ ██████╗ ███╗   ███╗██╗███╗   ███╗ █████╗ ██╗██╗     
██╔══██╗██╔══██╗██╔══██╗████╗ ████║██║████╗ ████║██╔══██╗██║██║     
██████╔╝███████║██████╔╝██╔████╔██║██║██╔████╔██║███████║██║██║     
██╔═══╝ ██╔══██║██╔═══╝ ██║╚██╔╝██║██║██║╚██╔╝██║██╔══██║██║██║     
██║     ██║  ██║██║     ██║ ╚═╝ ██║██║██║ ╚═╝ ██║██║  ██║██║███████╗
╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚══════╝
                                                                    
EOF

echo "📦 Starting AdminiMail installation..."
sleep 2

# Ask for Postgres password
read -s -p "🔐 Enter Postgres password to use: " DB_PASSWORD
echo

# Prepare environment
echo "🔧 Updating packages and installing system tools..."
apt update -y && apt install -y curl git build-essential libpq-dev postgresql postgresql-contrib redis-server

# Install Node.js v20 LTS using NVM
if ! command -v nvm &> /dev/null; then
  echo "⬇️ Installing Node.js v20 with NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
fi

nvm install 20
nvm use 20
nvm alias default 20

# Install pnpm globally
echo "⬇️ Installing pnpm..."
npm install -g pnpm

# Create adminimail user DB
echo "🗃 Setting up PostgreSQL user and database..."
sudo -u postgres psql <<EOF
CREATE USER postgres WITH PASSWORD '${DB_PASSWORD}' SUPERUSER;
CREATE DATABASE zerodotemail;
GRANT ALL PRIVILEGES ON DATABASE zerodotemail TO postgres;
EOF

# Clone AdminiMail (Zero) repository
echo "📁 Cloning AdminiMail repository..."
git clone https://github.com/Mail-0/Zero.git ~/AdminiMail
cd ~/AdminiMail

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Create .env from example
cp .env.example .env

# Update .env with DB and secrets
echo "🔐 Configuring .env..."
sed -i "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@localhost:5432/zerodotemail|" .env
sed -i "s|^BETTER_AUTH_SECRET=.*|BETTER_AUTH_SECRET=$(openssl rand -hex 32)|" .env
sed -i "s|^JWT_SECRET=.*|JWT_SECRET=$(openssl rand -hex 32)|" .env

# Setup DB schema
echo "🧱 Initializing database schema..."
pnpm db:push

# Build and start with PM2
echo "🚀 Starting AdminiMail with PM2..."
pnpm build
npm install -g pm2
pm2 start "pnpm start" --name adminimail
pm2 save

echo
echo "🎉 AdminiMail installation complete!"
echo
echo "• Front-end:  http://<your-ip>:3000"
echo "• Worker:     http://<your-ip>:8787"
echo
echo "🛠 You can view logs using: pm2 logs adminimail"
