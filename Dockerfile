FROM php:7.3-fpm

LABEL maintainer="Johan van Helden <johan@johanvanhelden.com>"

# Set environment variables
ARG TZ=Europe/Amsterdam
ENV TZ ${TZ}

# Install dependencies
RUN apt-get update && apt-get install -y \
    mariadb-client \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libcurl4-nss-dev \
    libc-client-dev \
    libkrb5-dev \
    firebird-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    autoconf \
    wget \
    zip \
    unzip \
    cron \
    git \
    libssh2-1-dev \
    libzip-dev \
    locales-all \
    libmagickwand-dev

RUN printf "\n" | pecl install imagick

# Install the Oracle client
RUN mkdir /opt/oracle \
    && cd /opt/oracle

RUN wget -O /opt/oracle/instantclient-basic-linux.x64-19.5.0.0.0dbru.zip https://github.com/johanvanhelden/dockerhero-oracle/raw/master/19.5/instantclient-basic-linux.x64-19.5.0.0.0dbru.zip && \
    wget -O /opt/oracle/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip https://github.com/johanvanhelden/dockerhero-oracle/raw/master/19.5/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip && \
    unzip /opt/oracle/instantclient-basic-linux.x64-19.5.0.0.0dbru.zip -d /opt/oracle && \
    unzip /opt/oracle/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip -d /opt/oracle && \
    rm -rf /opt/oracle/*.zip

RUN ln -s /opt/oracle/instantclient_19_5/libclntshcore.so.19.1 /opt/oracle/instantclient_19_5/libclntshcore.so

ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_19_5:${LD_LIBRARY_PATH}

RUN echo 'instantclient,/opt/oracle/instantclient_19_5/' | pecl install oci8

RUN docker-php-ext-install -j$(nproc) curl \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-install -j$(nproc) mbstring \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-install -j$(nproc) interbase \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) soap \
    && docker-php-ext-install -j$(nproc) xmlrpc \
    && docker-php-ext-install -j$(nproc) xsl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-install zip \
    && docker-php-ext-enable oci8 \
    && docker-php-ext-enable imagick \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_19_5,19.5 \
    && docker-php-ext-install pdo_oci

# redis module
RUN \
    pecl install -o -f redis \
    &&  echo "extension=redis.so" > /usr/local/etc/php/conf.d/ext-redis.ini

# ssh2 module
RUN cd /tmp && git clone https://git.php.net/repository/pecl/networking/ssh2.git && cd /tmp/ssh2 \
    && phpize && ./configure && make && make install \
    && echo "extension=ssh2.so" > /usr/local/etc/php/conf.d/ext-ssh2.ini \
    && rm -rf /tmp/ssh2

# Set the timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install the xdebug extension
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

# Comment out xdebug extension line per default
RUN sed -i 's/^zend_extension=/;zend_extension=/g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Copy xdebug configration for remote debugging
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Copy the php-fpm config
COPY ./dockerhero.fpm.conf /usr/local/etc/php-fpm.d/zzz-dockerhero.fpm.conf
COPY ./dockerhero.php.ini /usr/local/etc/php/conf.d/dockerhero.php.ini

# Setup mhsendmail
COPY ./mhsendmail_linux_amd64 /usr/local/bin/mhsendmail
RUN chmod +x /usr/local/bin/mhsendmail

# Cleanup all downloaded packages
RUN apt-get -y autoclean && apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/* && apt-get update

# Set the proper permissions
RUN usermod -u 1000 www-data

# Add the startup script and set executable
COPY ./.startup.sh /var/scripts/.startup.sh
RUN chmod +x /var/scripts/.startup.sh

# Run the startup script
CMD ["/var/scripts/.startup.sh"]
