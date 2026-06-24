#!/bin/sh
set -e

# Default to 1000 if not provided
UID=${UID:-1000}
GID=${GID:-1000}

echo "Starting with UID=$UID GID=$GID"

# Only modify user/group if needed
CURRENT_UID=$(id -u www-data)
CURRENT_GID=$(id -g www-data)

if [ "$CURRENT_GID" != "$GID" ]; then
    echo "Updating group www-data to GID $GID"
    groupmod -o -g "$GID" www-data
fi

if [ "$CURRENT_UID" != "$UID" ]; then
    echo "Updating user www-data to UID $UID"
    usermod -o -u "$UID" www-data
fi

# Fix permissions inside container
chown -R www-data:www-data /var/www

cd /var/www/html

# Optional composer step
if [ -f composer.json ]; then
    echo "Running composer install/update..."
    composer install || composer update
fi

# Start Apache in foreground
exec apache2-foreground
