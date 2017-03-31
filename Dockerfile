FROM quay.io/devurandom/c-dev:debian8.7-1

RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list \
	&& apt -y update \
	&& apt -y install -t jessie-backports liblua5.3-dev \
	&& rm -fr /var/cache/apt
