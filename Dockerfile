FROM alpine:edge

MAINTAINER KasperFranz, <kasper@franz.guru>

WORKDIR /var/www/html/

RUN apk update \
 && apk add  openssl-dev php7 php7-bcmath php7-common php7-dom php7-fpm php7-gd php7-mbstring php7-openssl php7-pdo php7-phar php7-json php7-pdo_mysql php7-session php7-ctype curl tar tini caddy \
 && mv /usr/bin/php7 /usr/bin/php \
 && mv /usr/sbin/php-fpm7 /usr/sbin/php-fpm

COPY ./manifest/ /

RUN curl -Lo panel.tar.gz https://github.com/Pterodactyl/Panel/archive/v0.6.0-beta.2.tar.gz \
 && tar --strip-components=1 -xzvf panel.tar.gz \
 && sed -ie "s/env('CACHE_DRIVER', 'memcached')/env('CACHE_DRIVER', 'array')/g" config/cache.php \
 && rm panel.tar.gz \
 && chown -R caddy:caddy * \
 && chmod -R 777 storage/* bootstrap/cache \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer install --ansi --no-dev

ENTRYPOINT ["/bin/ash", "/var/www/html/entrypoint.sh"]

EXPOSE 80

CMD ["/sbin/tini", "--", "/usr/sbin/caddy", "-conf", "/etc/caddy/caddy.conf"]
