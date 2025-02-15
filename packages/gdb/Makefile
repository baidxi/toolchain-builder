PKG_NAME:=gdb
PKG_VERSION:=16.2
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://mirrors.aliyun.com/gnu/$(PKG_NAME)/$(PKG_FILE)


PKG_BUILD_DIR:=$(STAGE_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=$(BUILD_PREFIX) \
	--target=$(TARGET)	\
	$(if $(HOST), --host=$(HOST))	\
	--enable-nls	\
	--enable-lto	\
	--disable-werror	\
	--with-gmp=$(HOST_OUTPUT_PREFIX)	\
	--with-mpc=$(HOST_OUTPUT_PREFIX)	\
	--with-mpfr=$(HOST_OUTPUT_PREFIX)	\
	--with-isl=$(HOST_OUTPUT_PREFIX)	

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
		MAKEINFO="$(HOST_OUTPUT_PREFIX)/bin/makeinfo"	\
		YACC="$(HOST_OUTPUT_PREFIX)/bin/yacc"	\
		M4="$(HOST_OUTPUT_PREFIX)/bin/m4"	\
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)" \
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)" \
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured \
	)

build:configure
	[ -f $(PKG_BUILD_DIR)/.build ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) && \
		touch $(PKG_BUILD_DIR)/.build \
	)

install:build
	[ -f $(PKG_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) install-gdb DESTDIR=$(INSTALL_DIR) && \
		touch $(PKG_BUILD_DIR)/.installed	\
	)
