FROM abiosoft/caddy

MAINTAINER Olivier Pichon <op@united-asian.com>

ADD Caddyfile /etc/Caddyfile

COPY ./www /var/www/

VOLUME /var/www/

WORKDIR /var/www
