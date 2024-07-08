FROM php:8.1-apache

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY ./app/composer.* ./

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        zip \
        unzip \
        ffmpeg \
        imagemagick 

RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype
RUN docker-php-ext-install gd

RUN composer install --prefer-dist --no-scripts --no-dev --no-progress --no-interaction

COPY ./app ./

COPY ./apache/default.conf /etc/apache2/sites-available/000-default.conf

RUN composer dump-autoload --optimize --classmap-authoritative

RUN chown -R www-data:www-data /var/www/html

RUN a2enmod headers rewrite


