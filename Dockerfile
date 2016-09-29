FROM php:7-fpm
MAINTAINER Olivier Pichon <op@united-asian.com>

ARG timezone='Asia/Hong_Kong'

ARG memory_limit=-1

ARG build='build'

COPY ./etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY caddy /usr/bin/caddy

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
        supervisor \
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
	&& chmod 0755 /usr/bin/caddy \
    && /usr/bin/caddy -version

WORKDIR /var/www/html

#ONBUILD COPY . /var/www/html

EXPOSE 80 443 2015

ENTRYPOINT ["/usr/bin/caddy"]

CMD ["--conf", "/etc/Caddyfile"]
