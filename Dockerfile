FROM php:8.4-apache

ENV UID=1000
ENV GID=1000
ENV USERNAME=www-data

# Install system dependencies needed by Composer
RUN apt-get update && apt-get install -y \
    curl \
    imagemagick \
    unzip \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl gd zip exif mysqli pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Install Composer (official method)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Apache + PHP configs
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./docker-php.conf /etc/apache2/conf-available/docker-php.conf
COPY ./apache2.conf /etc/apache2/apache2.conf
COPY ./php-custom.ini /usr/local/etc/php/conf.d/php-custom.ini
COPY ./start.sh /var/www/start.sh

WORKDIR /var/www/html

RUN usermod -u $UID www-data && groupmod -g $GID www-data

# Make start script executable
RUN chmod +x /var/www/start.sh

EXPOSE 80

CMD ["/var/www/start.sh"]