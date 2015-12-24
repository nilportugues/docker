FROM phusion/baseimage

MAINTAINER Nil Portugués Calderó <contact@nilportugues.com>

CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y python-software-properties
RUN add-apt-repository ppa:nginx/stable
RUN apt-get update && apt-get install -y nginx nginx-extras

ADD config/mime.types /etc/nginx/mime.types
ADD config/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/log/nginx
RUN mkdir -p /usr/share/nginx/logs/
RUN mkdir -p /etc/nginx/sites-available/
RUN mkdir -p /etc/nginx/sites-enabled/
RUN mkdir -p /etc/nginx/logs/
RUN mkdir -p /etc/nginx/helpers/
RUN mkdir -p /etc/service/nginx

RUN touch /etc/nginx/logs/error.log
RUN touch /etc/nginx/helpers/extra.conf
RUN touch /var/log/nginx/access.log
RUN touch /var/log/nginx/error.log
RUN touch /usr/share/nginx/logs/error.log

ADD start.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run


EXPOSE 8080
EXPOSE 4430

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

