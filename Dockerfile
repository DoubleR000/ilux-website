FROM php:8.1-fpm-alpine

RUN set -ex \
    && apk --no-cache add \
    postgresql-dev

RUN docker-php-ext-install pdo pdo_pgsql

RUN mkdir -p /app
COPY . /app

RUN apk update && apk add nodejs npm

WORKDIR /app
RUN npm install
RUN npm run build

WORKDIR /
RUN apk add --no-cache nginx wget

RUN mkdir -p /run/nginx

COPY ./Docker/nginx.conf /etc/nginx/nginx.conf

RUN sh -c "wget http://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer"
RUN cd /app && \
    /usr/local/bin/composer install --no-dev

RUN chown -R www-data: /app

CMD sh /app/Docker/startup.sh
#================================================================================================================
# RUN apt-get update -y
# RUN apt-get install -y unzip libpq-dev libcurl4-gnutls-dev
# RUN docker-php-ext-install pdo pdo_mysql bcmath

# RUN pecl install -o -f redis \
#     && rm -rf /tmp/pear \
#     && docker-php-ext-enable redis

# WORKDIR /var/www
# COPY . .

# COPY --from=composer:2.4.0 /usr/bin/composer /usr/bin/composer

# ENV PORT=8000
# ENTRYPOINT [ "docker/entrypoint.sh" ]

# # ====================================================================
# # node

# FROM node:16.16.0-alpine as node

# WORKDIR /var/www
# COPY . .

# RUN npm install --global cross-env
# RUN npm install

# VOLUME /var/www/node_modules
