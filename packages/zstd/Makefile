PKG_NAME:=zstd
PKG_VERSION:=1.5.6
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://github.com/facebook/zstd/archive/refs/tags/v$(PKG_VERSION).tar.gz


PKG_BUILD_DIR:=$(HOST_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=$(HOST_OUTPUT_PREFIX) \
	$(if $(HOST), --host=$(HOST))	\
	--disable-shared	\
	--enable-static	\
	--enable-largefile	\
	--disable-install-examples	\
	--with-curses=$(HOST_OUTPUT_PREFIX)	\
	--with-mpfr=$(HOST_OUTPUT_PREFIX)	

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
		ln -sf $(PKG_SOURCE_DIR);	\
		cmake -DCMAKE_INSTALL_PREFIX=$(HOST_OUTPUT_PREFIX) -DZSTD_BUILD_STATIC=YES -DZSTD_BUILD_SHARED=NO ./$(PKG_NAME)-$(PKG_VERSION)/build/cmake/ && \
		touch $(PKG_BUILD_DIR)/.configured \
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
