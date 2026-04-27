#!/bin/sh

chown -R www-data:www-data /var/www/html
cd /var/www/html

if [ -f composer.json ]; then
    echo "Running composer update..."
    composer update
fi

a2enmod rewrite
apache2-foreground