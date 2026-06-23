# Base image for PHP and Apache
FROM php:8.2-apache

# Install Unzip, MariaDB (MySQL), and PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    mariadb-server \
    mariadb-client \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable URL rewriting for Apache
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy the zip file and extract it
COPY deep.zip .
RUN unzip deep.zip && rm deep.zip

# ============================================================
# AUTOMATIC FIX: Yeh line aapke config.php mein localhost ko 
# 127.0.0.1 mein badal degi bina aapko zip open kiye.
RUN sed -i "s/'localhost'/'127.0.0.1'/g" config.php
# ============================================================

# Set proper permissions for the web server
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Ensure MySQL directories exist and have correct permissions
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql

# Create a robust startup script
RUN echo '#!/bin/bash\n\
echo "Starting MariaDB..."\n\
service mariadb start\n\
\n\
# Loop to wait until MySQL socket file is created\n\
while [ ! -S /var/run/mysqld/mysqld.sock ]; do\n\
  echo "Waiting for MySQL to start..."\n\
  sleep 1\n\
done\n\
echo "MariaDB is up and running!"\n\
\n\
# Import the database if the SQL file exists\n\
if [ -f "database.sql" ]; then\n\
  echo "Importing database.sql..."\n\
  mysql -e "ALTER USER '\''root'\''@'\''localhost'\'' IDENTIFIED BY '\'''\''; FLUSH PRIVILEGES;" || true\n\
  mysql < database.sql\n\
  echo "Database imported successfully!"\n\
fi\n\
\n\
# Start Apache in the foreground\n\
echo "Starting Apache..."\n\
exec apache2-foreground\n\
' > /start.sh

# Make the startup script executable
RUN chmod +x /start.sh

# Expose port 80 for Render
EXPOSE 80

# Command to run the startup script when the container starts
CMD ["/start.sh"]
