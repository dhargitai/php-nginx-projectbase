#!/bin/bash

export $(cat .env | grep -v ^# | xargs)

echo "Deleting all related Docker containers and images..."
if [ $(docker ps -a | grep diatigrah_mysql | wc -l) -eq 1 ]; then
    docker exec -it diatigrah_mysql /bin/bash -c "
        mysql -uroot -p$MYSQL_ROOT_PASSWORD << EOF
DROP DATABASE IF EXISTS $MYSQL_DATABASE;
EOF
"
fi

echo "Deleting all related Docker containers and images..."
docker-compose stop web && docker-compose rm -f web
docker-compose stop database && docker-compose rm -f database
if [ $(docker images | grep diatigrah_web | wc -l) -eq 1 ]; then
    docker rmi -f diatigrah_web
fi

echo "Removing project from hosts file..."
if [ $EUID != 0 ]; then
    grep -v "$DOCKER_IP diatigrah.dev diatigrah.test" /etc/hosts > temp && sudo mv temp /etc/hosts
fi

echo "Deleting vendor files..."
rm -rf application/vendor

echo "Deleting build files..."
rm -rf application/build

echo "Done."
