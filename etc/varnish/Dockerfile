FROM phusion/baseimage

MAINTAINER Nil Portugués Calderó <contact@nilportugues.com>

CMD ["/sbin/my_init"]

# Update the package repository and install applications
RUN apt-get update -qq && \
  apt-get upgrade -yqq && \
  apt-get -yqq install varnish && \
  apt-get -yqq clean

# Make our custom VCLs available on the container
ADD templates/default.vcl /etc/varnish/default.vcl

ENV VARNISH_BACKEND_PORT 8000
ENV VARNISH_BACKEND_IP 172.17.42.1
ENV VARNISH_PORT 80

EXPOSE 80
EXPOSE 443

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]