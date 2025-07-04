# 📬 AdminiMail Installer – Fully Automated Setup Script

Welcome to **AdminiMail-installer**, a fully automated installation solution designed to deploy the complete [Zero Mail (Mail-0)](https://github.com/mail-0/zero) system under a new brand called **AdminiMail**.

This script sets up everything you need to run AdminiMail on a fresh Linux server with minimal manual steps. It's ideal for developers, testers, or private self-hosters looking to run a full-featured email management system with local workflows and AI features.

---

## 🌟 What Is AdminiMail?

**AdminiMail** is a rebranded fork of the open-source **Zero Mail** (also known as Mail-0), designed for self-hosted usage. It offers:

- A powerful web interface for managing emails
- Cloudflare Workers integration
- Local development support with full backend + frontend
- Redis, PostgreSQL, durable objects, workflows, queues, and more

---

## 📦 Features of This Installer

✅ One-click installation on a fresh Debian/Ubuntu VM  
✅ Installs Node.js (v18), pnpm, PostgreSQL, Redis  
✅ Clones the original Zero/Mail-0 repository  
✅ Sets up `.env`, database, and local server  
✅ Configures local development environment  
✅ Automatically runs with `pnpm dev` or PM2  
✅ Built for long-term rebranding and fork support  

---

## 🧰 Requirements

Before using this installer, ensure the following:

- A fresh VPS or VM (Debian 10/11, Ubuntu 20.04/22.04)
- Minimum **2 GB RAM**, **1 vCPU**
- Open network ports:  
  - `3000` – Web UI  
  - `8787` – Worker  
- `sudo` access  
- Internet connectivity for downloads

---

## 🚀 One-Line Installation

Install AdminiMail on a fresh VM with one line:

```bash
curl -fsSL https://raw.githubusercontent.com/iSundram/AdminiMail-installer/main/install.sh | bash
