#############################################################################
#    (c)2010-2014 Broadcom Corporation
#
# This program is the proprietary software of Broadcom Corporation and/or its licensors,
# and may only be used, duplicated, modified or distributed pursuant to the terms and
# conditions of a separate, written license agreement executed between you and Broadcom
# (an "Authorized License").  Except as set forth in an Authorized License, Broadcom grants
# no license (express or implied), right to use, or waiver of any kind with respect to the
# Software, and Broadcom expressly reserves all rights in and to the Software and all
# intellectual property rights therein.  IF YOU HAVE NO AUTHORIZED LICENSE, THEN YOU
# HAVE NO RIGHT TO USE THIS SOFTWARE IN ANY WAY, AND SHOULD IMMEDIATELY
# NOTIFY BROADCOM AND DISCONTINUE ALL USE OF THE SOFTWARE.
#
# Except as expressly set forth in the Authorized License,
#
# 1.     This program, including its structure, sequence and organization, constitutes the valuable trade
# secrets of Broadcom, and you shall use all reasonable efforts to protect the confidentiality thereof,
# and to use this information only in connection with your use of Broadcom integrated circuit products.
#
# 2.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE SOFTWARE IS PROVIDED "AS IS"
# AND WITH ALL FAULTS AND BROADCOM MAKES NO PROMISES, REPRESENTATIONS OR
# WARRANTIES, EITHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE, WITH RESPECT TO
# THE SOFTWARE.  BROADCOM SPECIFICALLY DISCLAIMS ANY AND ALL IMPLIED WARRANTIES
# OF TITLE, MERCHANTABILITY, NONINFRINGEMENT, FITNESS FOR A PARTICULAR PURPOSE,
# LACK OF VIRUSES, ACCURACY OR COMPLETENESS, QUIET ENJOYMENT, QUIET POSSESSION
# OR CORRESPONDENCE TO DESCRIPTION. YOU ASSUME THE ENTIRE RISK ARISING OUT OF
# USE OR PERFORMANCE OF THE SOFTWARE.
#
# 3.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL BROADCOM OR ITS
# LICENSORS BE LIABLE FOR (i) CONSEQUENTIAL, INCIDENTAL, SPECIAL, INDIRECT, OR
# EXEMPLARY DAMAGES WHATSOEVER ARISING OUT OF OR IN ANY WAY RELATING TO YOUR
# USE OF OR INABILITY TO USE THE SOFTWARE EVEN IF BROADCOM HAS BEEN ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGES; OR (ii) ANY AMOUNT IN EXCESS OF THE AMOUNT
# ACTUALLY PAID FOR THE SOFTWARE ITSELF OR U.S. $1, WHICHEVER IS GREATER. THESE
# LIMITATIONS SHALL APPLY NOTWITHSTANDING ANY FAILURE OF ESSENTIAL PURPOSE OF
# ANY LIMITED REMEDY.
#
#############################################################################

SHELL := /bin/bash

export SHELL

include device/broadcom/avko/refsw_defs.mk
include device/broadcom/avko/refsw_targets.mk

export MULTI_BUILD=y
ifneq ($(DISABLE_REFSW_PARALLELISM),)
MAKE_OPTIONS := -j1
endif

BOLT_DIR := ${BRCMSTB_ANDROID_VENDOR_PATH}/bolt
ANDROID_BSU_DIR := ${BRCMSTB_ANDROID_VENDOR_PATH}/bolt/android

ifeq ($(B_REFSW_DEBUG), n)
    BUILD_TYPE ?= release
    SEC_LIB_MODE ?= retail
else
    BUILD_TYPE ?= debug
    SEC_LIB_MODE ?= debug
endif

ifeq ($(BCHP_VER_LOWER),)
BCHP_VER_LOWER := $(shell echo ${BCHP_VER} | tr [:upper:] [:lower:])
endif

ifeq ($(BOLT_IMG_TO_USE_OVERRIDE),)
BOLT_IMG_TO_USE_OVERRIDE := bolt-bb.bin
endif

# Include Nexus platform application Makefile include
# platform_app.inc modifies the PWD variable used by android.  Save it and restore afterward.
PWD_BEFORE_PLATFORM_APP := $(PWD)
include ${NEXUS_TOP}/platforms/$(PLATFORM)/build/platform_app.inc
PWD := $(PWD_BEFORE_PLATFORM_APP)

