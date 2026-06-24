#!/bin/bash
# Kisi bhi error aane par script stop ho jaye
set -e

echo "MariaDB (MySQL) service start ho rahi hai..."
service mariadb start

# Database ko fully initialize hone ke liye 3 seconds ka wait
sleep 3

echo "Database aur User configure ho raha hai..."
mysql -e "CREATE DATABASE IF NOT EXISTS lottery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'lottery_user'@'localhost' IDENTIFIED BY 'Lottery@2024#Secure';"
mysql -e "GRANT ALL PRIVILEGES ON lottery_db.* TO 'lottery_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "Check kar rahe hain ki database import ki zaroorat hai ya nahi..."
# Ek check lagaya hai taaki agar container restart ho toh data overwrite na ho
TABLE_EXISTS=$(mysql -u lottery_user -p'Lottery@2024#Secure' -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'lottery_db' AND table_name = 'users';")

if [ "$TABLE_EXISTS" -eq 0 ]; then
    echo "database.sql import ho raha hai..."
    if [ -f "/var/www/html/database.sql" ]; then
        mysql -u lottery_user -p'Lottery@2024#Secure' lottery_db < /var/www/html/database.sql
        echo "Database successfully import ho gaya!"
    else
        echo "Warning: database.sql file nahi mili!"
    fi
else
    echo "Database tables pehle se exist karti hain. Import skip kiya gaya."
fi

echo "Apache (PHP) start ho raha hai..."
# Apache ko foreground mein start karein taaki container run karta rahe
apache2-foreground
