PKG_CONFIGURE_ARGS += \
    --disable-lto \
    --disable-largefile \
    --disable-threads \
    --disable-tls \
    --disable-nls \
    --disable-shared \
    --disable-bootstrap \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libatomic \
    --disable-libssp \
    --disable-libsanitizer \
    --disable-libgcc \
	--disable-libmpx	\
    --enable-languages=c \
    --without-headers \
    --with-newlib

configure: extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		ln -s $(PKG_SOURCE_DIR);	\
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)"	\
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)" \
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured	\
	)