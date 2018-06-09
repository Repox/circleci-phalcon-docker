FROM ubuntu:16.04

MAINTAINER Dan Storm

RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update \
    && apt-get install -y curl zip unzip git software-properties-common wget mysql-client \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php7.1-fpm php7.1-cli php7.1-mcrypt php7.1-gd php7.1-mysql php7.1-intl \
       php7.1-pgsql php7.1-imap php-memcached php7.1-mbstring php7.1-xml php7.1-curl php7.1-dev \
       gcc libpcre3-dev \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php \
    && apt-get remove -y --purge software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /root/cphalcon \
    && git clone --branch v3.2.2 --single-branch --depth 1 https://github.com/phalcon/cphalcon.git /root/cphalcon \
    && cd /root/cphalcon/build \
    && ./install --phpize /usr/bin/phpize7.1 --php-config /usr/bin/php-config7.1 \
    && cd ~

ADD phalcon.ini /etc/php/7.1/mods-available/phalcon.ini

RUN ln -s /etc/php/7.1/mods-available/phalcon.ini /etc/php/7.1/cli/conf.d/30-phalcon.ini \
    && ln -s /etc/php/7.1/mods-available/phalcon.ini /etc/php/7.1/fpm/conf.d/30-phalcon.ini

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g apidoc

RUN wget -O phpunit https://phar.phpunit.de/phpunit-7.phar \
    && chmod +x ./phpunit \
    && mv ./phpunit /usr/local/bin/phpunit

ADD php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf
ADD www.conf /etc/php/7.1/fpm/pool.d/www.conf

EXPOSE 9000
CMD ["php-fpm7.1"]
