ifndef LOCAL_PRODUCT_OUT
export LOCAL_PRODUCT_OUT         := avkodr4
endif

LOCAL_DEVICE_FSTAB               := device/broadcom/common/fstab/fstab.default.early:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.avkodr4
LOCAL_DEVICE_FSTAB               += device/broadcom/common/fstab/fstab.default.early:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.bcm
export LOCAL_DEVICE_FSTAB

export LOCAL_DEVICE_GPT          := device/broadcom/common/gpts/default-sys-bloat.conf

LOCAL_DEVICE_RCS                 := device/broadcom/common/rcs/init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.avkodr4.rc
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc

LOCAL_DEVICE_RECOVERY_RCS        := device/broadcom/common/rcs/init.recovery.rc:root/init.recovery.avkodr4.rc

export LOCAL_DEVICE_AON_GPIO     := device/broadcom/avko/rcs/aon_gpio.dr4.cfg:$(TARGET_COPY_OUT_VENDOR)/power/aon_gpio.cfg

export BOLT_BOARD_VB             := BCM97252SSFFDR4

# common to all avko devices.
include device/broadcom/avko/common.mk

# baseline the common support.
$(call inherit-product, device/broadcom/common/bcm.mk)
$(call inherit-product, build/make/target/product/product_launched_with_l.mk)
PRODUCT_NAME                     := avkodr4
PRODUCT_MODEL                    := avkodr4
PRODUCT_BRAND                    := broadcom
PRODUCT_DEVICE                   := avkodr4

# additional setup per device.
PRODUCT_PROPERTY_OVERRIDES += \
   ro.hardware=avkodr4 \
   \
   ro.opengles.version=196608 \
   ro.nx.mma=1 \
   \
   ro.nx.heap.video_secure=86m \
   ro.nx.heap.main=112m \
   ro.nx.heap.drv_managed=0m \
   ro.nx.heap.grow=8m \
   ro.nx.heap.shrink=2m \
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
   ro.nx.hwc2.tweak.force_eotf=0

TARGET_BOOTLOADER_BOARD_NAME := avkodr4
