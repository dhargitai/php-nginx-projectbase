#!/bin/bash

echo
echo "Determining Docker IP..."
dockerip=$(ifconfig docker0 2> /dev/null | grep --word-regexp inet | awk '{print $2}' | sed 's%addr:%%g')
dockerinterfaceip=$dockerip
if [[ ! $dockerip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] ; then
    dockerip=$(docker-machine ip default 2> /dev/null)
    if [[ ! $dockerip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] ; then
        echo "Can't determine Docker's IP address"
        exit -1
    fi
    subnet=${dockerip%.*}
    dockerinterfaceip=$(ifconfig 2> /dev/null | grep -F "inet $subnet" | awk '{print $2}' | sed 's%addr:%%g')
fi

encryptionkey=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo "APP_ENV=dev
MYSQL_USER=dev
MYSQL_PASSWORD=dev123
MYSQL_DATABASE=diatigrah_db
ENCRYPTION_KEY=$encryptionkey
DOCKER_IP=$dockerip
" > .env

echo "FROM diatigrah/php-nginx-projectbase:0.2.5

ADD docker/services/nginx/sites /etc/nginx/sites-enabled
ADD docker/services/php5-fpm/php.ini /etc/php5/fpm/conf.d/40-custom.ini

ADD application /var/www/$projectname
ADD docker/run.sh /root/run.sh

WORKDIR /var/www/$projectname
" > Dockerfile

echo "; XDebug configuration
xdebug.remote_enable = 1
xdebug.renite_enable = 1
xdebug.max_nesting_level = 1000
xdebug.profiler_enable_trigger = 1
xdebug.profiler_output_dir = \"/var/log\"
xdebug.default_enable = 1
xdebug.remote_autostart = 0
xdebug.remote_handler = dbgp
xdebug.remote_port = 9000
xdebug.remote_connect_back = Off
xdebug.remote_host = $dockerip

cgi.fix_pathinfo = 0
date.timezone = \"Europe/Budapest\"
" > docker/services/php5-fpm/php.ini

echo
host_entry="$dockerip diatigrah.dev diatigrah.test"
if grep "$host_entry" /etc/hosts;
then
    echo "Your hosts file is up to date."
else
    echo "Adding diatigrah.dev and diatigrah.test domains to your hosts file..."
    echo $host_entry | sudo tee -a /etc/hosts
fi

echo
echo "Ok, your files are ready. From now you can use build.sh to build up your environment."
