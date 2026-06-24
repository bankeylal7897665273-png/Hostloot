FROM php:8.2-apache

# Packages install kar rahe hain
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    unzip \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clean URLs ke liye Apache mod_rewrite enable karein
RUN a2enmod rewrite

# 403 Error Fix
RUN echo "<Directory /var/www/html>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>" > /etc/apache2/conf-available/custom-dir.conf \
    && a2enconf custom-dir

# Repo files copy karein
COPY . /var/www/html/

# 1. Zip extract karein
# 2. Zip delete karein
# 3. Aapke permission dene par automatic localhost ko 127.0.0.1 me change karein taaki SQL connect ho jaye
RUN if [ -f "/var/www/html/deep.zip" ]; then unzip /var/www/html/deep.zip -d /var/www/html/ && rm /var/www/html/deep.zip; fi \
    && if [ -f "/var/www/html/config.php" ]; then sed -i "s/'localhost'/'127.0.0.1'/g" /var/www/html/config.php; fi

# Entrypoint script set karein
RUN cp /var/www/html/entrypoint.sh /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Permissions set karein
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Port 80
EXPOSE 80

# Script run karein
ENTRYPOINT ["entrypoint.sh"]
