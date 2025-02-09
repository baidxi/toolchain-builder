export STAGE:=$(strip $(STAGE))

export TARGET_BUILD_DIR:=$(BUILD_DIR)/$(TARGET)/$(VARIANT)
export TARGET_OUTPUT_DIR:=$(OUTPUT_DIR)/$(TARGET)/$(VARIANT)

export STAGE_BUILD_DIR:=$(TARGET_BUILD_DIR)/$(STAGE)
export LINUX_HEADER_DIR:=$(TARGET_BUILD_DIR)/linux-headers

export LIBC_PRE_HEADER_DIR:=$(STAGE_BUILD_DIR)/libc-dev
export BUILD_SYSROOT:=$(STAGE_BUILD_DIR)/$(SYSROOT_NAME)

ifneq ($(filter uclibc-ng glibc,$(LIBC)),)
export LIBC_HEADERS:=$(LIBC)-headers
endif

ifeq ($(STAGE),toolchain)
export HOST:=
export HOST_BUILD_DIR:=$(BUILD_DIR)/$(BUILD)
export BUILD_PREFIX:=$(TARGET_OUTPUT_DIR)/$(STAGE)/usr
export INSTALL_DIR:=/
export FINAL_OUTPUT_DIR:=$(BUILD_PREFIX)
else
ifeq ($(STAGE),target)
export HOST_BUILD_DIR:=$(BUILD_DIR)/$(HOST)
ifneq ($(TARGET_PREFIX),)
export BUILD_PREFIX:=$(TARGET_PREFIX)
else
export BUILD_PREFIX:=/opt/toolchain/$(TARGET)
endif # $(TARGET_PREFIX)
export INSTALL_DIR:=$(TARGET_OUTPUT_DIR)/$(STAGE)
export FINAL_OUTPUT_DIR:=$(INSTALL_DIR)$(BUILD_PREFIX)
else
$(error Invalid STAGE)
endif
endif

export SYSROOT_PREFIX:=$(BUILD_PREFIX)/$(TARGET)/$(SYSROOT_NAME)
export FINAL_SYSROOT_DIR:=$(FINAL_OUTPUT_DIR)/$(TARGET)/$(SYSROOT_NAME)

export HOST_OUTPUT_PREFIX:=$(HOST_BUILD_DIR)/install

ifneq ($(filter-out aarch64 aarch64_eb x86_64 mipse64 mips64el,$(TARGET)),)
export TARGET_LIB_DIR:=/lib64
else
export TARGET_LIB_DIR:=/lib
endif

export TOOLCHAIN_BIN_DIR:=$(TARGET_OUTPUT_DIR)/toolchain/usr/bin

ifeq ($(NATIVE_BUILD),)
export TOOLCHAIN_PREFIX:=$(TOOLCHAIN_BIN_DIR)/$(TARGET)-
else
ifeq ($(PREFIX_USE_GCC_ARCH),y)
export TOOLCHAIN_PREFIX:=$(GCC_ARCH)-
else
export TOOLCHAIN_PREFIX:=$(TARGET)-
endif
endif

all:gcc-final gdb

dir-prep:
	mkdir -p $(FINAL_SYSROOT_DIR)/lib
	mkdir -p $(FINAL_SYSROOT_DIR)/include
	ln -sf $(SYSROOT_NAME)/include $(FINAL_OUTPUT_DIR)/$(TARGET)/include
	mkdir -p $(BUILD_SYSROOT)/lib
	mkdir -p $(BUILD_SYSROOT)/include

gmp:
	$(MAKE) -C $(PKG_DIR)/gmp

mpfr:
	$(MAKE) -C $(PKG_DIR)/mpfr

mpc:
	$(MAKE) -C $(PKG_DIR)/mpc

libiconv:
	$(MAKE) -C $(PKG_DIR)/libiconv

isl:
	$(MAKE) -C $(PKG_DIR)/isl

zlib:
	$(MAKE) -C $(PKG_DIR)/zlib

binutils: gmp mpfr mpc isl zlib libiconv
	$(MAKE) -C $(PKG_DIR)/binutils

ifneq ($(LIBC),none)

linux-headers: dir-prep
	$(MAKE) -C $(PKG_DIR)/kernel headers

ifeq ($(STAGE),toolchain)

$(LIBC): linux-headers gcc-initial
	$(MAKE) -C $(PKG_DIR)/$(LIBC)

ifneq ($(LIBC_HEADERS),)
gcc-minimum: gmp mpfr mpc isl zlib libiconv binutils
	$(MAKE) -C $(PKG_DIR)/gcc GCC_STAGE=minimum

$(LIBC_HEADERS): gcc-minimum dir-prep
	$(MAKE) -C $(PKG_DIR)/$(LIBC) headers
endif # $(LIBC_HEADERS) neq " "

gcc-initial: gmp mpfr mpc isl zlib libiconv binutils $(LIBC_HEADERS)
	$(MAKE) -C $(PKG_DIR)/gcc GCC_STAGE=initial

else # $(STAGE) eq toolchain
$(LIBC): linux-headers
	$(MAKE) -C $(PKG_DIR)/$(LIBC)
endif
gcc-final: binutils $(LIBC)
	$(MAKE) -C $(PKG_DIR)/gcc GCC_STAGE=final
else	# $(LIBC) neq none
gcc-final: gmp mpfr mpc isl zlib libiconv binutils dir-prep
	$(MAKE) -C $(PKG_DIR)/gcc GCC_STAGE=final
endif	# $(LIBC) neq none

gdb:
	true