# filter out flags clashing with Android build system
FILTER_OUT_NEXUS_CFLAGS := -march=armv7-a -Wstrict-prototypes
NEXUS_CFLAGS := $(filter-out $(FILTER_OUT_NEXUS_CFLAGS), $(NEXUS_CFLAGS))

BRCMSTB_MODEL_NAME := bcm$(BCHP_CHIP)_$(BCHP_VER_LOWER)_$(MODEL_NAME)_$(HARDWARE_REV)
export BRCMSTB_MODEL_NAME

NEXUS_DEPS := \
	${PRODUCT_OUT}/obj/lib/libcutils.so \
	${PRODUCT_OUT}/obj/lib/crtbegin_dynamic.o \
	${PRODUCT_OUT}/obj/lib/crtend_android.o \
	mkbootimg

NEXUS_APP_CFLAGS := $(addprefix -I,$(NEXUS_APP_INCLUDE_PATHS))
NEXUS_APP_CFLAGS += $(addprefix -D,$(NEXUS_APP_DEFINES))
NEXUS_APP_CFLAGS += -DBSTD_CPU_ENDIAN=BSTD_ENDIAN_LITTLE
export NEXUS_APP_CFLAGS

.PHONY: setup_nexus_toolchains
setup_nexus_toolchains:
	@if [ -d "${B_REFSW_TOOLCHAINS_INSTALL}" ]; then \
		rm -rf ${B_REFSW_TOOLCHAINS_INSTALL}; \
	fi
	@mkdir -p ${B_REFSW_TOOLCHAINS_INSTALL};
	@if [ "${B_REFSW_USES_CLANG}" == "y" ] ; then \
		ln -s ${P_REFSW_CC_CLANG}/clang ${B_REFSW_TOOLCHAINS_INSTALL}gcc; \
		ln -s ${P_REFSW_CC_CLANG}/clang++ ${B_REFSW_TOOLCHAINS_INSTALL}c++; \
		ln -s ${P_REFSW_CC_CLANG}/clang++ ${B_REFSW_TOOLCHAINS_INSTALL}g++; \
	else \
		ln -s ${P_REFSW_CC}gcc ${B_REFSW_TOOLCHAINS_INSTALL}gcc; \
		ln -s ${P_REFSW_CC}c++ ${B_REFSW_TOOLCHAINS_INSTALL}c++; \
		ln -s ${P_REFSW_CC}c++ ${B_REFSW_TOOLCHAINS_INSTALL}g++; \
	fi
	@ln -s ${P_REFSW_CC}ar ${B_REFSW_TOOLCHAINS_INSTALL}ar;

export NXCLIENT_SOCKET_INTF := ${ANDROID}/${BCM_VENDOR_STB_ROOT}/bcm_platform/nxif/nxsocket/nxclient_android_socket.c
export NEXUS_PLATFORM_PROXY_INTF := ${ANDROID}/${BCM_VENDOR_STB_ROOT}/bcm_platform/nxif/nxproxyif/nexus_platform_proxy_intf.c

.PHONY: nexus_build
nexus_build: setup_nexus_toolchains clean_recovery_ramdisk build_kernel $(NEXUS_DEPS) build_bootloaderimg
	@echo "'$@' started"
	@if [ ! -d "${NEXUS_BIN_DIR}" ]; then \
		mkdir -p ${NEXUS_BIN_DIR}; \
	fi
	@if [ ! -d "${B_REFSW_OBJ_ROOT}/k_drivers/" ]; then \
		mkdir -p ${B_REFSW_OBJ_ROOT}/k_drivers/; \
	fi
	$(MAKE) $(MAKE_OPTIONS) -C $(NEXUS_TOP)/nxclient/server
	$(MAKE) $(MAKE_OPTIONS) -C $(NEXUS_TOP)/nxclient/build
	cp -faR $(BRCMSTB_ANDROID_DRIVER_PATH)/droid_pm ${B_REFSW_OBJ_ROOT}/k_drivers/ && \
	$(MAKE) -C ${B_REFSW_OBJ_ROOT}/k_drivers/droid_pm INSTALL_DIR=$(NEXUS_BIN_DIR) install
	cp -faR $(BRCMSTB_ANDROID_DRIVER_PATH)/fbdev ${B_REFSW_OBJ_ROOT}/k_drivers/ && \
	$(MAKE) -C ${B_REFSW_OBJ_ROOT}/k_drivers/fbdev INSTALL_DIR=$(NEXUS_BIN_DIR) install
	cp -faR $(BRCMSTB_ANDROID_DRIVER_PATH)/nx_ashmem ${B_REFSW_OBJ_ROOT}/k_drivers/ && \
	$(MAKE) $(MAKE_OPTIONS) -C ${B_REFSW_OBJ_ROOT}/k_drivers/nx_ashmem NEXUS_MODE=driver INSTALL_DIR=$(NEXUS_BIN_DIR) install
	mkdir -p ${B_REFSW_OBJ_ROOT}/k_drivers/gator && cp -faR $(BRCMSTB_ANDROID_DRIVER_PATH)/gator/driver ${B_REFSW_OBJ_ROOT}/k_drivers/gator && \
	$(MAKE) -C $(LINUX_OUT) M=${B_REFSW_OBJ_ROOT}/k_drivers/gator/driver modules && \
	cp ${B_REFSW_OBJ_ROOT}/k_drivers/gator/driver/gator.ko $(NEXUS_BIN_DIR)
	@echo "'$@' completed"

