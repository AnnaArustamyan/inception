FROM alpine:3.18

RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-gd \
    php82-intl \
    mariadb-client \
    wget \
    curl \
    && rm -rf /var/cache/apk/*

# Create necessary directories
RUN mkdir -p /var/www/html /run/php

# Copy WordPress installation script
COPY tools/install-wordpress.sh /install-wordpress.sh
RUN chmod +x /install-wordpress.sh

# Copy PHP-FPM configuration
COPY tools/www.conf /etc/php82/php-fpm.d/www.conf

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/install-wordpress.sh"]
CMD ["php-fpm82", "-F"]
