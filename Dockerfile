FROM quay.io/devurandom/c-dev:debian8.7-1

ENV LUA_VERSIONS="5.1 5.2 5.3"

RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list \
	&& apt -y update \
	&& apt -y install -t jessie-backports \
		curl \
		unzip \
		$(for v in ${LUA_VERSIONS} ; do \
			echo lua${v} liblua${v}-dev \
		; done) \
	&& rm -fr /var/cache/apt

ENV LUAROCKS_VERSION=2.4.1

RUN curl --fail --location https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz | tar -xzf - \
	&& cd luarocks-${LUAROCKS_VERSION} \
	&& for v in ${LUA_VERSIONS} ; do \
		apiv=$(lua${v} -e 'print(_VERSION)' | cut -d' ' -f2) ; \
		echo "Building for lua${v} (API: ${apiv})" ; \
		./configure \
			--prefix=/usr \
			--lua-suffix=${v} \
			--lua-version=${apiv} \
			--versioned-rocks-dir \
		&& make bootstrap \
		|| exit \
		; done \
	&& cd \
	&& rm -fr luarocks-${LUAROCKS_VERSION}

RUN for v in ${LUA_VERSIONS} ; do \
	echo "Building for lua${v}" ; \
	luarocks-${v} install \
		busted 2.0.rc12-1 \
	&& luarocks-${v} install \
		cluacov 0.1.0-1 \
	|| exit \
	; done
