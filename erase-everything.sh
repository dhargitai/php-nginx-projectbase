#!/bin/bash

echo "Deleting all related Docker containers and images..."
if [ $(docker ps -a | grep diatigrah_mysql | wc -l) -eq 1 ]; then
  docker rm -f diatigrah_mysql
fi
if [ $(docker ps -a | grep diatigrah_dataonly_mysql | wc -l) -eq 1 ]; then
  docker rm -f diatigrah_dataonly_mysql
fi
if [ $(docker ps -a | grep diatigrah_web_1 | wc -l) -eq 1 ]; then
  docker rm -f diatigrah_web_1
fi
if [ $(docker images | grep diatigrah_web | wc -l) -eq 1 ]; then
  docker rmi -f diatigrah_web
fi

echo "Removing project from hosts file..."
if [ $EUID != 0 ]; then
    sudo sed -i.bak '/192.168.99.100 diatigrah.dev diatigrah.test/d' /etc/hosts
    sudo rm -rf /etc/hosts.bak
fi

echo "Done."
