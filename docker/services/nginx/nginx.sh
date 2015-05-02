#!/usr/bin/env bash

exec /sbin/setuser root /usr/sbin/nginx >>/var/log/nginx.log 2>&1
