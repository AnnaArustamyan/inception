FROM alpine:3.18

RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    gettext \
    && rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /var/www/html /etc/nginx/ssl /run/nginx

# Copy configuration files (default.conf is a template, substituted at runtime)
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/http.d/default.conf.template
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
