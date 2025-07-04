#!/usr/bin/env bash
#───────────────────────────────────────────────────────────
#  AdminiMail (Zero) One-Click Installer
#  Tested on Ubuntu/Debian fresh VMs
#───────────────────────────────────────────────────────────
set -euo pipefail

REPO_URL="https://github.com/Mail-0/Zero.git"
APP_DIR="$HOME/Zero"
DB_NAME="adminimail"
NODE_VERSION="lts/*"             # Node 20 LTS at time of writing
PNPM_VERSION="latest"
APP_PORT="3000"                  # Front-end
WORKER_PORT="8787"               # Back-end / wrangler

echo "──────────  AdminiMail Installer  ──────────"

#───────────────────────────────────────────────────────────
# 1. Ask for Postgres password once
#───────────────────────────────────────────────────────────
read -rsp "Choose a password for the Postgres 'postgres' user: " DB_PASS
echo
read -rp "Git branch to checkout (default: main): " BRANCH
BRANCH=${BRANCH:-main}

#───────────────────────────────────────────────────────────
# 2. System packages
#───────────────────────────────────────────────────────────
echo "📦  Updating APT & installing prerequisites…"
sudo apt update -y
sudo apt install -y curl git build-essential postgresql postgresql-contrib redis-server

#───────────────────────────────────────────────────────────
# 3. Install NVM & Node
#───────────────────────────────────────────────────────────
if ! command -v nvm >/dev/null 2>&1; then
  echo "⬇️  Installing NVM…"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# shellcheck disable=SC1090
source "$HOME/.nvm/nvm.sh"
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
echo "✅  Node version: $(node -v)"

#───────────────────────────────────────────────────────────
# 4. Install pnpm
#───────────────────────────────────────────────────────────
echo "⬇️  Installing pnpm…"
npm install -g "pnpm@$PNPM_VERSION"
echo "✅  pnpm version: $(pnpm -v)"

#───────────────────────────────────────────────────────────
# 5. Clone or pull repo
#───────────────────────────────────────────────────────────
if [[ -d "$APP_DIR/.git" ]]; then
  echo "🔄  Repo exists – pulling latest $BRANCH…"
  git -C "$APP_DIR" fetch origin "$BRANCH" && git -C "$APP_DIR" checkout "$BRANCH" && git -C "$APP_DIR" pull
else
  echo "⬇️  Cloning repo…"
  git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
fi

#───────────────────────────────────────────────────────────
# 6. Configure Postgres
#───────────────────────────────────────────────────────────
echo "🛢️  Configuring Postgres…"
sudo -u postgres psql -tc "ALTER USER postgres WITH PASSWORD '$DB_PASS';" >/dev/null
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';" | grep -q 1 || \
  sudo -u postgres createdb "$DB_NAME"

#───────────────────────────────────────────────────────────
# 7. Generate .env
#───────────────────────────────────────────────────────────
cd "$APP_DIR"
cp -n .env.example .env
sed -i "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://postgres:$DB_PASS@localhost:5432/$DB_NAME|" .env
sed -i "s|^REDIS_URL=.*|REDIS_URL=redis://localhost:6379|" .env
sed -i "s|^NEXTAUTH_SECRET=.*|NEXTAUTH_SECRET=$(openssl rand -hex 32)|" .env
sed -i "s|^NEXTAUTH_URL=.*|NEXTAUTH_URL=http://localhost:$APP_PORT|" .env

#───────────────────────────────────────────────────────────
# 8. Install dependencies & push DB schema
#───────────────────────────────────────────────────────────
echo "📦  Installing dependencies (this may take a minute)…"
pnpm install
echo "🗄️   Applying DB schema…"
pnpm db:push

#───────────────────────────────────────────────────────────
# 9. Build & run with PM2
#───────────────────────────────────────────────────────────
echo "🔧  Building…"
pnpm build
echo "🚀  Launching with PM2…"
npm install -g pm2
pm2 start "pnpm start" --name adminimail
pm2 save

#───────────────────────────────────────────────────────────
# 10. Final info
#───────────────────────────────────────────────────────────
echo
echo "🎉  AdminiMail is running!"
echo "    Front-end → http://<server-ip>:$APP_PORT"
echo "    Worker    → http://<server-ip>:$WORKER_PORT"
echo "    PM2 logs  → pm2 logs adminimail"
echo
echo "Tip: open firewall ports $APP_PORT and $WORKER_PORT if needed."
echo "───────────────────────────────────────────────────────────"
