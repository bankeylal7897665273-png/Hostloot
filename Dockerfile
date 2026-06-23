# PHP aur Apache ka official base image use kar rahe hain
FROM php:8.2-apache

# Unzip tool aur SQL chalane ke liye zaroori extensions install karna
RUN apt-get update && apt-get install -y \
    unzip \
    libsqlite3-dev \
    && docker-php-ext-install pdo pdo_mysql mysqli pdo_sqlite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# URL rewriting enable karna (PHP projects ke liye zaroori hota hai)
RUN a2enmod rewrite

# Working directory ko Apache ke default web root par set karna
WORKDIR /var/www/html

# Apni 'deep.zip' file ko container ke andar copy karna
COPY deep.zip .

# deep.zip ko extract karna aur phir zip file ko delete kar dena space bachane ke liye
RUN unzip deep.zip && rm deep.zip

# Web server ke liye sahi folder permissions set karna
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Render ke liye default web port (80) expose karna
EXPOSE 80

