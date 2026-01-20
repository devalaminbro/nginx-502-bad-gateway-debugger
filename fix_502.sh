```bash
#!/bin/bash

# ============================================================
# Nginx 502 Bad Gateway Auto-Fixer
# Author: Sheikh Alamin Santo
# Use Case: Optimizes PHP-FPM & Nginx Buffers
# ============================================================

# Color Codes
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Starting 502 Error Fixer...${NC}"

# 1. Detect PHP Version
PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
echo -e "${GREEN}[+] Detected PHP Version: $PHP_VER${NC}"

PHP_CONF="/etc/php/$PHP_VER/fpm/pool.d/www.conf"
NGINX_CONF="/etc/nginx/nginx.conf"

# 2. Backup Configs
cp $PHP_CONF $PHP_CONF.bak
cp $NGINX_CONF $NGINX_CONF.bak

# 3. Optimize PHP-FPM (Dynamic Calculation based on RAM)
# We assume each PHP process takes ~60MB RAM
TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MAX_CHILDREN=$((TOTAL_MEM / 1024 / 60))

echo -e "${GREEN}[+] Tuning pm.max_children to $MAX_CHILDREN (Based on Available RAM)${NC}"

# Using sed to replace values
sed -i "s/^pm.max_children = .*/pm.max_children = $MAX_CHILDREN/" $PHP_CONF
sed -i "s/^pm.start_servers = .*/pm.start_servers = 10/" $PHP_CONF
sed -i "s/^pm.min_spare_servers = .*/pm.min_spare_servers = 5/" $PHP_CONF
sed -i "s/^pm.max_spare_servers = .*/pm.max_spare_servers = 20/" $PHP_CONF

# 4. Fix Nginx Buffers (To fix "upstream sent too big header")
echo -e "${GREEN}[+] Increasing Nginx FastCGI Buffers...${NC}"

if grep -q "fastcgi_buffers" $NGINX_CONF; then
    echo "Buffers already set."
else
    # Insert inside http block
    sed -i '/http {/a \    fastcgi_buffers 16 16k;\n    fastcgi_buffer_size 32k;' $NGINX_CONF
fi

# 5. Restart Services
echo -e "${GREEN}[+] Restarting Services...${NC}"
systemctl restart php$PHP_VER-fpm
systemctl restart nginx

echo -e "${GREEN}[SUCCESS] Optimization Applied! Check your website now.${NC}"
