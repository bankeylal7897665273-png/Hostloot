FROM php:8.2-apache

# MariaDB server, client aur PHP extensions install karein
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clean URLs ke liye Apache mod_rewrite enable karein
RUN a2enmod rewrite

# Project ki saari files ko Apache ke public folder mein copy karein
COPY . /var/www/html/

# Files ko sahi permissions dein
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Entrypoint script ko copy karein aur executable banayein
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Render ke liye Port 80 expose karein
EXPOSE 80

# Container start hone par entrypoint script run karein
ENTRYPOINT ["entrypoint.sh"]
