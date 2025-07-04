#!/usr/bin/env bash
###############################################################################
#  AdminiMail One-Click Installer
#  Author : iSundram
#  URL    : https://github.com/iSundram/AdminiMail-installer
#  License: MIT
###############################################################################
set -euo pipefail
IFS=$'\n\t'

#---------------------------  Configuration  ----------------------------------
APP_REPO="https://github.com/iSundram/AdminiMail" # your code repo
APP_DIR="$HOME/AdminiMail"                        # target directory
DB_NAME="adminimail"
NODE_VERSION="lts/*"                              # Node 20 LTS
FRONT_PORT=3000
WORKER_PORT=8787
#-----------------------------------------------------------------------------#

#-- COLORS --------------------------------------------------------------------
C_RESET="\e[0m"; C_BOLD="\e[1m"; C_GREEN="\e[32m"; C_YELLOW="\e[33m"; C_RED="\e[31m"
print()  { printf "${C_GREEN}${1}${C_RESET}\n"; }
warn()   { printf "${C_YELLOW}⚠️  %s${C_RESET}\n" "$1"; }
die()    { printf "${C_RED}✖ %s${C_RESET}\n" "$1"; exit 1; }

#-- ROOT CHECK ----------------------------------------------------------------
[[ $EUID -ne 0 ]] && die "Run as root (sudo)."

#-- PROMPTS -------------------------------------------------------------------
read -rp "📧  Enter a strong Postgres password: " PG_PASS
read -rp "🌿  Git branch to deploy [main]: " GIT_BRANCH
GIT_BRANCH=${GIT_BRANCH:-main}

echo -e "${C_BOLD}\n🔧  Installing system dependencies…${C_RESET}"
apt update -y
apt install -y curl git build-essential postgresql postgresql-contrib redis-server ufw

#-- NVM + NODE ----------------------------------------------------------------
if ! command -v nvm &>/dev/null; then
  print "⬇️  Installing NVM…"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
# shellcheck disable=SC1091
source "$HOME/.nvm/nvm.sh"
nvm install "$NODE_VERSION" && nvm alias default "$NODE_VERSION"
print "✅  Node $(node -v) / npm $(npm -v)"

#-- PNPM ----------------------------------------------------------------------
if ! command -v pnpm &>/dev/null; then
  print "⬇️  Installing pnpm…"
  npm install -g pnpm@latest
fi
print "✅  pnpm $(pnpm -v)"

#-- POSTGRES + REDIS -----------------------------------------------------------
sudo -u postgres psql -tc "ALTER USER postgres WITH PASSWORD '$PG_PASS';"
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';" | grep -q 1 \
  || sudo -u postgres createdb "$DB_NAME"
systemctl enable --now redis-server

#-- CLONE / UPDATE APP ---------------------------------------------------------
if [[ -d $APP_DIR/.git ]]; then
  print "🔄  Repo exists – pulling latest $GIT_BRANCH…"
  git -C "$APP_DIR" fetch origin "$GIT_BRANCH"
  git -C "$APP_DIR" checkout "$GIT_BRANCH"
  git -C "$APP_DIR" pull
else
  print "⬇️  Cloning AdminiMail source…"
  git clone --branch "$GIT_BRANCH" "$APP_REPO" "$APP_DIR"
fi

#-- ENV FILE -------------------------------------------------------------------
print "🔑  Generating .env…"
cp -n "$APP_DIR/.env.example" "$APP_DIR/.env"
sed -i "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://postgres:${PG_PASS}@localhost:5432/${DB_NAME}|" "$APP_DIR/.env"
sed -i "s|^REDIS_URL=.*|REDIS_URL=redis://localhost:6379|" "$APP_DIR/.env"
sed -i "s|^NEXTAUTH_SECRET=.*|NEXTAUTH_SECRET=$(openssl rand -hex 32)|" "$APP_DIR/.env"
sed -i "s|^NEXTAUTH_URL=.*|NEXTAUTH_URL=http://localhost:${FRONT_PORT}|" "$APP_DIR/.env"
# ensure frontend/backend URLs
grep -q '^VITE_PUBLIC_APP_URL=' "$APP_DIR/.env" \
  || echo "VITE_PUBLIC_APP_URL=http://localhost:${FRONT_PORT}" >> "$APP_DIR/.env"
grep -q '^VITE_PUBLIC_BACKEND_URL=' "$APP_DIR/.env" \
  || echo "VITE_PUBLIC_BACKEND_URL=http://localhost:${WORKER_PORT}" >> "$APP_DIR/.env"

#-- INSTALL & BUILD ------------------------------------------------------------
cd "$APP_DIR"
print "📦  Installing dependencies (this may take a while)…"
pnpm install --silent

print "🗄️  Applying database schema…"
pnpm db:push --silent

print "🔧  Building production bundle…"
pnpm build --silent

#-- PM2 LAUNCH -----------------------------------------------------------------
npm install -g pm2 &>/dev/null
pm2 start "pnpm start" --name adminimail
pm2 save
pm2 startup -u "$SUDO_USER" --silent

#-- FIREWALL (optional) --------------------------------------------------------
read -rp "🛡  Open UFW ports ${FRONT_PORT} and ${WORKER_PORT}? [y/N]: " OPEN_FW
if [[ $OPEN_FW =~ ^[Yy]$ ]]; then
  ufw allow "$FRONT_PORT"
  ufw allow "$WORKER_PORT"
  ufw enable
fi

#-- FOOTER ---------------------------------------------------------------------
cat <<EOF

${C_BOLD}${C_GREEN}🎉  AdminiMail installation complete!${C_RESET}

• Front-end:  http://<your-server-ip>:${FRONT_PORT}
• Worker:     http://<your-server-ip>:${WORKER_PORT}

PM2 commands:
  pm2 status              # view
  pm2 logs adminimail     # live logs
  pm2 restart adminimail  # restart service

To remove AdminiMail:
  pm2 delete adminimail && rm -rf "${APP_DIR}"

${C_BOLD}Next steps:${C_RESET}
1. Point a domain (e.g., mail.admini.tech) at your server IP.
2. Add HTTPS via Nginx + Certbot or Cloudflare Tunnel.
3. Customize branding inside ${APP_DIR}/apps/web.

Thank you for using AdminiMail-installer!
EOF
