PKG_NAME:=binutils
PKG_VERSION:=2.32
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://ftp.gnu.org/gnu/$(PKG_NAME)/$(PKG_FILE)


PKG_BUILD_DIR:=$(HOST_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=$(BUILD_PREFIX) \
	--target=$(TARGET)	\
	$(if $(HOST), --host=$(HOST))	\
	--disable-shared	\
	--enable-static	\
	--enable-nls	\
	--enable-ld	\
	--enable-lto	\
	--enable-gold	\
	--with-sysroot=$(SYSROOT_PREFIX)

all:install
	true

download:
	[ -f $(DL_DIR)/.$(PKG_FILE).download ] || (wget -O $(DL_DIR)/$(PKG_FILE) $(PKG_URL) && touch $(DL_DIR)/.$(PKG_FILE).download) || (rm -f $(DL_DIR)/$(PKG_FILE) && false)

extract:
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
		$(PKG_SOURCE_DIR:$(SOURCE_DIR)/%=%)/configure $(PKG_CONFIGURE_ARGS) \
			CFLAGS="$(HOST_CFLAGS)" \
			CXXFLAGS="$(HOST_CXXFLAGS)" \
			LDFLAGS="$(HOST_LDFLAGS)" && \
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