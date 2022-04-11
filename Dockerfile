ARG PHP_VERSION=8.0

FROM php:${PHP_VERSION}-fpm-bullseye as base

# require dependencies install pkgs and install php extensions.
RUN apt-get update -qq \
  && apt-get install -qy --no-install-recommends --no-install-suggests git unzip zip vim libonig-dev \
  && docker-php-ext-install mbstring pdo_mysql \
  && rm -rf /var/lib/apt/lists/*

# php config
RUN { \
    echo "[www]";\
    echo "memory_limit = 256M";\
    echo "upload_max_filesize = 32M";\
    echo "post_max_size = 32M";\
    echo "max_execution_time = 180";\
    echo "default_socket_timeout = 180";\
    echo "error_log = /dev/stderr";\
    echo "access_log = /dev/stdout";\
    echo "display_errors = On";\
  } > /usr/local/etc/php-fpm.d/zz-www.ini

# composer
RUN curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer \
  && composer self-update

ENV COMPOSER_ALLOW_SUPERUSER 1

WORKDIR /var/www/html
