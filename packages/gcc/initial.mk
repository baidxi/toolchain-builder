PKG_CONFIGURE_ARGS += \
	--disable-lto	\
	--disable-largefile	\
	--disable-nls	\
	--disable-shared	\
	--disable-bootstrap	\
	--disable-libgomp	\
	--disable-libquadmath	\
	--disable-libatomic	\
	--disable-libssp	\
	--disable-libsanitizer	\
	--disable-libmpx	\
	--enable-languages=c	\
	--enable-libgcc	\
	--with-newlib

ifneq ($(LIBC_HEADERS),)
PKG_CONFIGURE_ARGS += \
	--enable-threads	\
	--enable-tls	\
	--with-build-sysroot=$(BUILD_SYSROOT)	\
	--with-native-system-header-dir=/include
else
PKG_CONFIGURE_ARGS += \
	--disable-threads	\
	--disable-tls	\
	--without-headers 
endif

configure: extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || (	\
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		ln -sf $(PKG_SOURCE_DIR);	\
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)"	\
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)"	\
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)"	\
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured	\
	)