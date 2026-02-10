#!/bin/sh

# Read secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Initialize MariaDB if data directory is empty
if [ ! -d /var/lib/mysql/mysql ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db
    
    # Start MariaDB temporarily to create database and user
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!
    
    # Wait for MariaDB to start
    until mysqladmin ping --silent; do
        sleep 1
    done
    
    # Create database and user
    mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    # Stop temporary MariaDB instance
    kill $MYSQL_PID
    wait $MYSQL_PID
fi

# Set permissions
chown -R mysql:mysql /var/lib/mysql /run/mysqld

exec "$@"
