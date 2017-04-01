FROM quay.io/devurandom/c-dev:debian8.7-2

# luarocks requires: curl, unzip
RUN apt-get -y update \
	&& apt-get -y install \
		curl \
		git \
		unzip \
	&& apt-get -y clean all

ENV LUAENV_SRC_VERSION=afcd23a05c14fa015f6445454f0a5cccc7cebbb8 \
	LUAENV_BUILD_SRC_VERSION=82f7913eea0d341c82cfc7fe130ac7641f904f14 \
	LUAENV_LUAROCKS_SRC_VERSION=3cc71dde392efb5e0f4b7881a2877db1be6949d8

ENV LUA_VERSIONS="5.1.5 5.2.4 5.3.3 luajit-2.0.4 luajit-2.1.0-beta2"

ENV LUAROCKS_VERSION=2.4.1

ENV LUAENV_ROOT=/opt/luaenv \
	PATH=/opt/luaenv/bin:$PATH

RUN apt-get -y update \
	&& __PACKAGES="libreadline6-dev libncurses5-dev" \
	&& apt-get -y install ${__PACKAGES} \
	&& git clone https://github.com/cehoffman/luaenv.git ${LUAENV_ROOT} && cd ${LUAENV_ROOT} && git checkout ${LUAENV_SRC_VERSION} \
	&& git clone https://github.com/cehoffman/lua-build.git ${LUAENV_ROOT}/plugins/lua-build && cd ${LUAENV_ROOT}/plugins/lua-build && git checkout ${LUAENV_BUILD_SRC_VERSION} \
	&& sed 's/luajit-2/LuaJIT-2/' -i share/lua-build/luajit-2.1.0-beta2 \
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

RUN for v in ${LUA_VERSIONS} ; do \
	echo "Installing rocks for Lua ${v}" ; \
	eval "$(luaenv init -)" \
	&& luaenv shell ${v} \
	&& luarocks install \
		compat53 0.3-1 \
	&& luarocks install \
		busted 2.0.rc12-1 \
	&& luarocks install \
		cluacov 0.1.0-1 \
	&& luarocks install \
		luacov-coveralls 0.2.1-1 \
	|| exit \
	; done
