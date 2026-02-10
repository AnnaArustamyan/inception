#!/bin/sh

# Read secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Wait for MariaDB to be ready
until mysqladmin ping -h mariadb -u root -p"$DB_ROOT_PASSWORD" --silent 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# Download WordPress if not already present
if [ ! -f /var/www/html/wp-config.php ]; then
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# Configure WordPress
if [ ! -f /var/www/html/wp-config.php ]; then
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    
    # Replace database configuration
    sed -i "s/database_name_here/${MYSQL_DATABASE}/g" /var/www/html/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/g" /var/www/html/wp-config.php
    sed -i "s/password_here/${DB_PASSWORD}/g" /var/www/html/wp-config.php
    sed -i "s/localhost/${MYSQL_HOST}/g" /var/www/html/wp-config.php
    
    # Add security keys
    curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wp-config.php
    
    # Set permissions
    chown -R nobody:nobody /var/www/html
    chmod -R 755 /var/www/html
fi

exec "$@"
