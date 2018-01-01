PKG_NAME:=binutils
PKG_VERSION:=2.24
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://mirrors.aliyun.com/gnu/$(PKG_NAME)/$(PKG_FILE)


PKG_BUILD_DIR:=$(STAGE_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=$(BUILD_PREFIX) \
	--target=$(TARGET)	\
	$(if $(HOST), --host=$(HOST))	\
	--disable-werror	\
	--disable-gold	\
	--enable-ld	\
	--enable-lto	\
	--with-sysroot=$(SYSROOT_PREFIX)

ifeq ($(STAGE),target)
PKG_CONFIGURE_ARGS += 	--enable-nls
else
PKG_CONFIGURE_ARGS +=	--disable-nls
endif

all:install
	true

download:
	[ -f $(DL_DIR)/$(PKG_FILE) ] || $(HOST_OUTPUT_PREFIX)/bin/wget -O $(DL_DIR)/$(PKG_FILE) $(PKG_URL) --no-check-cert  || (rm -f $(DL_DIR)/$(PKG_FILE) && false)

extract: download
	[ -f $(PKG_SOURCE_DIR)/.extracted ] || ( \
		$(HOST_OUTPUT_PREFIX)/bin/tar xf $(DL_DIR)/$(PKG_FILE) -C $(SOURCE_DIR) && \
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
		CFLAGS="$(HOST_CFLAGS)" \
		CXXFLAGS="$(HOST_CXXFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS)" \
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
		$(MAKE) -C $(PKG_BUILD_DIR) install DESTDIR=$(INSTALL_DIR) && \
		touch $(PKG_BUILD_DIR)/.installed	\
	)
