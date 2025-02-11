PKG_NAME:=gcc
PKG_VERSION:=7.5.0
PKG_FILE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_URL:=https://ftp.gnu.org/gnu/gcc/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_FILE)


PKG_BUILD_DIR_COMMON:=$(HOST_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIGURE_ARGS:=	\
	--prefix=$(BUILD_PREFIX) \
	--target=$(TARGET)	\
	$(if $(HOST), --host=$(HOST))	\
	--disable-multilib	\
	--disable-sjlj-exceptions	\
	--enable-version-specific-runtime-libs	\
	--enable-fully-dynamic-string	\
	--enable-gnu-unique-object	\
	--enable-clocale=gnu	\
	--with-gnu-ld	\
	--with-gnu-as	\
	--with-libiconv-prefix=$(HOST_OUTPUT_PREFIX)	\
	--with-system-zlib \
	$(TARGET_GCC_FLAGS)

LIBS_CFLAGS := -I$(HOST_OUTPUT_PREFIX)/include
LIBS_CXXFLAGS := $(LIBS_CFLAGS)
LIBS_LDFLAGS := -L$(HOST_OUTPUT_PREFIX)/lib

ifneq ($(ARCH),x86)
PKG_CONFIGURE_ARGS += --disable-decimal-float
endif

ifeq ($(strip $(LIBC_DEBUG)),y)
GCC_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif

ifneq ($(LIBC),none)
GCC_STAGE_MK=$(GCC_STAGE)
else
GCC_STAGE_MK=$(GCC_STAGE)-none
endif

PKG_BUILD_DIR:=$(PKG_BUILD_DIR_COMMON)-$(GCC_STAGE)

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

ifneq ($(GCC_STAGE_MK),)
include $(GCC_STAGE_MK).mk
endif

build: configure
	[ -f $(PKG_BUILD_DIR)/.build ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) && \
		touch $(PKG_BUILD_DIR)/.build \
	)

install: build
	[ -f $(PKG_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PKG_BUILD_DIR) install DESTDIR=$(INSTALL_DIR) && \
		([ -d $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET)/lib ] && cp -a $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET)/lib64/* $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET)/$(VERSION)/ || true ) && \
		([ -d $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET)/lib64 ] && cp -a $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET)/lib64/* $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET)/$(VERSION)/ || true ) && \
		sed -i 's/$(subst /,\/,$(INSTALL_DIR))//g' $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET)/$(VERSION)/install-tools/mkheaders.conf && \
		find $(FINAL_OUTPUT_DIR) -name '*.la' | xargs sed -i -e "s/'$(subst /,\/,$(TARGET_OUTPUT_DIR)/toolchain/usr/lib/gcc/$(TARGET)/$(VERSION))'\/libstdc++.la//g"; \
		find $(FINAL_OUTPUT_DIR) -name '*.la' | xargs sed -i -e "s/'$(subst /,\/,$(BUILD_PREFIX)/lib/gcc/$(TARGET)/$(VERSION))'\/libstdc++.la/-lstdc++/g"; \
		if [ x"$(INSTALL_DIR)" != x"/" ]; then \
			find $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET)/$(VERSION)/include-fixed -name '*.h' | xargs sed -i 's/$(subst /,\/,$(INSTALL_DIR))//g'; \
		fi;	\
		touch $(PKG_BUILD_DIR)/.installed	\
	)