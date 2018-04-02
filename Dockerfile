FROM php:7.2-fpm-alpine

MAINTAINER KasperFranz, <kasper@franz.guru>

WORKDIR /var/www/html/

ADD crontab /crontab
RUN /usr/bin/crontab /crontab
ENV PYTHON_VERSION=2.7.14-r0
ENV PY_PIP_VERSION=9.0.1-r1
ENV SUPERVISOR_VERSION=3.3.1

RUN apk update \
 && apk add  openssl-dev curl tar tini caddy \  
        curl-dev  \
        libxml2-dev \
 && apk add  python=$PYTHON_VERSION py-pip=$PY_PIP_VERSION \
 && docker-php-ext-install \
        curl \
        iconv \
        mbstring \
        pdo \
	pdo_mysql \
        pcntl \
        tokenizer \
        xml \
        zip \
        bcmath 


RUN pip install supervisor==$SUPERVISOR_VERSION


COPY ./manifest/ /


RUN curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/download/v0.7.2/panel.tar.gz \
 && tar --strip-components=1 -xzvf panel.tar.gz \
 && sed -ie "s/env('CACHE_DRIVER', 'memcached')/env('CACHE_DRIVER', 'array')/g" config/cache.php \
 && rm panel.tar.gz \
 && chmod -R 777 storage/* bootstrap/cache \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer install --ansi --no-dev \
 && chown -R caddy:caddy * 



ENTRYPOINT ["/bin/ash", "/var/www/html/entrypoint.sh"]

CMD ["/sbin/tini", "--", "supervisord", "--configuration", "/etc/supervisord.conf"]

EXPOSE 80 443 2015

