FROM alpine:edge

MAINTAINER KasperFranz, <kasper@franz.guru>

WORKDIR /var/www/html/

ADD crontab /crontab
RUN /usr/bin/crontab /crontab
ENV PYTHON_VERSION=2.7.13-r1
ENV PY_PIP_VERSION=9.0.1-r1
ENV SUPERVISOR_VERSION=3.3.1


RUN apk update \
 && apk add  openssl-dev php7 php7-bcmath	php7-tokenizer  php7-common php7-zip php7-dom php7-fpm php7-gd php7-mbstring php7-openssl php7-pdo php7-phar php7-json php7-pdo_mysql php7-session php7-ctype curl tar tini caddy \
 && apk add  python=$PYTHON_VERSION py-pip=$PY_PIP_VERSION \
 && mv /usr/bin/php7 /usr/bin/php \
 && mv /usr/sbin/php-fpm7 /usr/sbin/php-fpm

RUN pip install supervisor==$SUPERVISOR_VERSION


COPY ./manifest/ /

RUN curl -Lo panel.tar.gz https://github.com/Pterodactyl/Panel/archive/v0.6.0.tar.gz \
 && tar --strip-components=1 -xzvf panel.tar.gz \
 && sed -ie "s/env('CACHE_DRIVER', 'memcached')/env('CACHE_DRIVER', 'array')/g" config/cache.php \
 && rm panel.tar.gz \
 && chown -R caddy:caddy * \
 && chmod -R 777 storage/* bootstrap/cache \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer install --ansi --no-dev

ENTRYPOINT ["/bin/ash", "/var/www/html/entrypoint.sh"]

CMD ["/sbin/tini", "--", "supervisord", "--configuration", "/etc/supervisord.conf"]

EXPOSE 80

