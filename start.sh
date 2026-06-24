#!/bin/bash
set -e
echo "========================================="
echo "   66Lottery - Starting on Render.com"
echo "========================================="

echo "[1/5] Starting MariaDB..."
service mariadb start

for i in $(seq 1 30); do
    mysqladmin ping --silent 2>/dev/null && echo ">>> MariaDB ready." && break
    echo "    Waiting... ($i/30)" && sleep 1
done

echo "[2/5] Creating database & user..."
mysql -u root <<'SQL'
CREATE DATABASE IF NOT EXISTS lottery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'lottery_user'@'localhost' IDENTIFIED BY 'Lottery@2024#Secure';
GRANT ALL PRIVILEGES ON lottery_db.* TO 'lottery_user'@'localhost';
FLUSH PRIVILEGES;
SQL

echo "[3/5] Importing schema..."
TABLES=$(mysql -u root -sse "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='lottery_db';" 2>/dev/null || echo 0)
if [ "$TABLES" -lt "3" ]; then
    mysql -u root lottery_db < /var/www/html/database.sql
    echo ">>> Schema imported."
else
    echo ">>> Schema already exists, skipping."
fi

echo "[4/5] Starting cron..."
service cron start

echo "[5/5] Starting Apache..."
exec apache2-foreground

