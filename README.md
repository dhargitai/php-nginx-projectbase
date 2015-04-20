# PHP - nginx project base using Docker

This is a simple PHP-nginx base project skeleton built with Docker.
If you want to start a new project on the top of it, you have to...

## Clone it
```console
git clone git@github.com:dhargitai/php-nginx-projectbase.git myproject
cd myproject
```

## Edit the Dockerfile to build a new image on the top of this base image, for example:
```console
FROM diatigrah/php-nginx-projectbase

composer config -g github-oauth.github.com YOUR-OAUTH-TOKEN
```

## Build it
```console
./build.sh
```
