#!/usr/bin/env bash

#
# Following commands expected to run with root privileges
#
echo; echo "Trying to set up file permissions..." &&
chown -R www-data: .

su www-data -s /bin/bash

if [ -n "$GITHUB_API_TOKEN" ]; then
    echo; echo "Configuring Composer to use your Github API token..."
    composer config -g github-oauth.github.com $GITHUB_API_TOKEN
fi

echo; echo "Installing composer packages..." &&
composer install --ansi --prefer-dist --no-interaction

exit 0