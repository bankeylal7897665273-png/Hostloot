FROM php:8.2-apache

# unzip package install kar rahe hain taaki deep.zip extract ho sake
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    unzip \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clean URLs ke liye Apache mod_rewrite enable karein
RUN a2enmod rewrite

# 403 Error Fix: Apache ko directory read karne ki permission
RUN echo "<Directory /var/www/html>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>" > /etc/apache2/conf-available/custom-dir.conf \
    && a2enconf custom-dir

# GitHub repo ki saari files (deep.zip aur entrypoint.sh) ko server par copy karein
COPY . /var/www/html/

# deep.zip ko extract karein aur extract hone ke baad us zip file ko delete kar dein
RUN if [ -f "/var/www/html/deep.zip" ]; then unzip /var/www/html/deep.zip -d /var/www/html/ && rm /var/www/html/deep.zip; fi

# Entrypoint script (jo extract hui hai ya bahar thi) ko sahi jagah move karein aur executable banayein
RUN cp /var/www/html/entrypoint.sh /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Files ko sahi permissions dein (403 error se bachne ke liye)
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Render ke liye Port 80 expose karein
EXPOSE 80

# Container start hone par entrypoint script run karein
ENTRYPOINT ["entrypoint.sh"]
