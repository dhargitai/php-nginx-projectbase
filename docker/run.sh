#!/bin/bash

if [ -z "$NGINX_SERVER_NAMES" ] ; then
    NGINX_SERVER_NAMES="localhost"
fi
sed -i "s|\${NGINX_SERVER_NAMES}|${NGINX_SERVER_NAMES}|" /etc/nginx/sites-enabled/default

COMPOSER_INSTALL_MODE="--no-dev"
if [ "$APP_ENV" = "dev" ] ; then
    COMPOSER_INSTALL_MODE=""
fi

sed -i "s|;clear_env = no|clear_env = no|" /etc/php5/fpm/pool.d/www.conf

if [ -n "$DB_PORT_3306_TCP_ADDR" ] ; then
    bin/wait-for-db.sh
fi

composer install --prefer-dist $COMPOSER_INSTALL_MODE

/sbin/my_init
