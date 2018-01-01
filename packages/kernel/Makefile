PKG_NAME:=linux
PKG_VERSION:=3.0.1
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://mirrors.aliyun.com/linux-kernel/v3.x/$(PKG_FILE)

PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

download:
	[ -f $(DL_DIR)/$(PKG_FILE) ] || $(HOST_OUTPUT_PREFIX)/bin/wget -O $(DL_DIR)/$(PKG_FILE) $(PKG_URL) --no-check-certificate || (rm -f $(DL_DIR)/$(PKG_FILE) && false)

extract: download
	[ -f $(PKG_SOURCE_DIR)/.extracted ] || ( \
		$(HOST_OUTPUT_PREFIX)/bin/tar xf $(DL_DIR)/$(PKG_FILE) -C $(SOURCE_DIR) && \
		for f in $$(ls ./patches-$(PKG_VERSION)/*.patch ./patches-$(PKG_VERSION)/*.diff); do patch -d $(PKG_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PKG_SOURCE_DIR)/.extracted \
	)

headers: extract
	mkdir -p $(LINUX_HEADER_DIR)
	$(MAKE) -C $(PKG_SOURCE_DIR) ARCH=$(ARCH) INSTALL_HDR_PATH=$(LINUX_HEADER_DIR) headers_install
	cp -a $(LINUX_HEADER_DIR)/include/* $(BUILD_SYSROOT)/include/
	cp -a $(LINUX_HEADER_DIR)/include/* $(FINAL_SYSROOT_DIR)/include
