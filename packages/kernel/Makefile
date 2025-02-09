PKG_NAME:=linux
PKG_VERSION:=5.15.80
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://mirrors.aliyun.com/linux-kernel/v5.x/$(PKG_FILE)

PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

download:
	[ -f $(DL_DIR)/.$(PKG_FILE).download ] || (wget -O $(DL_DIR)/$(PKG_FILE) $(PKG_URL) && touch $(DL_DIR)/.$(PKG_FILE).download) || (rm -f $(DL_DIR)/$(PKG_FILE) && false)

extract:
	[ -f $(PKG_SOURCE_DIR)/.extracted ] || ( \
		tar xf $(DL_DIR)/$(PKG_FILE) -C $(SOURCE_DIR) && \
		for f in $$(ls ./patches-$(PKG_VERSION)/*.patch ./patches-$(PKG_VERSION)/*.diff); do patch -d $(PKG_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PKG_SOURCE_DIR)/.extracted \
	)

headers: extract
	mkdir -p $(LINUX_HEADER_DIR)
	$(MAKE) -C $(PKG_SOURCE_DIR) ARCH=$(ARCH) INSTALL_HDR_PATH=$(LINUX_HEADER_DIR) headers_install
	cp -a $(LINUX_HEADER_DIR)/include/* $(BUILD_SYSROOT)/include/
	cp -a $(LINUX_HEADER_DIR)/include/* $(FINAL_SYSROOT_DIR)/include