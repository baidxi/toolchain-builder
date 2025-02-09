PKG_CONFIGURE_ARGS += \
	--disable-nls	\
	--enable-lto	\
	--enable-plugins	\
	--enable-largefile	\
	--enable-shared	\
	--enable-static	\
	--enable-nls	\
	--enable-c99	\
	--enable-checking=release	\
	--enable-libstdcxx-debug	\
	--enable-libstdcxx-time=yes	\
	--enable-languages=c,c++,lto	\
	--with-sysroot=$(SYSROOT_PREFIX)	\
	--with-native-system-header-dir=/include

ifeq ($(LIBC),newlib)
PKG_CONFIGURE_ARGS += \
	--with-newlib \
	--disable-libgomp \
	--disable-thread \
	--disable-tls 
else
PKG_CONFIGURE_ARGS += \
	--enable-libatomic \
	--enable-libssp \
	--enable-libgomp \
	--enable-threads=posix	\
	--enable-tls
endif

ifneq ($(LIBC),glibc)
PKG_CONFIGURE_ARGS += \
	--disable-libsanitizer
endif

configure: extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		ln -sf $(PKG_SOURCE_DIR);	\
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)"	\
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)"	\
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)"	\
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured	\
	)