#!/bin/bash

set -e

/usr/bin/caddy --conf /etc/Caddyfile &&

exec "$@"