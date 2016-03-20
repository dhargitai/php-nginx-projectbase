FROM diatigrah/nginx:1.9.12

RUN add-apt-repository ppa:ondrej/php5-5.6 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key E5267A6C && \
    apt-get update && \
    apt-get install --assume-yes python-software-properties

# Install packages
RUN apt-get install --assume-yes --fix-missing \
        build-essential zlib1g-dev libpcre3 libpcre3-dev libssl-dev unzip \
        php5 \
        php5-fpm \
        php5-mysql \
        php5-mcrypt \
        php5-gd \
        php5-memcached \
        php5-curl \
        php5-xdebug \
        php5-xsl \
        php5-apcu \
        php5-intl \
        php5-ldap \
        php5-sqlite \
        php5-pgsql \
        php-pear \
        php5-xmlrpc \
        libxslt-dev

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
RUN npm install -g npm

# Clean
RUN apt-get autoremove --assume-yes && \
    apt-get remove --assume-yes build-essential zlib1g-dev libpcre3-dev libssl-dev unzip
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install composer
ENV PATH /root/.composer/vendor/bin:$PATH
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require "fxp/composer-asset-plugin:~1.0.3" && \
    composer global dumpautoload --optimize

# Add php fpm
RUN mkdir -p /var/run/php5-fpm
RUN mkdir -p /etc/service/php5-fpm
ADD docker/services/php5-fpm/php5-fpm.sh /etc/service/php5-fpm/run
ADD docker/services/php5-fpm/php.ini /etc/php5/fpm/conf.d/40-custom.ini

ADD application /var/www
ADD docker/run.sh /root/run.sh

ADD application/bin/wait-for-db.sh /wait-for-db.sh
RUN chmod a+x /wait-for-db.sh

WORKDIR /var/www

EXPOSE 80 9000

CMD ["/root/run.sh"]
