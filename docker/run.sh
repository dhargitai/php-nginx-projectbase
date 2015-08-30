#!/bin/bash

sed -i "s|;clear_env = no|clear_env = no|" /etc/php5/fpm/pool.d/www.conf

if [ -n "$DB_PORT_3306_TCP_ADDR" ] ; then
    bin/wait-for-db.sh
fi

chown -R www-data: /var/www

/sbin/my_init
