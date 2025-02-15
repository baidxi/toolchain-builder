PKG_NAME:=zlib
PKG_VERSION:=1.2.13
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://github.com/madler/zlib/archive/refs/tags/v$(PKG_VERSION).tar.gz


PKG_BUILD_DIR:=$(HOST_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=$(HOST_OUTPUT_PREFIX)	\
	--static

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

configure: extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		ln -s $(PKG_SOURCE_DIR);	\
		CFLAGS="$(TARGET_CFLAGS)"	\
		LDFLAGS="$(TARGET_LDFLAGS)"	\
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PKG_BUILD_DIR)/.build ] || ( \
		$(MAKE) PREFIX=$(HOST)- LOC="$(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
			-C $(PKG_BUILD_DIR) && \
		touch $(PKG_BUILD_DIR)/.build \
	)

install:build
	[ -f $(PKG_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) install	&& \
		touch $(PKG_BUILD_DIR)/.installed	\
	)
