PKG_NAME:=glibc
PKG_VERSION:=2.41
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://mirrors.aliyun.com/gnu/$(PKG_NAME)/$(PKG_FILE)


PKG_BUILD_DIR:=$(STAGE_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=/	\
	--build=$(HOST)	\
	$(if $(HOST), --host=$(TARGET))	\
	--disable-profile	\
	--disable-werror	\
	--without-gd	\
	--without-cvs	\
	--enable-add-ons	\
	--with-headers=$(BUILD_SYSROOT)/include

ifeq ($(strip $(LIBC_USE_SOFT_FLOAT)),y)
PKG_CONFIGURE_ARGS += --without-fp
endif

ifeq ($(strip $(LIBC_DEBUG)),y)
GLIBC_DEBUG_FLAGS:=-g3 -ggdb3 -gdwarf-4
endif

LIBS_CFLAGS := -I$(HOST_OUTPUT_PREFIX)/include
LIBS_CXXFLAGS := $(LIBS_CFLAGS)
LIBS_LDFLAGS := -L$(HOST_OUTPUT_PREFIX)/lib

all:install
	true

download:
	[ -f $(DL_DIR)/$(PKG_FILE) ] || wget -O $(DL_DIR)/$(PKG_FILE) $(PKG_URL) || (rm -f $(DL_DIR)/$(PKG_FILE) && false)

extract: download
	[ -f $(PKG_SOURCE_DIR)/.extracted ] || ( \
		tar xf $(DL_DIR)/$(PKG_FILE) -C $(SOURCE_DIR) && \
		for f in $$(ls ./patches-$(PKG_VERSION)/*.patch ./patches-$(PKG_VERSION)/*.diff); do patch -d $(PKG_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PKG_SOURCE_DIR)/.extracted \
	)

configure:extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		ln -sf $(PKG_SOURCE_DIR);	\
		libc_cv_slibdir="/$(TARGET_LIB_DIR)" \
		use_ldconfig=no \
		libc_cv_ssp=no \
		libc_cv_ssp_strong=no \
		ac_cv_header_cpuid_h=yes \
		libc_cv_ld_gnu_indirect_function=yes \
		MAKEINFO="$(HOST_OUTPUT_PREFIX)/bin/makeinfo" \
		CC="$(TOOLCHAIN_PREFIX)gcc"	\
		CXX="$(TOOLCHAIN_PREFIX)g++"	\
		CFLAGS="$(TARGET_CFLAGS) $(GLIBC_DEBUG_FLAGS) $(LIBS_CFLAGS)"	\
		CXXFLAGS="$(TARGET_CXXFLAGS) $(GLIBC_DEBUG_FLAGS) $(LIBS_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(LIBS_LDFLAGS)" \
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured	\
	)

headers: configure
	[ -f $(PKG_BUILD_DIR)/.header ] || (	\
	$(MAKE) -C $(PKG_BUILD_DIR)	\
		install_root="$(LIBC_PRE_HEADER_DIR)"	\
		install-bootstrap-headers=yes \
		install-headers && \
		$(MAKE) -C $(PKG_BUILD_DIR) csu/subdir_lib && \
		(	\
			cd $(PKG_BUILD_DIR);	\
			cp csu/crt1.o csu/crti.o csu/crtn.o	$(BUILD_SYSROOT)/lib;	\
		) &&	\
		$(TOOLCHAIN_PREFIX)gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $(BUILD_SYSROOT)/lib/libc.so &&	\
		cp $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/include/gnu/stubs.h $(LIBC_PRE_HEADER_DIR)/include/gnu/ &&	\
		cp -a $(LIBC_PRE_HEADER_DIR)/include/* $(BUILD_SYSROOT)/include/	&&	\
		cp -a $(LIBC_PRE_HEADER_DIR)/include/* $(FINAL_SYSROOT_DIR)/include/ &&	\
	touch $(PKG_BUILD_DIR)/.header	\
	)

build:configure
	[ -f $(PKG_BUILD_DIR)/.build ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) && \
		touch $(PKG_BUILD_DIR)/.build \
	)

install:build
	[ -f $(PKG_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) install install-headers install_root=$(FINAL_SYSROOT_DIR) && \
		touch $(PKG_BUILD_DIR)/.installed	\
	)
	( \
		cd $(FINAL_OUTPUT_DIR);	\
		for f in libc.so libm.so ; do \
			sed -i 's,//lib64/,/lib64/,g;s,//lib/,/lib/,g' $(FINAL_OUTPUT_DIR)/$(TARGET)/sysroot/lib/$$f ; \
		done	\
	)
