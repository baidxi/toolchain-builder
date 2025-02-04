
NAME=glibc
VERSION=2.14
SOURCE_FILE=$(NAME)-$(VERSION).tar.gz
#THREAD_EXTEND_FILE=$(NAME)-linuxthreads-$(VERSION).tar.gz
#EXTEND_URL=https://ftp.gnu.org/gnu/$(NAME)/$(THREAD_EXTEND_FILE)
URL=https://ftp.gnu.org/gnu/$(NAME)/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(SOURCEDIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(STAGE_BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix= \
	--host=$(TARGET) \
	--disable-profile \
	--disable-werror \
	--without-gd \
	--without-cvs \
	--enable-add-ons \
	--with-headers=$(BUILD_SYSROOT)/include/

ifeq ($(strip $(LIBC_USE_SOFT_FLOAT)),y)
CONFIGURE_ARGS += --without-fp
endif

ifeq ($(strip $(LIBC_DEBUG)),y)
GLIBC_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif


all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) --no-check-certificate || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -xf $(DLDIR)/$(SOURCE_FILE) -C $(SOURCEDIR) && \
		[ -d ./patches-$(VERSION) ] && ( \
			for f in $$(ls ./patches-$(VERSION)/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		); \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

configure: extract

	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		ln -sf $(PACKAGE_SOURCE_DIR); \
		use_ldconfig=no \
		libc_cv_forced_unwind=yes \
		libc_cv_c_cleanup=yes	\
		libc_cv_gnu99_inline=yes	\
		libc_cv_ssp=no \
		libc_cv_ssp_strong=no \
		ac_cv_header_cpuid_h=yes \
		libc_cv_ld_gnu_indirect_function=yes \
		MAKEINFO="$(HOST_OUTPUT_PREFIX)/bin/makeinfo" \
		libc_cv_slibdir="$(TARGET_LIB_DIR)"	\
		CC="$(TOOLCHAIN_PREFIX)gcc" \
		CXX="$(TOOLCHAIN_PREFIX)g++" \
		CFLAGS="$(TARGET_CFLAGS) $(GLIBC_DEBUG_CFLAGS) -D_LIBC_REENTRANT=1" \
		CXXFLAGS="$(TARGET_CXXFLAGS) $(GLIBC_DEBUG_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
			$(PACKAGE_SOURCE_DIR:$(SOURCEDIR)/%=%)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

headers: configure
	[ -f $(PACKAGE_BUILD_DIR)/.header_installed ] || ( \
	$(MAKE) -C $(PACKAGE_BUILD_DIR) 	\
		install_root="$(LIBC_PRE_HEADER_DIR)" \
		install-bootstrap-headers=yes \
		install-headers	&&	\
	cp -a $(LIBC_PRE_HEADER_DIR)/include/* $(BUILD_SYSROOT)/include/ && \
	cp -a $(LIBC_PRE_HEADER_DIR)/include/* $(FINAL_SYSROOT_DIR)/include/	&& \
	$(MAKE) -C $(PACKAGE_BUILD_DIR)	\
		csu/subdir_lib &&	\
	( \
		cd $(PACKAGE_BUILD_DIR); \
		cp csu/crt1.o csu/crti.o csu/crtn.o $(FINAL_SYSROOT_DIR)/usr/lib;	\
	) && \
	$(TOOLCHAIN_PREFIX)gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $(FINAL_SYSROOT_DIR)/usr/lib/libc.so && \
		touch $(PACKAGE_BUILD_DIR)/.headers_installed \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install install-headers install-others-nosubdir DESTDIR=$(FINAL_SYSROOT_DIR) prefix=$(FINAL_SYSROOT_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install install-headers install-others-nosubdir DESTDIR=$(FINAL_SYSROOT_DIR) prefix=$(FINAL_SYSROOT_DIR)

