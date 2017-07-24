FROM debian:8.7
MAINTAINER Sergey Izgiyaev <sergo27@gmail.com>

ARG PDNS_VERSION
ARG PDNS_MYSQL_VERSION

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y curl ca-certificates netcat host && \
	curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - && \
	echo "deb [arch=amd64] http://repo.powerdns.com/debian jessie-auth-40 main" > /etc/apt/sources.list.d/pdns.list && \
	apt-get update && apt-get install -y \
	pdns-server=${PDNS_VERSION} \
    pdns-backend-mysql=${PDNS_MYSQL_VERSION} && \
	apt-get purge curl ca-certificates -y && \
	apt-get autoremove -y -qq && \
	apt-get clean -qq && \
	rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /bin/

STOPSIGNAL SIGTERM

RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]