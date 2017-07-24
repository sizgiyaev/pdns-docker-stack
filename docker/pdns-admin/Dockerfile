FROM debian:8.7
MAINTAINER Sergey Izgiyaev <sergo27@gmail.com>

ARG POWERADMIN_VERSION

ENV DEBIAN_FRONTEND noninteractive

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests wget ca-certificates \
                                        apache2 php5 php5-mysql libapache2-mod-php5 php5-mcrypt netcat \
                                        -y && \
    wget -O /tmp/poweradmin.tgz https://netix.dl.sourceforge.net/project/poweradmin/poweradmin-${POWERADMIN_VERSION}.tgz && \
    tar zxf /tmp/poweradmin.tgz -C /tmp && \
    rm /var/www/html/index.html && \
    mv /tmp/poweradmin-${POWERADMIN_VERSION}/* /var/www/html/ && \
    rm -Rf /tmp/poweradmin* && \
    apt-get purge wget ca-certificates -y && \
    apt-get autoremove -y -qq && \
	apt-get clean -qq && \
	rm -rf /var/lib/apt/lists/* &&\
    rm -Rf /var/www/html/install

RUN /usr/sbin/a2dismod 'mpm_*' && \
    /usr/sbin/a2enmod mpm_prefork 
    # && \
    #/usr/sbin/a2ensite default-ssl
    #/usr/sbin/a2enmod ssl

COPY ./add_mysql_tables.php /
COPY ./poweradmin_mysql.sql /

COPY ./entrypoint.sh /bin/
RUN chmod +x /bin/entrypoint.sh

STOPSIGNAL SIGTERM

ENTRYPOINT ["entrypoint.sh"]
