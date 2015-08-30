#!/bin/bash

if [ $(docker ps -a | grep diatigrah_mysql | wc -l) -eq 1 ]; then
  echo ""
  echo "Starting MySQL container..."
  docker start diatigrah_mysql
else
  echo ""
  echo "Running MySQL container..."
  docker run --name diatigrah_mysql \
             --volumes-from diatigrah_dataonly_mysql \
             -v /var/lib/mysql:/var/lib/mysql \
             -e MYSQL_USER=dev \
             -e MYSQL_PASSWORD=dev123 \
             -e MYSQL_DATABASE=diatigrah_db \
             -e MYSQL_ROOT_PASSWORD=supersecret \
             -h db1.diatigrah.hu.dev \
             -P -d \
           mysql
fi

if [ $(docker ps -a | grep diatigrah_web_1 | wc -l) -eq 1 ]; then
  echo ""
  echo "Starting web container..."
  docker start diatigrah_web_1
else
  echo ""
  echo "Running web container..."
  docker run --name diatigrah_web_1 \
           --link diatigrah_mysql:db \
           --add-host diatigrah.test:127.0.0.1 \
           --add-host diatigrah.dev:127.0.0.1 \
           -v $(pwd)/application:/var/www/diatigrah \
           -e APP_DEBUG=1 \
           -h web1.diatigrah.dev \
           -p 80:80 -d \
         diatigrah_web
fi
