PKG_NAME:=bison
PKG_VERSION:=3.8.2
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://mirrors.aliyun.com/gnu/$(PKG_NAME)/$(PKG_FILE)


PKG_BUILD_DIR:=$(HOST_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=$(HOST_OUTPUT_PREFIX) \
	$(if $(BUILD), --build=$(BUILD))	\
	$(if $(HOST), --host=$(HOST))	\
	--disable-nls	\
	--with-libiconv-prefix=$(HOST_OUTPUT_PREFIX)	\
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
		ln -sf $(PKG_SOURCE_DIR);	\
		M4="$(HOST_OUTPUT_PREFIX)/bin/m4"	\
		CFLAGS="$(HOST_CFLAGS) -L$(HOST_OUTPUT_PREFIX)/lib -I$(HOST_OUTPUT_PREFIX)/include" \
		CXXFLAGS="$(HOST_CXXFLAGS) -L$(HOST_OUTPUT_PREFIX)/lib" \
		LDFLAGS="$(HOST_LDFLAGS) -lncurses " \
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
		$(MAKE) -C $(PKG_BUILD_DIR) install && \
		touch $(PKG_BUILD_DIR)/.installed	\
	)
