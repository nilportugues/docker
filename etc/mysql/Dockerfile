FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean &&  apt-get update
RUN apt-get install -y mysql-server

ADD templates/my.cnf /etc/mysql/my.cnf

RUN /usr/sbin/mysqld & \
    sleep 10s &&\
    echo "CREATE USER 'master'@'%' IDENTIFIED BY 'writter';GRANT ALL PRIVILEGES ON *.* TO 'master'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

RUN /usr/sbin/mysqld & \
    sleep 10s &&\
    echo "CREATE USER 'slave'@'%' IDENTIFIED BY 'reader';GRANT SELECT ON *.* TO 'slave'@'%'; FLUSH PRIVILEGES" | mysql

EXPOSE 3306
CMD ["/usr/bin/mysqld_safe"]
