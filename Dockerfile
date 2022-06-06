FROM migrate/migrate:latest as migrate
FROM composer:2.3.5 as composer

FROM migrate as migrations
LABEL quay.expires-after=30d
COPY ./migrations /migrations
ENTRYPOINT migrate -path /migrations -database postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB?sslmode=disable up

FROM nginx/unit:1.27.0-php8.1 as base
RUN apt-get update && apt-get install -y libpq-dev && \
    docker-php-ext-install pdo_pgsql && \
    docker-php-ext-enable opcache && \
    rm -rf /var/lib/apt/lists/* && \
    apt autoremove
COPY ./docker/php/10-common.ini /usr/local/etc/php/conf.d/
WORKDIR /opt/authorization
EXPOSE 8080

FROM composer as code
COPY ./app/composer.* /app/
RUN composer install --prefer-dist --no-progress -n --ignore-platform-reqs

FROM base as dev
RUN addgroup --system --gid 1000 host && \
    adduser --system --disabled-password --gid 1000 --uid 1000 host && \
    apt-get update && apt-get install -y git unzip && \
    pecl install xdebug-3.1.4 && \
    docker-php-ext-enable xdebug && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
COPY --from=migrate /usr/local/bin/migrate /usr/bin/migrate
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY ./docker/nginx-unit/config.dev.json /docker-entrypoint.d/config.json
COPY ./docker/php/90-*.ini /usr/local/etc/php/conf.d/
VOLUME ["/opt/authorization"]