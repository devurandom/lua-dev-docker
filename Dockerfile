FROM quay.io/devurandom/c-dev:debian9.6-1

# luarocks requires: curl, unzip
RUN apt-get -y update \
	&& apt-get -y install \
		curl \
		git \
		unzip \
	&& apt-get -y clean all

ENV LUAENV_SRC_VERSION=3ef7626fded7042a0363a67d71153868f7075b8f \
	LUAENV_LUABUILD_SRC_VERSION=8c7e2eaac4d3ba9d4d36d3c6e4ff1b29d32fdb63 \
	LUAENV_LUAROCKS_SRC_VERSION=daa2adad89208138e313bc50247cac0b042b1597

ENV LUA_VERSIONS="5.1.5 5.2.4 5.3.5 luajit-2.0.5 luajit-2.1.0-beta3"

ENV LUAROCKS_VERSION=2.4.1

ENV LUAENV_ROOT=/opt/luaenv \
	PATH=/opt/luaenv/bin:$PATH

RUN apt-get -y update \
	&& __PACKAGES="libreadline6-dev libncurses5-dev" \
	&& apt-get -y install ${__PACKAGES} \
	&& git clone https://github.com/cehoffman/luaenv.git ${LUAENV_ROOT} && cd ${LUAENV_ROOT} && git checkout ${LUAENV_SRC_VERSION} \
	&& git clone https://github.com/cehoffman/lua-build.git ${LUAENV_ROOT}/plugins/lua-build && cd ${LUAENV_ROOT}/plugins/lua-build && git checkout ${LUAENV_LUABUILD_SRC_VERSION} \
	&& git clone https://github.com/xpol/luaenv-luarocks.git ${LUAENV_ROOT}/plugins/luaenv-luarocks && cd ${LUAENV_ROOT}/plugins/luaenv-luarocks && git checkout ${LUAENV_LUAROCKS_SRC_VERSION} \
	&& eval "$(luaenv init -)" \
	&& for v in ${LUA_VERSIONS} ; do \
		echo "Installing Lua ${v}" ; \
		if ! luaenv install ${v} ; then \
			cat /tmp/lua-build.*.log ; \
			exit 1 ; \
		fi ; \
	done \
	&& rm -fr /tmp/lua-build.* \
	&& for v in ${LUA_VERSIONS} ; do \
		echo "Installing LuaRocks for Lua ${v}" ; \
		luaenv shell ${v} \
		&& luaenv luarocks ${LUAROCKS_VERSION} || exit ; \
	done \
	&& apt-get -y purge ${__PACKAGES} \
	&& apt-get -y autoremove \
	&& apt-get -y clean all

RUN eval "$(luaenv init -)" \
	&& for v in ${LUA_VERSIONS} ; do \
		echo "Installing rocks for Lua ${v}" ; \
		luaenv shell ${v} \
		&& luarocks install \
			compat53 0.3-1 \
		&& luarocks install \
			busted 2.0.rc12-1 \
		&& luarocks install \
			cluacov 0.1.0-1 \
		|| exit ; \
	done
