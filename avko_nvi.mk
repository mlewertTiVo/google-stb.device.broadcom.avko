# non-vendor-image layout: there is no separate partition for vendor.img in O+.
export LOCAL_NVI_LAYOUT          := y
ifndef LOCAL_PRODUCT_OUT
export LOCAL_PRODUCT_OUT         := avko
endif
export TARGET_SAGE_PLATFORM      := avko
export LOCAL_FULL_TREBLE_NOT_COMPATIBLE := y

LOCAL_DEVICE_FSTAB               := device/broadcom/common/fstab/fstab.nvi.default:root/fstab.avko
LOCAL_DEVICE_FSTAB               += device/broadcom/common/fstab/fstab.nvi.default:root/fstab.bcm
export LOCAL_DEVICE_FSTAB

export LOCAL_DEVICE_GPT          := device/broadcom/common/gpts/default.nvi.conf

LOCAL_DEVICE_RCS                 := device/broadcom/common/rcs/init.nvi.rc:root/init.avko.rc
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/ueventd.rc:root/ueventd.avko.rc

LOCAL_DEVICE_RECOVERY_RCS        := device/broadcom/common/rcs/init.recovery.rc:root/init.recovery.avko.rc

export LOCAL_DEVICE_AON_GPIO     := device/broadcom/avko/rcs/aon_gpio.cfg:$(TARGET_COPY_OUT_VENDOR)/power/aon_gpio.cfg

export BOLT_BOARD_VB             := BCM97252SSFFG_NOAVS

# common to all avko devices.
include device/broadcom/avko/common.mk

# baseline the common support.
$(call inherit-product, device/broadcom/common/bcm.mk)
$(call inherit-product, build/make/target/product/product_launched_with_l.mk)
PRODUCT_NAME                     := avko_nvi
PRODUCT_MODEL                    := avko
PRODUCT_BRAND                    := google
PRODUCT_DEVICE                   := avko

# additional setup per device.
# additional setup per device.
PRODUCT_PROPERTY_OVERRIDES += \
   ro.hardware=avko \
   \
   ro.opengles.version=196608 \
   debug.v3d.use_mma=1 \
   \
   ro.nx.heap.video_secure=86m \
   ro.nx.heap.main=112m \
   ro.nx.heap.drv_managed=0m \
   ro.nx.heap.grow=1 \
   ro.nx.heap.gfx=64m \
   \
   ro.nx.capable.cb=1 \
   ro.nx.capable.si=1 \
   ro.sf.lcd_density=320 \
   \
   ro.rfkilldisabled=1 \
   ro.nx.eth.irq_mode_mask=3:2 \
   \
   ro.com.google.clientidbase=android-avko-tv \
   \
   ro.nx.hwc2.tweak.force_eotf=0

TARGET_BOOTLOADER_BOARD_NAME := avko
# including special configuration for nvi target.
include device/broadcom/common/nvi.mk
