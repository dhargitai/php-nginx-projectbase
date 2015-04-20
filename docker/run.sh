#!/bin/bash

if [ ! -n "$NGINX_SERVER_NAMES" ] ; then
    NGINX_SERVER_NAMES="localhost"
fi
sed -i "s|\${NGINX_SERVER_NAMES}|${NGINX_SERVER_NAMES}|" /etc/nginx/sites-enabled/default

COMPOSER_INSTALL_MODE="--no-dev"
if [ "$APP_ENV" = "dev" ] ; then
    COMPOSER_INSTALL_MODE="--dev"
fi

bin/wait-for-db.sh && \
composer install --prefer-dist $COMPOSER_INSTALL_MODE

/usr/bin/supervisord
