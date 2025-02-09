PKG_NAME:=zlib
PKG_VERSION:=1.3.1
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://zlib.net/$(PKG_FILE)


PKG_BUILD_DIR:=$(HOST_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--static

all:install
	true

download:
	[ -f $(DL_DIR)/.$(PKG_FILE).download ] || (wget -O $(DL_DIR)/$(PKG_FILE) $(PKG_URL) && touch $(DL_DIR)/.$(PKG_FILE).download) || (rm -f $(DL_DIR)/$(PKG_FILE) && false)


extract:
	[ -f $(PKG_SOURCE_DIR)/.extracted ] || ( \
		tar xf $(DL_DIR)/$(PKG_FILE) -C $(SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PKG_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PKG_SOURCE_DIR)/.extracted \
	)

ifeq ($(STAGE),target)
configure: extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cp -a $(PKG_SOURCE_DIR)/* $(PKG_BUILD_DIR)/ && \
		touch $(PKG_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PKG_BUILD_DIR)/.build ] || ( \
			$(MAKE) PREFIX=$(HOST)- LOC="$(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
			-C $(PKG_BUILD_DIR) -f win32/Makefile.gcc libz.a && \
		touch $(PKG_BUILD_DIR)/.build \
	)
else
configure: extract
	[ -f $(PKG_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PKG_BUILD_DIR);	\
		cd $(PKG_BUILD_DIR);	\
		ln -sf $(PKG_SOURCE_DIR);	\
		CFLAGS="$(TARGET_CFLAGS)"	\
		LDFLAGS="$(TARGET_LDFLAGS)"	\
		$(CONFIGURE_ENVS)	\
			$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) && \
		touch $(PKG_BUILD_DIR)/.configured	\
	)
build: configure
	[ -f $(PKG_BUILD_DIR)/.build ] || (	\
		$(MAKE) -C $(PKG_BUILD_DIR) && \
		touch $(PKG_BUILD_DIR)/.build \
	)
endif

install:build
	[ -f $(PKG_BUILD_DIR)/.installed ] || ( \
		mkdir -p $(HOST_OUTPUT_PREFIX)/lib $(HOST_OUTPUT_PREFIX)/include && \
		cp $(PKG_BUILD_DIR)/libz.a $(HOST_OUTPUT_PREFIX)/lib && \
		cp $(PKG_BUILD_DIR)/zconf.h $(HOST_OUTPUT_PREFIX)/include && \
		cp $(PKG_SOURCE_DIR)/zlib.h $(HOST_OUTPUT_PREFIX)/include && \
		touch $(PKG_BUILD_DIR)/.installed	\
	)