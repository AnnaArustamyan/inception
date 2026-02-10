#!/bin/sh

# Substitute DOMAIN_NAME into nginx config
envsubst '${DOMAIN_NAME}' < /etc/nginx/http.d/default.conf.template > /etc/nginx/http.d/default.conf

# Generate SSL certificate if it doesn't exist
if [ ! -f /etc/nginx/ssl/cert.pem ] || [ ! -f /etc/nginx/ssl/key.pem ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out /etc/nginx/ssl/cert.pem \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME:-localhost}"
fi

exec "$@"
