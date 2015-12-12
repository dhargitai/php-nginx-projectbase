#!/bin/bash

echo
read -p "Enter your project's name (all lowercase without any special character or space) and press [ENTER]: " projectname
read -p "Enter MySQL username and press [ENTER] (default: dev): " mysqluser
read -p "Enter MySQL password and press [ENTER] (default: dev123): " -s mysqlpass
echo

sed -i.bak "s%diatigrah%$projectname%g" setup.sh
sed -i.bak "s%diatigrah%$projectname%g" build.sh
sed -i.bak "s%diatigrah%$projectname%g" erase-everything.sh
sed -i.bak "s%diatigrah%$projectname%g" docker-compose.yml
sed -i.bak "s%diatigrah%$projectname%g" wait-for-webserver.sh
sed -i.bak "s%diatigrah%$projectname%g" docker/services/nginx/sites/default
sed -i.bak "s%/var/www/public%/var/www/$projectname/public%g" docker/services/nginx/sites/default

if [ "$mysqluser" != "" ]; then
  sed -i.bak "s%MYSQL_USER=dev%MYSQL_USER=$mysqluser%g" setup.sh
fi

if [ "$mysqlpass" != "" ]; then
  sed -i.bak "s%MYSQL_PASSWORD=dev123%MYSQL_PASSWORD=$mysqlpass%g" setup.sh
fi

echo "FROM diatigrah/php-nginx-projectbase:0.2.5

RUN npm install -g jshint

ADD docker/services/nginx/sites /etc/nginx/sites-enabled
ADD docker/services/php5-fpm/php.ini /etc/php5/fpm/conf.d/40-custom.ini

ADD application /var/www/$projectname
ADD docker/run.sh /root/run.sh

WORKDIR /var/www/$projectname
" > Dockerfile

echo "# $projectname project

This is a PHP project development environment built with Docker.

## Prerequisites

### Linux or OSX system

### Global environment file

Place a MySQL root password (mandatory) and your Github API token (optional) into the \`/opt/.common.env\` file on your host in the following format:
\`\`\`console
MYSQL_ROOT_PASSWORD=disIzMaiRutPezworld
GITHUB_API_TOKEN=somerandomcharactersinalongrow
\`\`\`

### Running Docker daemon or running Docker Machine with the name \`default\`

## Setup

### Initialize your environment

You have to do this only once.
\`\`\`console
./setup.sh
\`\`\`

## Build up your environment
\`\`\`console
./build.sh
\`\`\`

## Have a good work!
" > README.md

rm -rf .git *.bak docker/services/nginx/sites/*.bak
git init
git add .
git rm --cached setup-project.sh
git commit -m "Init $projectname project"

echo
echo "Your project files are ready. You can safely delete this file (setup-project.sh), push the others to your repository and have a party."
