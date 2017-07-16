FROM debian:8.7
MAINTAINER Sergey Izgiyaev <sergo27@gmail.com>

ARG PDNS_VERSION
ARG PDNS_MYSQL_VERSION

RUN apt-get update && apt-get install -y curl \
	&& curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - \
	&& echo "deb [arch=amd64] http://repo.powerdns.com/debian jessie-auth-40 main" > /etc/apt/sources.list.d/pdns.list

RUN apt-get update && apt-get install -y \
	pdns-server=${PDNS_VERSION} \
    pdns-backend-mysql=${PDNS_MYSQL_VERSION}
	
RUN apt-get autoremove -y -qq \
	&& apt-get clean -qq \
	&& rm -rf /var/lib/apt/lists/*

COPY ./valid_params.list /
COPY ./pdns_entrypoint.sh /bin/

RUN chmod +x /bin/pdns_entrypoint.sh

ENTRYPOINT ["pdns_entrypoint.sh", "-a", "pdns_server", "-c", "/etc/powerdns/pdns.conf"]