.PHONY: clean_bolt
clean_bolt: clean_android_bsu
	$(MAKE) -C $(BOLT_DIR) distclean ODIR=$(B_BOLT_OBJ_ROOT) GEN=$(B_BOLT_OBJ_ROOT)
	rm -f $(PRODUCT_OUT_FROM_TOP)/bolt-ba.bin
	rm -f $(PRODUCT_OUT_FROM_TOP)/bolt-bb.bin

.PHONY: build_bolt
build_bolt:
	@echo "'$@' started"
	@if [ ! -d "${B_BOLT_OBJ_ROOT}" ]; then \
		mkdir -p ${B_BOLT_OBJ_ROOT}; \
	fi
	$(MAKE) -C $(BOLT_DIR) $(BCHP_CHIP)$(BCHP_VER_LOWER) ODIR=$(B_BOLT_OBJ_ROOT) GEN=$(B_BOLT_OBJ_ROOT)
	cp -pv $(B_BOLT_OBJ_ROOT)/bolt-ba.bin $(PRODUCT_OUT_FROM_TOP)/bolt-ba.bin || :
	cp -pv $(B_BOLT_OBJ_ROOT)/bolt-bb.bin $(PRODUCT_OUT_FROM_TOP)/bolt-bb.bin || :
	@echo "'$@' completed"

.PHONY: clean_android_bsu
clean_android_bsu:
	$(MAKE) -C $(ANDROID_BSU_DIR) distclean ODIR=$(B_BOLT_OBJ_ROOT) GEN=$(B_BOLT_OBJ_ROOT)
	rm -f $(PRODUCT_OUT_FROM_TOP)/android_bsu.elf

.PHONY: build_android_bsu
build_android_bsu: build_bolt
	@echo "'$@' started"
	$(MAKE) -C $(ANDROID_BSU_DIR) $(BCHP_CHIP)$(BCHP_VER_LOWER) ODIR=$(B_BOLT_OBJ_ROOT) GEN=$(B_BOLT_OBJ_ROOT)
	cp -pv $(B_BOLT_OBJ_ROOT)/android_bsu.elf $(PRODUCT_OUT_FROM_TOP)/android_bsu.elf || :
	@echo "'$@' completed"

.PHONY: build_bootloaderimg
_bootloader.img := $(PRODUCT_OUT)/bootloader.img
$(_bootloader.img): build_bootloaderimg
build_bootloaderimg: build_android_bsu
	@echo "'$@' started"
	$(ANDROID_BSU_DIR)/scripts/bootloaderimg.py $(PRODUCT_OUT_FROM_TOP)/$(BOLT_IMG_TO_USE_OVERRIDE) $(PRODUCT_OUT_FROM_TOP)/android_bsu.elf $(PRODUCT_OUT_FROM_TOP)/bootloader.img
	@echo "'$@' completed"

.PHONY: clean_bootloaderimg
clean_bootloaderimg:
	rm -f $(PRODUCT_OUT_FROM_TOP)/bootloader.img

.PHONY: clean_nexus
clean_nexus:
	rm -rf ${B_REFSW_OBJ_ROOT}

