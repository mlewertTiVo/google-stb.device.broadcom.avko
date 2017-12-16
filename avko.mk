export LOCAL_PRODUCT_OUT       := avko

LOCAL_DEVICE_FSTAB               := device/broadcom/common/fstab/fstab.default.early:root/fstab.avko
LOCAL_DEVICE_FSTAB               += device/broadcom/common/fstab/fstab.default.early:root/fstab.bcm
export LOCAL_DEVICE_FSTAB

export LOCAL_DEVICE_GPT          := device/broadcom/common/gpts/default.conf

LOCAL_DEVICE_RCS                 := device/broadcom/common/rcs/init.rc:root/init.avko.rc
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/ueventd.rc:root/ueventd.avko.rc

LOCAL_DEVICE_RECOVERY_RCS        := device/broadcom/common/rcs/init.recovery.rc:root/init.recovery.avko.rc

# common to all avko devices.
include device/broadcom/avko/common.mk

# baseline the common support.
$(call inherit-product, device/broadcom/common/bcm.mk)
$(call inherit-product, build/make/target/product/product_launched_with_l.mk)
PRODUCT_NAME                     := avko
PRODUCT_MODEL                    := avko
PRODUCT_BRAND                    := google
PRODUCT_DEVICE                   := avko

# additional setup per device.
PRODUCT_PROPERTY_OVERRIDES    += ro.hardware=avko
TARGET_BOOTLOADER_BOARD_NAME := avko
