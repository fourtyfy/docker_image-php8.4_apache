FROM php:8.4-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
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

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Apache modules
RUN a2enmod rewrite headers

# Config files
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./docker-php.conf /etc/apache2/conf-available/docker-php.conf
COPY ./apache2.conf /etc/apache2/apache2.conf
COPY ./php-custom.ini /usr/local/etc/php/conf.d/php-custom.ini
COPY ./start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

WORKDIR /var/www/html

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