.PHONY: clean_refsw
clean_refsw: clean_nexus clean_bolt clean_bootloaderimg
	@echo "================ MAKE CLEAN"
	rm -rf ${BRCMSTB_ANDROID_OUT_PATH}/target/product/${ANDROID_PRODUCT_OUT}/obj/FAKE/refsw/
	rm -rf ${BRCMSTB_ANDROID_OUT_PATH}/target/product/${ANDROID_PRODUCT_OUT}/obj/EXECUTABLES/nxserver_*
	rm -rf ${BRCMSTB_ANDROID_OUT_PATH}/target/product/${ANDROID_PRODUCT_OUT}/obj/EXECUTABLES/nxmini_*

clean : clean_refsw

REFSW_BUILD_TARGETS := $(REFSW_TARGET_LIST)
$(REFSW_BUILD_TARGETS) : nexus_build
	@echo "'nexus_build' target: $@"

# for backwards compatibilty only!
.PHONY: refsw refsw_build
refsw: clean_recovery_ramdisk brcm_dhd_driver
refsw_build: clean_recovery_ramdisk brcm_dhd_driver

# standalone rules to clean/build the security libs from source, this assumes you have
# an environment allowing you to do that, otherwise do not bother.
#
# the libs are built in a NDK-like manner since that is essentially what they correspond
# to in the final android image.
#
# note: the order of the build components is important.
#

clean_recovery_ramdisk :
	@echo "'$@' started"
	rm -rf ${BRCMSTB_ANDROID_OUT_PATH}/target/product/${ANDROID_PRODUCT_OUT}/root/system/*
	rm -rf ${BRCMSTB_ANDROID_OUT_PATH}/target/product/${ANDROID_PRODUCT_OUT}/root/sbin/nxmini
	@echo "'$@' completed"

export URSR_TOP := ${REFSW_BASE_DIR}
export COMMON_DRM_TOP := $(URSR_TOP)/BSEAV/lib/security/common_drm
export PLAYREADY_ROOT := $(REFSW_BASE_DIR)/prsrcs/2.5/
export PLAYREADY_DIR := $(PLAYREADY_ROOT)/source/linux
export _NTROOT=${PLAYREADY_ROOT}

clean_security_user :
	$(MAKE) $(MAKE_OPTIONS) -C $(REFSW_BASE_DIR)/secsrcs/common_drm clean
	$(MAKE) $(MAKE_OPTIONS) -C $(REFSW_BASE_DIR)/secsrcs/third_party/android/drm/widevine/OEMCrypto clean
	$(MAKE) $(MAKE_OPTIONS) -C $(REFSW_BASE_DIR)/prsrcs/2.5/source clean

# build all the needed libs and 'install' them in the ndk-like environment for android pick up.
#
security_user: setup_nexus_toolchains
	@echo "'$@' started"
	$(MAKE) $(MAKE_OPTIONS) -C $(REFSW_BASE_DIR)/secsrcs/common_drm all
	cp -p $(REFSW_BASE_DIR)/secsrcs/common_drm/libcmndrm.so $(ANDROID_LINKER_SYSROOT)/usr/lib/libcmndrm.so
	$(MAKE) $(MAKE_OPTIONS) -C $(REFSW_BASE_DIR)/prsrcs/2.5/source all
	cp -p $(BSEAV_TOP)/lib/playready/2.5/bin/arm/lib/libplayreadypk_host.so $(ANDROID_LINKER_SYSROOT)/usr/lib/libplayreadypk_host.so
# If non-sage version is needed for testing purpose, you can uncomment the following 2 lines.
#	export PLAYREADY_HOST_BUILD=n; export PLAYREADY_STANDALONE_BUILD=y; $(MAKE) $(MAKE_OPTIONS) -C $(REFSW_BASE_DIR)/prsrcs/2.5/source all
#	cp -p $(BSEAV_TOP)/lib/playready/2.5/bin/arm/lib/libplayreadypk.so $(ANDROID_LINKER_SYSROOT)/usr/lib/libplayreadypk.so
	$(MAKE) $(MAKE_OPTIONS) -C $(REFSW_BASE_DIR)/secsrcs/third_party/android/drm/widevine/OEMCrypto
	cp -p $(REFSW_BASE_DIR)/secsrcs/third_party/android/drm/widevine/OEMCrypto/liboemcrypto.a $(ANDROID_LINKER_SYSROOT)/usr/lib/liboemcrypto.a
	@echo "'$@' completed"

include device/broadcom/avko/bcmdhd.mk
