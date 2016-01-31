FROM phusion/baseimage:0.9.18

RUN add-apt-repository ppa:ondrej/php5-5.6 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key E5267A6C && \
    apt-get update && \
    apt-get install --assume-yes python-software-properties

# Install packages
RUN apt-get install --assume-yes --fix-missing \
        build-essential zlib1g-dev libpcre3 libpcre3-dev libssl-dev unzip \
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
        libxslt-dev

RUN cd && \
    wget https://github.com/pagespeed/ngx_pagespeed/archive/release-1.9.32.10-beta.zip && \
    unzip release-1.9.32.10-beta.zip
RUN cd && cd ngx_pagespeed-release-1.9.32.10-beta/ && \
    wget https://dl.google.com/dl/page-speed/psol/1.9.32.10.tar.gz && \
    tar -xzvf 1.9.32.10.tar.gz
RUN cd && \
    wget http://nginx.org/download/nginx-1.8.0.tar.gz && \
    tar -xvzf nginx-1.8.0.tar.gz
RUN cd && cd nginx-1.8.0/ && ./configure \
      --add-module=$HOME/ngx_pagespeed-release-1.9.32.10-beta \
      --without-http_autoindex_module \
      --without-http_ssi_module \
      --with-http_ssl_module \
      --with-http_gzip_static_module \
      --with-http_gunzip_module \
      --without-http_browser_module \
      --without-http_geo_module \
      --without-http_limit_req_module \
      --without-http_limit_conn_module \
      --without-http_memcached_module \
      --without-http_referer_module \
      --without-http_scgi_module \
      --without-http_split_clients_module \
      --without-http_ssi_module \
      --without-http_userid_module \
      --without-http_uwsgi_module && \
    make && make install && make clean

RUN apt-get autoremove --assume-yes && \
    apt-get remove --assume-yes build-essential zlib1g-dev libpcre3-dev libssl-dev unzip
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN cd && \
    rm -rf nginx-1.8.0* ngx_pagespeed-release-1.9.32.10-beta release-1.9.32.10-beta.zip
RUN mkdir -p /var/cache/ngx_pagespeed/
RUN chown -R root:www-data /var/cache/ngx_pagespeed
RUN chmod -R ug+rw /var/cache/ngx_pagespeed

RUN echo "Package: nginx \
Pin: version 1.8.0-pagespeed \
Pin-Priority: 1001" > /etc/apt/preferences.d/nginx

ADD docker/services/nginx/nginx.conf /etc/nginx/nginx.conf

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
RUN npm install -g npm

# Install composer
ENV PATH /root/.composer/vendor/bin:$PATH
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require "fxp/composer-asset-plugin:~1.0.3" && \
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

RUN rm -rf /usr/sbin/nginx && ln -s /usr/local/nginx/sbin/nginx /usr/sbin/

ADD application /var/www
ADD docker/run.sh /root/run.sh

ADD application/bin/wait-for-db.sh /wait-for-db.sh
RUN chmod a+x /wait-for-db.sh

WORKDIR /var/www

EXPOSE 80 9000

CMD ["/root/run.sh"]
