export TOP_DIR:=$(CURDIR)
export DL_DIR:=$(TOP_DIR)/dl
export OUTPUT_DIR:=$(TOP_DIR)/output
export BUILD_DIR:=$(TOP_DIR)/build_dir
export PKG_DIR:=$(TOP_DIR)/packages
export SOURCE_DIR:=$(BUILD_DIR)/source

export HOST_CFLAGS:=-ffunction-sections -fdata-sections -fno-ident
export HOST_CXXFLAGS:=$(HOST_CFLAGS)
export HOST_LDFLAGS:=-Wl,--gc-sections

export TARGET_CFLAGS:=$(HOST_CFLAGS)
export TARGET_CXXFLAGS:=$(HOST_CXXFLAGS)
export TARGET_LDFLAGS:=$(HOST_LDFLAGS)

export HOSTCC ?= gcc

export SYSROOT_NAME:=sysroot

ifneq ($(wildcard $(TOP_DIR)/.config),)

include $(TOP_DIR)/.config

export GCC_ARCH:=$(strip $(shell $(HOSTCC) --print-multiarch 2>/dev/null))

ifeq ($(BUILD),)
export BUILD:=$(strip $(shell $(TOP_DIR)/config.guess 2>/dev/null))
ifeq ($(BUILD),)
export BUILD:=$(GCC_ARCH)
endif
endif

ifeq ($(BUILD),$(TARGET))
NATIVE_BUILD:=y
ifneq ($(GCC_ARCH),$(TARGET))
PREFIX_USE_GCC_ARCH:=y
endif
else
ifeq ($(GCC_ARCH),$(TARGET))
NATIVE_BUILD:=y
endif
endif

ifeq ($(VARIANT),)
export VARIANT:=generic
endif

export NATIVE_BUILD PREFIX_USE_GCC_ARCH

all:dirs download target
	true
dirs:
	mkdir -p $(DL_DIR);
	mkdir -p $(SOURCE_DIR)
download:
	( \
		for pkg in $$(ls $(PKG_DIR)/); do \
		[ -f ${PKG_DIR}/$${pkg}/Makefile ] && make -C ${PKG_DIR}/$${pkg} download || true; \
		done;	\
	)

target: toolchain
ifeq ($(strip $(NO_TARGET)),)
	$(MAKE) -f $(PKG_DIR)/package.mk STAGE=target
else
	true
endif

toolchain:
ifeq ($(NATIVE_BUILD),)
	make -f $(PKG_DIR)/package.mk STAGE=toolchain
else
	true
endif

else
all:
	echo "Missing config file!"
	false
endif
