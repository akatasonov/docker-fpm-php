## Make your FPM-PHP fly on Alpine

### Overview
This is a Dockerfile/image to build a container for FPM-PHP.
Most of the regular needed modules (apcu, opcache, php-redis, etc.) are built in and configured like suggested on [php.net](https://secure.php.net/).<br>
Additionally Phalcon framework is installed as a module.<br>

### Features
* intl, zip, soap
* mysqli, pdo, pdo_mysql, pdo_pgsql
* sodium, gd, iconv
* gmp
* php-redis
* memcached
* opcache ([configuration reference](https://secure.php.net/manual/en/opcache.installation.php))
* apcu ([configuration reference](https://secure.php.net/manual/en/apcu.configuration.php))
* imagick
* ssh2
* phalcon 3.4

### Basic Usage
This Image is intended to be used along with an external webserver container like apache or nginx.
I personally prefer nginx over apache. If you are interested in how to setup nginx along with this fpm-php image, take a look at [my docker-compose files](https://github.com/Hermsi1337/docker-compose/blob/master/full_php_dev_stack/docker-compose.yml).
