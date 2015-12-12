#!/bin/bash

export $(cat .env | grep -v ^# | xargs)

docker-compose up -d --force-recreate

./wait-for-webserver.sh

echo; echo "Setting up permissions to the database..."
docker exec -it diatigrah_mysql /bin/bash -c "
    mysql -uroot -p$MYSQL_ROOT_PASSWORD << EOF
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* To '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* To '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
DROP DATABASE IF EXISTS $MYSQL_DATABASE;
EOF
"

echo; echo "Building project dependecies..."
docker exec -i diatigrah_web_1 /bin/bash < configure-web-node.sh

echo
echo "Ok, done! Let's work!"
