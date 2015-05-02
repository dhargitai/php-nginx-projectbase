#!/usr/bin/env bash

exec /sbin/setuser root /usr/sbin/php5-fpm >>/var/log/php5-fpm.log 2>&1
