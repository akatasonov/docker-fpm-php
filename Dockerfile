FROM	php:7.3-fpm-alpine

LABEL	maintainer "https://github.com/akatasonov"

# intl, zip, soap
RUN apk add --update --no-cache libintl icu icu-dev libxml2-dev libzip-dev \
    && docker-php-ext-install intl zip soap

# mysqli, pdo, pdo_mysql, pdo_pgsql
RUN apk add --update --no-cache postgresql-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql

# sodium, gd, iconv
RUN apk add --update --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
#    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" iconv sodium \
#    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd

# gmp
RUN apk add --update --no-cache gmp gmp-dev \
    && docker-php-ext-install gmp

# php-redis
ENV PHPREDIS_VERSION="5.2.2"

RUN docker-php-source extract \
    && curl -L -o /tmp/redis.tar.gz "https://github.com/phpredis/phpredis/archive/${PHPREDIS_VERSION}.tar.gz" \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis \
    && docker-php-source delete

# Memcached
#RUN apk add --no-cache libmemcached-dev zlib-dev cyrus-sasl-dev git \
#    && docker-php-source extract \
#    && git clone --branch php7 https://github.com/php-memcached-dev/php-memcached.git /usr/src/php/ext/memcached/ \
#    && docker-php-ext-configure memcached \
#    && docker-php-ext-install memcached \
#    && docker-php-source delete \
#    && apk del --no-cache zlib-dev cyrus-sasl-dev git

# apcu
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

# imagick
RUN apk add --update --no-cache autoconf g++ imagemagick-dev pcre-dev libtool make \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del autoconf g++ libtool make pcre-dev

# ssh2
#RUN apk add --update --no-cache autoconf g++ libtool make pcre-dev libssh2 libssh2-dev libssh2-1-dev\
#    && pecl install ssh2-1 \
#    && docker-php-ext-enable ssh2 \
#    && apk del autoconf g++ libtool make pcre-dev

# Phalcon
RUN apk add --update --no-cache autoconf g++ libtool make pcre-dev git \
    && docker-php-source extract \
    && git clone --single-branch --branch 3.4.x https://github.com/phalcon/cphalcon /usr/src/php/ext/cphalcon \
    && cd /usr/src/php/ext/cphalcon/build \
    && ./install \
    && docker-php-source delete \
    && echo 'extension=phalcon.so' > /usr/local/etc/php/conf.d/30-phalcon.ini \
    && apk del autoconf g++ libtool make pcre-dev git

# set recommended opcache PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.validate_timestamps=0'; \
		#echo 'opcache.revalidate_freq=60'; \
		#echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
} > $PHP_INI_DIR/conf.d/opcache-recommended.ini

# set recommended apcu PHP.ini settings
# see https://secure.php.net/manual/en/apcu.configuration.php
RUN { \
        echo 'apc.shm_segments=1'; \
        echo 'apc.shm_size=256M'; \
        echo 'apc.num_files_hint=7000'; \
        echo 'apc.user_entries_hint=4096'; \
        echo 'apc.ttl=7200'; \
        echo 'apc.user_ttl=7200'; \
        echo 'apc.gc_ttl=3600'; \
        echo 'apc.max_file_size=1M'; \
        echo 'apc.stat=1'; \
} > $PHP_INI_DIR/conf.d/apcu-recommended.ini

RUN sed -i -e 's/pm\s=.*/pm = static/' /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -e 's/pm.max_children.*/pm.max_children = 30/' /usr/local/etc/php-fpm.d/www.conf


# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Clean up
RUN rm -rf /tmp/* /var/cache/apk/*

CMD ["php-fpm"]
