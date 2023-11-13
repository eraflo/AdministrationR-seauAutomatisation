FROM php:8.2-apache

RUN a2enmod rewrite && a2enmod headers

RUN apt update && \
apt install libldap2-dev -y && \
docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
docker-php-ext-install ldap

COPY ./src /var/www/html

CMD ["apache2-foreground"]
