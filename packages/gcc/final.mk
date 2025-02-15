PKG_CONFIGURE_ARGS += \
	--disable-bootstrap	\
	--enable-lto	\
	--enable-plugins	\
	--enable-largefile	\
	--enable-shared	\
	--enable-static	\
	--enable-c99	\
	--enable-checking=release	\
	--enable-libstdcxx-debug	\
	--enable-libstdcxx-time=yes	\
	--enable-languages=c,c++,lto	\
	--with-mpc=$(HOST_OUTPUT_PREFIX)	\
	--with-mpfr=$(HOST_OUTPUT_PREFIX)	\
	--with-gmp=$(HOST_OUTPUT_PREFIX)	\
	--with-isl=$(HOST_OUTPUT_PREFIX)	\
	--with-sysroot=$(SYSROOT_PREFIX)	\
	--with-zstd=$(HOST_OUTPUT_PREFIX)	\
	--with-native-system-header-dir=/include

ifeq ($(LIBC),newlib)
PKG_CONFIGURE_ARGS += \
	--with-newlib \
	--disable-libgomp \
	--disable-thread \
	--disable-tls \
	--disable-nls
else
PKG_CONFIGURE_ARGS += \
	--enable-libatomic \
	--enable-libssp \
	--enable-libgomp \
	--enable-threads=posix	\
	--enable-tls	\
	--enable-nls
endif

ifneq ($(LIBC),glibc)
PKG_CONFIGURE_ARGS += \
	--disable-libsanitizer
endif

ifeq ($(STAGE),toolchain)
configure: extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		ln -sf $(PKG_SOURCE_DIR);	\
		MAKEINFO=$(HOST_OUTPUT_PREFIX)/bin/makeinfo \
		AWK="$(HOST_OUTPUT_PREFIX)/bin/gawk"	\
		MSGFMT="$(HOST_OUTPUT_PREFIX)/bin/msgfmt"	\
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)"	\
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)"	\
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)"	\
		LIBS="-liconv"	\
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured	\
	)
else
configure: extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		ln -s $(PKG_SOURCE_DIR);	\
		enable_gnu_indirect_function=yes \
		default_gnu_indirect_function=yes \
		MAKEINFO="$(HOST_OUTPUT_PREFIX)/bin/makeinfo" 	\
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)" \
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)" \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(LIBS_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TARGET_CXXFLAGS) $(LIBS_CXXFLAGS) $(GCC_DEBUG_CFLAGS)" \
		LDFLAGS_FOR_TARGET="$(TARGET_LDFLAGS) $(LIBS_LDFLAGS)" \
		CC_FOR_TARGET="$(TOOLCHAIN_PREFIX)gcc" \
		CXX_FOR_TARGET="$(TOOLCHAIN_PREFIX)g++" \
		AR_FOR_TARGET="$(TOOLCHAIN_PREFIX)ar" \
		AS_FOR_TARGET="$(TOOLCHAIN_PREFIX)as" \
		LD_FOR_TARGET="$(TOOLCHAIN_PREFIX)ld"  \
		NM_FOR_TARGET="$(TOOLCHIAN_PREFIX)nm"	\
		READELF_FOR_TARGET="$(TOOLCHAIN_PREFIX)readelf"	\
		RANLIB_FOR_TARGET="$(TOOLCHAIN_PREFIX)ranlib" \
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) --with-build-sysroot="$(INSTALL_DIR)$(BUILD_PREFIX)/$(TARGET)/$(SYSROOT_NAME)"	 && \
		touch $(PKG_BUILD_DIR)/.configured \
	)
endif
