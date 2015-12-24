FROM ubuntu:14.04

MAINTAINER Nil Portugués Calderó <contact@nilportugues.com>

# Configure timezone and locale
RUN echo "Europe/Madrid" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=es_ES.UTF-8 && export LANG=es_ES.UTF-8 && export LC_ALL=es_ES.UTF-8 && locale-gen es_ES.UTF-8 && dpkg-reconfigure locales

# Update the package repository
RUN apt-get clean && apt-get update

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    locales \
    supervisor

ADD ./templates/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/www/brokers
WORKDIR /var/www/brokers
RUN export ENV=dev
CMD ["/usr/bin/supervisord"]
