#!/bin/bash

if [ $(docker ps -a | grep diatigrah_mysql | wc -l) -eq 1 ]; then
  docker rm -f diatigrah_mysql
fi
if [ $(docker ps -a | grep diatigrah_web_1 | wc -l) -eq 1 ]; then
  docker rm -f diatigrah_web_1
fi
if [ $(docker images | grep diatigrah_web | wc -l) -eq 1 ]; then
  docker rmi -f diatigrah_web
fi
if [ $(docker ps -a | grep diatigrah_dataonly_mysql | wc -l) -eq 0 ]; then
  docker create --name diatigrah_dataonly_mysql arungupta/mysql-data-container
fi

docker build -t diatigrah_web .

./start.sh

./wait-for-webserver.sh

docker exec -it diatigrah_web_1 su www-data -s /bin/bash -c '
    composer install --ansi --prefer-dist --no-interaction
'

echo ""
echo "Ok, done! Let's work!"
