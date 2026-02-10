FROM alpine:3.18

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    && rm -rf /var/cache/apk/*

# Create necessary directories
RUN mkdir -p /var/lib/mysql /run/mysqld

# Copy initialization script
COPY tools/init-db.sh /init-db.sh
RUN chmod +x /init-db.sh

# Copy MariaDB configuration
COPY conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf

EXPOSE 3306

ENTRYPOINT ["/init-db.sh"]
CMD ["mysqld", "--user=mysql"]
