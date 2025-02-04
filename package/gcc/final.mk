
CONFIGURE_ARGS += \
	--disable-libgomp \
	--enable-lto \
	--enable-plugins \
	--enable-largefile \
	--enable-shared \
	--enable-c99 \
	--enable-nls \
	--disable-bootstrap \
	--enable-static \
	--enable-checking=release \
	--enable-libstdcxx-debug \
	--enable-libstdcxx-time=yes \
	--enable-languages=c,c++,lto \
	--with-native-system-header-dir=/include


ifeq ($(LIBC),newlib)
CONFIGURE_ARGS += \
	--with-newlib \
	--disable-libgomp \
	--disable-thread \
	--disable-tls
else
CONFIGURE_ARGS += \
	--enable-libatomic \
	--enable-libssp \
	--enable-threads=posix \
	--enable-tls	\
	--enable-libgomp 
endif

ifneq ($(LIBC),glibc)
CONFIGURE_ARGS += \
	--disable-libsanitizer
endif

ifeq ($(STAGE),target)
CONFIGURE_ARGS += \
	$(if $(HOST),--build=$(HOST))
endif

