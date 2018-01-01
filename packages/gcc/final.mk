PKG_CONFIGURE_ARGS += \
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
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)" \
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)" \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(LIBS_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TARGET_CXXFLAGS) $(LIBS_CXXFLAGS) $(GCC_DEBUG_CFLAGS)" \
		LDFLAGS_FOR_TARGET="$(TARGET_LDFLAGS) $(LIBS_LDFLAGS)" \
		MAKEINFO="$(HOST_OUTPUT_PREFIX)/bin/makeinfo" 	\
		CC_FOR_TARGET="$(TOOLCHAIN_PREFIX)gcc" \
		CXX_FOR_TARGET="$(TOOLCHAIN_PREFIX)g++" \
		AR_FOR_TARGET="$(TOOLCHAIN_PREFIX)ar" \
		AS_FOR_TARGET="$(TOOLCHAIN_PREFIX)as" \
		LD_FOR_TARGET="$(TOOLCHAIN_PREFIX)ld"  \
		READELF_FOR_TARGET="$(TOOLCHAIN_PREFIX)readelf"	\
		RANLIB_FOR_TARGET="$(TOOLCHAIN_PREFIX)ranlib" \
		BUILD_TIME_INSTALL_DIR="$(INSTALL_DIR)" \
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) --with-build-sysroot=$(FINAL_SYSROOT_DIR) && \
		touch $(PKG_BUILD_DIR)/.configured \
	)
endif
