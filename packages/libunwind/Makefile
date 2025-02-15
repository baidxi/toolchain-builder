PKG_NAME:=libunwind
PKG_VERSION:=1.8.1
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://github.com/libunwind/libunwind/archive/refs/tags/v$(PKG_VERSION).tar.gz


PKG_BUILD_DIR:=$(HOST_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=$(BUILD_SYSROOT) \
	$(if $(HOST), --host=$(HOST))	\
	--disable-shared	\
	--enable-static		\
	--enable-cxx-exceptions	\
	--enable-setjmp	\
	--with-gnu-ld

all:install
	true

download:
	[ -f $(DL_DIR)/$(PKG_FILE) ] || wget -O $(DL_DIR)/$(PKG_FILE) $(PKG_URL) || (rm -f $(DL_DIR)/$(PKG_FILE) && false)

extract: download
	[ -f $(PKG_SOURCE_DIR)/.extracted ] || ( \
		tar xf $(DL_DIR)/$(PKG_FILE) -C $(SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PKG_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PKG_SOURCE_DIR)/.extracted \
	)

configure:extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		cp -a $(PKG_SOURCE_DIR)/* $(PKG_BUILD_DIR)/; \
		(	\
		CFLAGS="$(HOST_CFLAGS)" \
		CXXFLAGS="$(HOST_CXXFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		M4="$(HOST_OUTPUT_PREFIX)/bin/m4" \
		ACLOCAL="$(HOST_OUTPUT_PREFIX)/bin/aclocal"	\
		AUTOM4TE="$(HOST_OUTPUT_PREFIX)/bin/autom4te"	\
		LIBTOOLIZE="$(HOST_OUTPUT_PREFIX)/bin/libtoolize"	\
		AUTOMAKE="$(HOST_OUTPUT_PREFIX)/bin/automake"	\
		$(HOST_OUTPUT_PREFIX)/bin/autoreconf --install -v --force && \
			./configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured \
		);	\
	)

build:configure
	[ -f $(PKG_BUILD_DIR)/.build ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) && \
		touch $(PKG_BUILD_DIR)/.build \
	)

install:build
	[ -f $(PKG_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) install && \
		touch $(PKG_BUILD_DIR)/.installed	\
	)
