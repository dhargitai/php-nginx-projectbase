FROM debian:jessie

# Install packages
RUN apt-get update -qq && \
    apt-get install -y --fix-missing \
        g++ \
        build-essential \
        nginx \
        supervisor \
        curl \
        wget \
        vim \
        git \
        php5-fpm \
        php5-mysql \
        php5-mcrypt \
        php5-gd \
        php5-memcached \
        php5-curl \
        php5-xdebug \
        php5-xsl \
        php5-apcu \
        libicu-dev \
        libmcrypt-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libjpeg-dev \
        zlib1g-dev \
        libffi-dev \
        libssl-dev \
        libxslt-dev && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> ~/.bash_profile
RUN echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

# Install ruby-build
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN /usr/local/rbenv/plugins/ruby-build/install.sh

ENV PATH /usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set to Ruby 2.2.0
RUN rbenv install 2.2.0
RUN rbenv rehash
RUN rbenv global 2.2.0

# Install Compass
RUN eval "$(rbenv init -)" && gem install compass

# Install Bower
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
RUN npm install -g bower

# Install Composer
ENV PATH /root/.composer/vendor/bin:$PATH
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require "fxp/composer-asset-plugin:1.0.0" && \
    composer global dumpautoload --optimize

# Create required directories
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /etc/nginx
RUN mkdir -p /var/run/php5-fpm

# Add configuration files
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD docker/php.ini /etc/php5/fpm/conf.d/40-custom.ini
ADD docker/sites /etc/nginx/sites-enabled

ADD application /var/www
ADD docker/run.sh /root/run.sh

WORKDIR /var/www

EXPOSE 80 9000

CMD ["/root/run.sh"]
