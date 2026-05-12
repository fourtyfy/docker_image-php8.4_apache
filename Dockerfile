FROM php:8.4-apache

ENV UID=1000
ENV GID=1000
ENV USER=dev

# Install system dependencies needed by Composer
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

# Install Composer (official method)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer


# Create/update www-data group with GID 1000
# Create dev user with UID 1000 and primary group www-data
# Ensure www-data user uses www-data as primary group
RUN set -eux; \
    if getent group www-data >/dev/null; then \
        groupmod -g 1000 www-data; \
    else \
        groupadd -g 1000 www-data; \
    fi; \
    if ! id -u $USER >/dev/null 2>&1; then \
        useradd -m -u 1000 -g www-data -s /bin/bash $USER; \
    fi; \
    if id -u www-data >/dev/null 2>&1; then \
        usermod -g www-data www-data; \
    else \
        useradd -r -g www-data -s /usr/sbin/nologin www-data; \
    fi; \
    usermod -aG www-data $USER

# Apache + PHP configs
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./docker-php.conf /etc/apache2/conf-available/docker-php.conf
COPY ./apache2.conf /etc/apache2/apache2.conf
COPY ./php-custom.ini /usr/local/etc/php/conf.d/php-custom.ini
COPY ./start.sh /home/$USER/start.sh

WORKDIR /home/$USER

# Make start script executable
RUN chmod +x /home/$USER/start.sh

EXPOSE 80

CMD ["/home/$USER/start.sh"]
