FROM phusion/baseimage:0.9.17

RUN add-apt-repository ppa:ondrej/php5-5.6 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key E5267A6C && \
    apt-get update && \
    apt-get install --assume-yes python-software-properties && \
    apt-get update

# Install packages
RUN apt-get install --assume-yes --fix-missing \
        nginx \
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
        curl \
        wget \
        vim \
        git \
        libxslt-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
RUN npm install -g npm

# Install composer
ENV PATH /root/.composer/vendor/bin:$PATH
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require "fxp/composer-asset-plugin:1.0.0" && \
    composer global dumpautoload --optimize

ADD docker/services/.vimrc /root/.vimrc

# Add nginx
RUN mkdir -p /etc/nginx
RUN mkdir -p /etc/service/nginx
ADD docker/services/nginx/nginx.sh /etc/service/nginx/run
ADD docker/services/nginx/sites /etc/nginx/sites-enabled

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
