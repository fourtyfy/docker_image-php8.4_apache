#!/bin/sh

rm -R /var/www/html
ln -s ~ /var/www/html
chown -R www-data:www-data /var/www
cd /var/www/html

if [ -f composer.json ]; then
    echo "Running composer update..."
    composer update
fi

a2enmod rewrite
apache2-foreground
