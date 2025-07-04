<!-- TITLE & BADGES -->
<h1 align="center">📬 AdminiMail-installer</h1>
<p align="center">
  <b>Instant, unattended setup for the AdminiMail stack on any fresh Debian/Ubuntu server.</b><br>
  <sub>Powered by Bash, PM2, Node 20 LTS, PostgreSQL 15, and Redis 6 — no manual copy-pasting required.</sub>
</p>

<p align="center">
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/iSundram/AdminiMail-installer?color=brightgreen">
  <img alt="License" src="https://img.shields.io/github/license/iSundram/AdminiMail-installer">
  <img alt="OS" src="https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-blue">
</p>

---

## 🌟 Features

| ✅ | What it does |
|----|--------------|
| One-line install | Spins up Node 20 LTS (via **NVM**), **pnpm**, PostgreSQL, Redis, Git | 
| Secure by default | Prompts once for a Postgres password, generates unique secrets |
| Hands-free app deploy | Clones the AdminiMail repo, installs dependencies, creates DB schema |
| Always-on | Runs AdminiMail under **PM2** (auto-restart, log rotation, reboot-safe) |
| Idempotent | Safe to re-run: detects existing install and upgrades in-place |
| Clean rollback | All files live in `~/AdminiMail` & PM2 — easy to remove if needed |

---

## 🚀 Quick Start

> **Copy icon:** click the clipboard in the corner of each block on GitHub to copy.<br>
> The installer must run as **root** (or with `sudo`).

```bash
curl -fsSL https://raw.githubusercontent.com/iSundram/AdminiMail-installer/main/install.sh | sudo bash
```
After ~2 minutes you’ll see:

🎉  AdminiMail installation complete!

• Front-end:  http://<server-ip>:3000
• Worker:     http://<server-ip>:8787

Open the front-end URL in your browser, create an account, and you’re ready to mail.


---

📝 Detailed Requirements

Debian 10/11 or Ubuntu 20.04/22.04 (fresh VPS recommended)

2 GB RAM / 1 vCPU minimum

Open TCP ports 3000 (front-end) and 8787 (worker)

sudo privileges



---

🔧 Manual Usage

git clone https://github.com/iSundram/AdminiMail-installer.git
cd AdminiMail-installer
chmod +x install.sh
sudo ./install.sh

The script asks:

1. Postgres password – used for superuser postgres and stored in .env


2. Git branch – default is main


3. (Optional) Open firewall ports 3000/8787 via UFW



Everything else is automatic.


---

📂 What the Script Does

1. Updates APT and installs core packages


2. Installs NVM → Node 20 LTS → pnpm


3. Installs PostgreSQL 15 + Redis 6 (enables at boot)


4. Clones https://github.com/iSundram/AdminiMail into ~/AdminiMail


5. Creates database adminimail and sets the supplied password


6. Generates .env with secure random secrets and correct URLs


7. pnpm install – installs all JS/TS dependencies


8. pnpm db:push – applies database schema automatically


9. pnpm build then pm2 start “pnpm start” --name adminimail


10. Saves PM2 startup so AdminiMail restarts on reboot




---

🛠  Customization & Maintenance

Task	Command

Update AdminiMail code	cd ~/AdminiMail && git pull && pnpm install && pnpm build && pm2 restart adminimail
View live logs	pm2 logs adminimail
Restart / stop service	pm2 restart adminimail / pm2 stop adminimail
Change ports	Edit FRONT_PORT / WORKER_PORT in install.sh before running
Remove AdminiMail completely	pm2 delete adminimail && rm -rf ~/AdminiMail && sudo apt purge nodejs postgresql redis-server -y



---

🌐 Adding a Domain & HTTPS

1. Point an A-record (e.g. mail.admini.tech) to your server IP.


2. Install Nginx + Certbot or use Cloudflare Tunnel.


3. Proxy inbound 443 → local 3000, and 443 → local 8787 (if you expose the worker).




---

🧩 Roadmap

Automated Nginx + Let’s Encrypt config

ARM 64 (Raspberry Pi) bootstrap options

GitHub Actions self-test matrix

Systemd unit alternative to PM2


Contributions welcome—open an issue or PR!


---

🛡  Security Notes

The Postgres superuser password is stored only in your private .env.

Redis runs on localhost by default.

Firewall ports are opened only when you agree.

Change default secrets in .env for production deployments.



---

© License

AdminiMail-installer is released under the MIT License.
Feel free to fork, adapt, and share. A backlink is appreciated but not required.


---

<p align="center">
  Made with ❤️  by <a href="https://github.com/iSundram">iSundram</a>
</p>

