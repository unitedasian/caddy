FROM php:7-fpm

MAINTAINER Olivier Pichon <op@united-asian.com>

LABEL caddy_version="0.9.5" architecture="amd64"

ARG plugins=expires,filemanager,git,locale,minify,realip

ARG timezone='Asia/Hong_Kong'

ARG memory_limit=-1

COPY ./etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY Caddyfile /etc/Caddyfile

COPY www/index.html /var/www/html/web/

COPY www/index.php /var/www/html/web/

RUN ulimit -n 4096 \
    && apt-get update && apt-get install -y --force-yes --fix-missing \
        git \
        libcurl4-gnutls-dev \
        libicu-dev \
        libmcrypt-dev \
        openssh-client \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install \
        curl \
        intl \
        mcrypt \
        pdo_mysql \
        zip \
    && echo "date.timezone="$timezone > /usr/local/etc/php/conf.d/date_timezone.ini \
    && echo "memory_limit="$memory_limit > /usr/local/etc/php/conf.d/memory_limit.ini \
    && usermod -u 1001 www-data \
    && chown -R www-data:www-data /var/www \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl --silent --show-error --fail --location \
        --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
        "https://caddyserver.com/download/build?os=linux&arch=amd64&features=${plugins}" \
        | tar --no-same-owner -C /usr/bin/ -xz caddy \
    && chmod 0755 /usr/bin/caddy \
    && /usr/bin/caddy -version \
    && apt-get clean

WORKDIR /var/www/html

EXPOSE 80 443 2015

ENTRYPOINT ["/usr/bin/caddy"]

CMD ["--conf", "/etc/Caddyfile"]
