FROM php:8.1-apache

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY ./atttntproject/composer.* ./

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        zip \
        unzip \
        ffmpeg \
        imagemagick \
        ghostscript

# Modify ImageMagick policy file if it exists
RUN if [ -f /etc/ImageMagick-6/policy.xml ]; then \
        sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml; \
        elif [ -f /etc/ImageMagick/policy.xml ]; then \
        sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick/policy.xml; \
        fi

RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype
RUN docker-php-ext-install gd

# Update composer lock file before installing dependencies
RUN composer update --no-scripts --no-interaction

# Install dependencies from the updated lock file
RUN composer install --prefer-dist --no-scripts --no-dev --no-progress --no-interaction

COPY ./atttntproject ./

COPY ./apache/default.conf /etc/apache2/sites-available/000-default.conf

COPY ./atttntproject/.htaccess /var/www/html/.htaccess

RUN composer dump-autoload --optimize --classmap-authoritative

RUN chown -R www-data:www-data /var/www/html

RUN a2enmod headers rewrite


