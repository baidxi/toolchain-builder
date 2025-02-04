
NAME=binutils
VERSION=2.24
SOURCE_FILE=$(NAME)-$(VERSION).tar.bz2
URL=https://ftp.gnu.org/gnu/$(NAME)/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(SOURCEDIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(STAGE_BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=$(BUILD_PREFIX) \
	--target=$(TARGET) \
	$(if $(HOST),--host=$(HOST)) \
	--enable-static \
	--disable-werror \
	--disable-shared \
	--disable-nls \
	--enable-relro \
	--enable-ld \
	--enable-lto \
	--disable-man \
	--with-sysroot=$(SYSROOT_PREFIX)

LIBS_CFLAGS := -I$(HOST_OUTPUT_PREFIX)/include
LIBS_CXXFLAGS := $(LIBS_CFLAGS)
LIBS_LDFLAGS := -L$(HOST_OUTPUT_PREFIX)/lib

ifeq ($(STAGE),target)
CONFIGURE_ARGS += \
	$(if $(HOST),--build=$(HOST))
endif

all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) --no-check-certificate || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -xf $(DLDIR)/$(SOURCE_FILE) -C $(SOURCEDIR) && \
		[ -d ./patches-$(VERSION) ] && (	\
			for f in $$(ls ./patches-$(VERSION)/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		); \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		ln -sf $(PACKAGE_SOURCE_DIR); \
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)" \
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)" \
		MAKEINFO="$(HOST_OUTPUT_PREFIX)/bin/makeinfo" \
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)" \
			$(PACKAGE_SOURCE_DIR:$(SOURCEDIR)/%=%)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(INSTALL_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(INSTALL_DIR)

