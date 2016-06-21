#
# Copyright 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# It is required to build the Kernel from source.
KERNEL_SRC_DIR ?= kernel/private/bcm-97xxx/linux
ifeq ($(wildcard $(KERNEL_SRC_DIR)/Makefile),)
  $(error Unable to build kernel from source, aborting.)
endif

# To prevent from including GMS twice in Google's internal source.
ifeq ($(wildcard vendor/google/prebuilt),)
PRODUCT_USE_PREBUILT_GMS := yes
endif

# standard target - based on the standard google atv device if present,
#                   otherwise fallback (note pdk device is not atv based in
#                   particular since device/google/atv is not part of pdk).
ifeq (,$(LOCAL_RUN_TARGET))
  ifneq ($(wildcard $(TOPDIR)device/google/atv/permissions/tv_core_hardware.xml),)
    $(call inherit-product, $(SRC_TARGET_DIR)/product/locales_full.mk)
    $(call inherit-product, $(TOPDIR)device/google/atv/products/atv_base.mk)
  else
    $(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
    PRODUCT_COPY_FILES += $(TOPDIR)device/broadcom/avko/tv_core_hardware.xml:system/etc/permissions/tv_core_hardware.xml
  endif
endif
# aosp - inherit from AOSP-BASE, not ATV.
ifeq ($(LOCAL_RUN_TARGET),aosp)
  PRODUCT_COPY_FILES += $(TOPDIR)device/broadcom/avko/tv_core_hardware.xml:system/etc/permissions/tv_core_hardware.xml
  $(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
endif

# Build WebView from source when using the internal source.
override PRODUCT_PREBUILT_WEBVIEWCHROMIUM := $(PRODUCT_USE_PREBUILT_GMS)

ifneq ($(wildcard $(TOPDIR)vendor/google/products/gms.mk),)
  PRODUCT_COPY_FILES += $(TOPDIR)device/broadcom/avko/google_aware.xml:system/etc/permissions/google_aware.xml
endif

include device/broadcom/avko/settings.mk
include device/broadcom/avko/refsw_defs.mk

ifeq ($(TARGET_BUILD_VARIANT),user)
  export B_REFSW_DEBUG ?= n
  export B_REFSW_DEBUG_LEVEL :=
else
  export B_REFSW_DEBUG ?= y
  export B_REFSW_DEBUG_LEVEL := msg
endif

ifneq ($(wildcard device/google/atv/permissions/tv_core_hardware.xml),)
  # purposefully swap overlay layout to override some settings from
  # the ATV setup.
  DEVICE_PACKAGE_OVERLAYS := device/broadcom/avko/overlay
  DEVICE_PACKAGE_OVERLAYS += device/google/atv/overlay
else
  DEVICE_PACKAGE_OVERLAYS += device/broadcom/avko/overlay
endif

PRODUCT_AAPT_CONFIG := normal large xlarge tvdpi hdpi xhdpi xxhdpi
PRODUCT_AAPT_PREF_CONFIG := xhdpi

ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.hardware=avko \
    ro.product.board=avko

TARGET_CPU_SMP := true

PRODUCT_COPY_FILES += \
    ${NEXUS_BIN_DIR}/nexus.ko:system/vendor/drivers/nexus.ko \
    ${NEXUS_BIN_DIR}/nx_ashmem.ko:system/vendor/drivers/nx_ashmem.ko \
    device/broadcom/avko/bootanimation.zip:system/media/bootanimation.zip \
    device/broadcom/avko/init.blockdev.rc:root/init.blockdev.rc \
    device/broadcom/avko/init.blockdev.rc:root/init.recovery.blockdev.rc \
    device/broadcom/avko/init.eth.rc:root/init.eth.rc \
    device/broadcom/avko/init.recovery.bcm_platform.rc:root/init.recovery.avko.rc \
    device/broadcom/avko/init.recovery.nx.dynheap.rc:root/init.recovery.nx.dynheap.rc \
    device/broadcom/avko/media_codecs.xml:system/etc/media_codecs.xml \
    device/broadcom/avko/media_profiles.xml:system/etc/media_profiles.xml \
    device/broadcom/avko/media_codecs_performance.xml:system/etc/media_codecs_performance.xml \
    device/broadcom/avko/aon_gpio.cfg:system/vendor/power/aon_gpio.cfg \
    device/broadcom/avko/audio_policy_btusb.conf:system/etc/audio_policy.conf \
    device/broadcom/avko/gpio_keys_polled.kl:system/usr/keylayout/gpio_keys_polled_5.kl \
    device/broadcom/avko/nexus_silver_remote.kl:system/usr/keylayout/NexusIrHandler.kl \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_tv.xml:system/etc/media_codecs_google_tv.xml \
    device/broadcom/avko/webview-command-line:/data/local/tmp/webview-command-line \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.hdmi.cec.xml:system/etc/permissions/android.hardware.hdmi.cec.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:system/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.software.live_tv.xml:system/etc/permissions/android.software.live_tv.xml \
    frameworks/native/data/etc/android.software.webview.xml:system/etc/permissions/android.software.webview.xml \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/nxif/libnexusir/irkeymap/broadcom_black.ikm:system/usr/irkeymap/broadcom_black.ikm \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/nxif/libnexusir/irkeymap/broadcom_silver.ikm:system/usr/irkeymap/broadcom_silver.ikm \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/gps.conf:system/etc/gps.conf \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/init.broadcomstb.rc:root/init.avko.rc \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/init.broadcomstb.usb.rc:root/init.bcm_platform.usb.rc \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/init.nx.dynheap.rc:root/init.nx.dynheap.rc \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/ueventd.bcm_platform.rc:root/ueventd.avko.rc \
    ${NEXUS_BIN_DIR}/droid_pm.ko:system/vendor/drivers/droid_pm.ko \
    ${NEXUS_BIN_DIR}/gator.ko:system/vendor/drivers/gator.ko

ifeq ($(EXPERIMENTAL_SQUASHFS),wanted)
PRODUCT_COPY_FILES += \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/fstab.squashfs:root/fstab.bcm_platform \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/fstab.squashfs:root/fstab.avko
else
PRODUCT_COPY_FILES += \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/fstab.broadcomstb:root/fstab.bcm_platform \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/cfgs/fstab.broadcomstb:root/fstab.avko
endif

ifeq ($(SAGE_SUPPORT),y)
SAGE_BL_BINARY_PATH  := $(BSEAV_TOP)/lib/security/sage/bin/$(BCHP_CHIP)$(BCHP_VER)
SAGE_APP_BINARY_PATH := $(SAGE_BL_BINARY_PATH)/securemode$(SAGE_SECURE_MODE)
PRODUCT_COPY_FILES += \
    ${SAGE_BL_BINARY_PATH}/sage_bl.bin:system/bin/sage_bl.bin \
    ${SAGE_BL_BINARY_PATH}/sage_bl_dev.bin:system/bin/sage_bl_dev.bin \
    ${SAGE_APP_BINARY_PATH}/sage_os_app.bin:system/bin/sage_os_app.bin \
    ${SAGE_APP_BINARY_PATH}/sage_os_app_dev.bin:system/bin/sage_os_app_dev.bin
endif

PRODUCT_PROPERTY_OVERRIDES += \
    ro.bq.gpu_to_cpu_unsupported=1 \
    ro.zygote.disable_gl_preload=true \
    sys.display-size=1920x1080 \
    persist.sys.hdmi.keep_awake=false

# GMS package integration.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-avko-tv

# nx configuration.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=196608 \
    debug.hwui.render_dirty_regions=false \
    ro.nx.heap.video_secure=80m \
    ro.nx.heap.main=96m \
    ro.nx.heap.drv_managed=0m \
    ro.nx.mma=1 \
    ro.nx.heap.grow=8m \
    ro.nx.heap.shrink=2m \
    ro.nx.heap.gfx=72m \
    ro.nx.odv=0 \
    ro.nx.odv.use.alt=150m \
    ro.nx.odv.a1.use=50 \
    ro.nx.capable.cb=1 \
    ro.nx.capable.si=1 \
    ro.v3d.fence.expose=true \
    ro.nx.svp=1

# This provides the build id of the reference platform that the current build
# is based on. Do not remove this line.
$(call inherit-product, device/broadcom/avko/reference_build.mk)

$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

PRODUCT_PACKAGES += \
    busybox \
    dhcpcd.conf \
    e2fsck \
    gatord \
    gptbin \
    hfrvideo \
    makehwcfg \
    netcoal \
    nxdispfmt \
    nxserver \
    nxlogger \
    wpa_supplicant

# only for full image.
ifeq (,$(filter redux,$(LOCAL_RUN_TARGET)))
  PRODUCT_PACKAGES += \
      audio.primary.avko \
      audio.usb.default \
      audio.r_submix.default \
      audio.atvr.default \
      libaudiopolicymanagerdefault \
      libaudiopolicymanager \
      BcmAdjustScreenOffset \
      BcmCoverFlow \
      BcmSidebandViewer \
      BcmTVInput \
      BcmOtaUpdater \
      BcmKeyInterceptor \
      camera.avko \
      gralloc.avko \
      hdmi_cec.avko \
      hwcbinder \
      hwcomposer.avko \
      libhwcbinder \
      libhwcconv \
      libjni_adjustScreenOffset \
      libGLES_nexus \
      libnexusir \
      libpmlibservice \
      libpng \
      libquake \
      libstagefrighthw \
      libbcrypt \
      libdrmrootfs \
      libcmndrm \
      libcmndrm_tl \
      libsrai \
      liboemcrypto \
      libwvdrmengine \
      libcmndrmprdy \
      libplayreadydrmplugin \
      libplayreadypk_host \
      memtrack.avko \
      power.avko \
      pmlibserver \
      send_cec \
      tv_input.avko \
      TV \
      TvProvider

  PRODUCT_PROPERTY_OVERRIDES += drm.service.enabled=true
endif

$(call inherit-product-if-exists, ${BCM_VENDOR_STB_ROOT}/bcm_platform/device-vendor.mk)

PRODUCT_NAME := avko
PRODUCT_DEVICE := avko
PRODUCT_MODEL := avko
PRODUCT_CHARACTERISTICS := tv
PRODUCT_MANUFACTURER := broadcom
PRODUCT_BRAND := google

# exporting toolchains path for kernel image+modules
export PATH := ${ANDROID}/vendor/broadcom/prebuilts/stbgcc-4.8-1.5/bin:${PATH}

# This makefile copies the prebuilt BT kernel module and corresponding firmware and configuration files

PRODUCT_COPY_FILES += \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/conx/btusb/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml

ADDITIONAL_BUILD_PROPERTIES += \
    ro.rfkilldisabled=1

PRODUCT_COPY_FILES += \
   ${BCM_VENDOR_STB_ROOT}/bcm_platform/conx/btusb/firmware/BCM43569A2_001.003.004.0074.0000_Generic_USB_40MHz_fcbga_BU_WakeOn_BLE_Google.hcd:system/vendor/broadcom/btusb/firmware/BCM_bt_fw.hcd

PRODUCT_PACKAGES += \
	audio.a2dp.default

# This makefile copies the prebuilt wifi driver module and corresponding firmware and configuration files
BRCM_DHD_DRIVER_TARGETS := \
	${B_DHD_OBJ_ROOT}/fw.bin.trx \
	${B_DHD_OBJ_ROOT}/nvm.txt \
	${B_DHD_OBJ_ROOT}/driver/bcmdhd.ko

PRODUCT_COPY_FILES += \
    ${B_DHD_OBJ_ROOT}/driver/bcmdhd.ko:system/vendor/broadcom/dhd/driver/bcmdhd.ko \
    ${B_DHD_OBJ_ROOT}/fw.bin.trx:system/vendor/firmware/broadcom/dhd/firmware/fw.bin.trx \
    ${B_DHD_OBJ_ROOT}/nvm.txt:system/vendor/firmware/broadcom/dhd/nvrams/nvm.txt \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/conx/dhd/init.brcm_dhd.rc:root/init.brcm_dhd.rc \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/conx/dhd/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/conx/dhd/p2p_supplicant.conf:system/etc/wifi/p2p_supplicant.conf \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/conx/dhd/wpa_supplicant_overlay.conf:system/etc/wifi/wpa_supplicant_overlay.conf \
    ${BCM_VENDOR_STB_ROOT}/bcm_platform/conx/dhd/p2p_supplicant_overlay.conf:system/etc/wifi/p2p_supplicant_overlay.conf

PRODUCT_PACKAGES += \
    dhcpcd.conf \
    network \
    wpa_supplicant

PRODUCT_PROPERTY_OVERRIDES += \
   wifi.interface=wlan0 \
   ro.nrdp.modelgroup=AVKO
