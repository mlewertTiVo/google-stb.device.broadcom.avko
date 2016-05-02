# BoardConfig.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := cortex-a15
ifeq ($(TARGET_ARCH),arm)
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
endif
ifeq ($(TARGET_ARCH),mips)
TARGET_CPU_ABI := mips
TARGET_CPU_ABI2 := mipsel
endif
TARGET_CPU_SMP := true

TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := false
TARGET_NO_RADIOIMAGE := true

# redux - we provide a modified init.rc with minimal services.
ifeq ($(LOCAL_RUN_TARGET),redux)
TARGET_PROVIDES_INIT_RC := true
endif

HAVE_HTC_AUDIO_DRIVER := true
BOARD_USES_GENERIC_AUDIO := false
export TARGET_BOARD_PLATFORM := avko
HTTP_STACK := chrome
JAVASCRIPT_ENGINE := v8
JS_ENGINE := v8
WITH_JIT := true

ADDITIONAL_BUILD_PROPERTIES += \
   ro.hdmi.device_type=4

USE_OPENGL_RENDERER := true

ADDITIONAL_BUILD_PROPERTIES += \
   ro.ir_remote.mode=CirNec \
   ro.ir_remote.map=broadcom_silver \
   ro.ir_remote.mask=0 \
   ro.ir_remote.initial_timeout=55 \
   ro.ir_remote.timeout=115 \
   ro.ir_remote.wakeup.button=398

ADDITIONAL_BUILD_PROPERTIES += \
   net.http.threads=25 \
   media.aac_51_output_enabled=true \
   media.stagefright.cache-params=32768/65536/25 \
   media.httplive.startathighbw=1

ADDITIONAL_BUILD_PROPERTIES += \
   ro.nx.logger_size=4096

ifeq ($(TARGET_BUILD_VARIANT),user)
ADDITIONAL_DEFAULT_PROPERTIES += \
   ro.adb.secure=1
endif

WPA_SUPPLICANT_VERSION := VER_0_8_X

# Wifi related defines
BOARD_WLAN_DEVICE                      := bcmdhd
BOARD_WLAN_DEVICE_REV                  := bcm4334_b1
WPA_SUPPLICANT_VERSION                 := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER            := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB       := lib_driver_cmd_bcmdhd
#BOARD_HOSTAPD_DRIVER                  := NL80211
#BOARD_HOSTAPD_PRIVATE_LIB             := lib_driver_cmd_bcmdhd

# BTUSB
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/broadcom/avko/bluetooth
BOARD_CUSTOM_BT_CONFIG := device/broadcom/avko/bluetooth/vnd_avko.txt

BOARD_WIDEVINE_OEMCRYPTO_LEVEL := 3

ADDITIONAL_BUILD_PROPERTIES += \
    ro.graphics_resolution.width=1920 \
    ro.graphics_resolution.height=1080 \
    ro.sf.lcd_density=320 \
    ro.v3d.fence.expose=true

TARGET_USERIMAGES_USE_EXT4            := true
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE     := ext4
BOARD_BOOTIMAGE_PARTITION_SIZE        := 33554432   # 32M
BOARD_RECOVERYIMAGE_PARTITION_SIZE    := 33554432   # 32M
BOARD_CACHEIMAGE_PARTITION_SIZE       := 268435456  # 256M
BOARD_SYSTEMIMAGE_PARTITION_SIZE      := 1317011456 # 1256M
ifeq ($(EXPERIMENTAL_SQUASHFS),wanted)
BOARD_SYSTEMIMAGE_JOURNAL_SIZE        := 0
BOARD_SYSTEMIMAGE_SQUASHFS_COMPRESSOR := lz4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE    := squashfs
endif
BOARD_USERDATAIMAGE_PARTITION_SIZE    := 6137298432 # ~5.7G

BOARD_FLASH_BLOCK_SIZE := 512
BOARD_KERNEL_BASE := 0x00008000
BOARD_KERNEL_PAGESIZE := 4096

BOARD_KERNEL_CMDLINE := mem=1024m@0m mem=1024m@2048m bmem=336m@672m bmem=256m@2048m brcm_cma=768m@2304m
BOARD_KERNEL_CMDLINE += ramoops.mem_address=0x3F800000 ramoops.mem_size=0x800000 ramoops.console_size=0x400000 pmem=8m@1016m

BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x02000000

ifeq ($(EXPERIMENTAL_SQUASHFS),wanted)
TARGET_RECOVERY_FSTAB := device/broadcom/avko/recovery/fstab-squashfs/recovery.fstab
else
TARGET_RECOVERY_FSTAB := device/broadcom/avko/recovery/fstab-default/recovery.fstab
endif
TARGET_RECOVERY_UI_LIB := librecovery_ui_avko
TARGET_RECOVERY_UPDATER_LIBS := librecovery_updater_avko
TARGET_RELEASETOOLS_EXTENSIONS := device/broadcom/avko
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"

TARGET_IS_AOSP := false

BOARD_SEPOLICY_DIRS += device/broadcom/avko/sepolicy
BOARD_SEPOLICY_DIRS += device/broadcom/avko/sepolicy-block

# using legacy audio policy.
USE_LEGACY_AUDIO_POLICY := 0
USE_CUSTOM_AUDIO_POLICY := 1

NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

TARGET_BOARD_KERNEL_HEADERS := device/broadcom/avko/kernel-headers

# set to 'true' for clang integration.
USE_CLANG_PLATFORM_BUILD := false

include device/broadcom/avko/bcm_refsw.mk

