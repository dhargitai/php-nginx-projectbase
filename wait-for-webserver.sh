#!/bin/bash
echo "Waiting for the webserver..."

until [[ "`docker exec diatigrah_web_1 /bin/sh -c 'service nginx status'`" == *"nginx is running"* ]]; do
    printf "."
    sleep 5;
done;
echo " Got it!"
