FROM quay.io/devurandom/c-dev:debian8.7-1

ENV LUA_VERSION=5.3

RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list \
	&& apt -y update \
	&& apt -y install -t jessie-backports lua${LUA_VERSION} liblua${LUA_VERSION}-dev \
	&& rm -fr /var/cache/apt

ENV LUAROCKS_VERSION=2.4.1

RUN apt -y update \
	&& apt -y install curl unzip \
	&& curl --fail --location https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz | tar -xzf - \
	&& cd luarocks-${LUAROCKS_VERSION} \
	&& ./configure \
		--prefix=/usr \
		--lua-version=${LUA_VERSION} \
		--versioned-rocks-dir \
	&& make bootstrap \
	&& cd \
	&& rm -fr luarocks-${LUAROCKS_VERSION} \
	&& rm -fr /var/cache/apt

RUN luarocks install \
		busted 2.0.rc12-1
