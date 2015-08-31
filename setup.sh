#!/bin/bash

echo
read -p "Enter your project's name (all lowercase without any special character or space) and press [ENTER]: " projectname
read -p "Enter your Github API token if you'll use Composer and press [ENTER]: " githubtoken
read -p "Enter MySQL username and press [ENTER] (default: dev): " mysqluser
read -p "Enter MySQL password and press [ENTER] (default: dev123): " -s mysqlpass
echo
read -p "Enter MySQL root password and press [ENTER] (default: supersecret): " -s mysqlrootpass
echo

sed -i.bak "s%diatigrah%$projectname%g" build.sh
sed -i.bak "s%diatigrah%$projectname%g" start.sh
sed -i.bak "s%diatigrah%$projectname%g" stop.sh
sed -i.bak "s%diatigrah%$projectname%g" wait-for-webserver.sh
sed -i.bak "s%diatigrah%$projectname%g" erase-everything.sh
sed -i.bak "s%diatigrah%$projectname%g" docker/services/nginx/sites/default
sed -i.bak "s%/var/www/public%/var/www/$projectname/public%g" docker/services/nginx/sites/default

if [ "$mysqluser" != "" ]; then
  sed -i.bak "s%MYSQL_USER=dev%MYSQL_USER=$mysqluser%g" start.sh
fi

if [ "$mysqlpass" != "" ]; then
  sed -i.bak "s%MYSQL_PASSWORD=dev123%MYSQL_PASSWORD=$mysqlpass%g" start.sh
fi

if [ "$mysqlrootpass" != "" ]; then
  sed -i.bak "s%MYSQL_ROOT_PASSWORD=supersecret%MYSQL_ROOT_PASSWORD=$mysqlrootpass%g" start.sh
fi

echo "FROM diatigrah/php-nginx-projectbase:0.2.4

ADD docker/services/nginx/sites /etc/nginx/sites-enabled
ADD docker/services/php5-fpm/php.ini /etc/php5/fpm/conf.d/40-custom.ini

ADD application /var/www/$projectname
ADD docker/run.sh /root/run.sh

WORKDIR /var/www/$projectname
" > Dockerfile

if [ "$githubtoken" != "" ]; then
echo "RUN composer config -g github-oauth.github.com $githubtoken" >> Dockerfile
fi

rm -rf .git *.bak docker/services/nginx/sites/*.bak
git init

echo "192.168.99.100 $projectname.dev $projectname.test" | sudo tee -a /etc/hosts

echo
echo "Ok, your files are ready. You can safely delete this file and build your environment by running build.sh"
