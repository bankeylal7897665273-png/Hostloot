# PHP aur Apache ka official base image
FROM php:8.2-apache

# Unzip, MariaDB (MySQL) server, client aur PHP extensions install karna
RUN apt-get update && apt-get install -y \
    unzip \
    mariadb-server \
    mariadb-client \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# URL rewriting enable karna
RUN a2enmod rewrite

# Working directory set karna
WORKDIR /var/www/html

# Zip file ko container mein copy karna
COPY deep.zip .

# Zip ko extract karna aur phir zip file ko delete karna
RUN unzip deep.zip && rm deep.zip

# Web server ke permissions set karna
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Render ke liye port 80 open karna
EXPOSE 80

# Container start hone par pehle MySQL start karna, database import karna, phir Apache start karna
CMD /etc/init.d/mariadb start && \
    sleep 3 && \
    (mysql < database.sql || true) && \
    apache2-foreground
