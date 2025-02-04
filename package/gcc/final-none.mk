
CONFIGURE_ARGS += \
	--disable-libssp \
	--disable-libstdc++-v3 \
	--enable-lto \
	--enable-plugins \
	--enable-largefile \
	--disable-threads \
	--disable-shared \
	--enable-static \
	--enable-languages=c,c++,lto \
	--with-newlib \
	--with-sysroot=$(SYSROOT_PREFIX) \
	--with-native-system-header-dir=/include



