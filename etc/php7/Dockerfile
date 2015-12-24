FROM php:7.0-fpm

MAINTAINER Nil Portugués Calderó <contact@nilportugues.com>

# Configure timezone and locale
RUN echo "Europe/Madrid" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=es_ES.UTF-8 && export LANG=es_ES.UTF-8 && export LC_ALL=es_ES.UTF-8 && locale-gen es_ES.UTF-8 && dpkg-reconfigure locales

RUN apt-get update && apt-get install -y libicu-dev\
	build-essential \
	sqlite sqlite3 \
	libpcre3 \
	libpcre3-dev \
	libmcrypt-dev \
    && apt-get clean

RUN docker-php-ext-install pdo pdo_mysql opcache intl iconv mcrypt