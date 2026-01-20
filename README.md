# 🌐 Nginx 502 Bad Gateway Fixer

![Service](https://img.shields.io/badge/Service-Nginx%20%7C%20PHP--FPM-green)
![Error](https://img.shields.io/badge/Error-502%20Bad%20Gateway-red)
![Fix](https://img.shields.io/badge/Fix-Buffer%20Tuning-blue)

## 🆘 The Problem
Your website is down with a **502 Bad Gateway** error.
This usually happens when **Nginx** tries to talk to **PHP-FPM**, but PHP is too busy or the data packet is too big for the buffer.

Common Causes:
1.  **Process Limit:** PHP-FPM has run out of "workers" (`pm.max_children` reached).
2.  **Buffer Overflow:** The page content is larger than the default Nginx buffer.
3.  **Timeout:** The script took too long to execute.

## 🛠️ The Solution
This repository contains a shell script that inspects your RAM and automatically calculates the optimal `pm.max_children` settings. It also increases Nginx buffer limits to prevent choke-ups.

## 🚀 Usage Guide

### Step 1: Run the Optimizer
Download and run the script on your Web Server (Ubuntu/CentOS):
```bash
sudo ./fix_502.sh

Step 2: What it Does
Backs up your existing configs to /tmp/.

Updates /etc/php/*/fpm/pool.d/www.conf with optimized process limits based on your total RAM.

Updates /etc/nginx/nginx.conf with higher fastcgi_buffers.

Restarts Nginx and PHP-FPM safely.

Step 3: Verify
Check the status:
systemctl status php8.1-fpm
tail -f /var/log/nginx/error.log

Author: Sheikh Alamin Santo
Web Infrastructure Architect
