# non-vendor-image layout: there is no separate partition for vendor.img in O+. 	1
export LOCAL_NVI_LAYOUT          := y
export ANDROID_PRODUCT_OUT       := avko_nvi

LOCAL_DEVICE_FSTAB               := device/broadcom/common/fstab/fstab.nvi.default:root/fstab.avko_nvi
LOCAL_DEVICE_FSTAB               += device/broadcom/common/fstab/fstab.nvi.default:root/fstab.bcm
export LOCAL_DEVICE_FSTAB

export LOCAL_DEVICE_GPT          := device/broadcom/common/gpts/default.nvi.conf

LOCAL_DEVICE_RCS                 := device/broadcom/common/rcs/init.rc:root/init.avko_nvi.rc
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/ueventd.rc:root/ueventd.avko_nvi.rc

LOCAL_DEVICE_RECOVERY_RCS        := device/broadcom/common/rcs/init.recovery.rc:root/init.recovery.avko_nvi.rc

# common to all avko devices.
include device/broadcom/avko/common.mk

# baseline the common support.
$(call inherit-product, device/broadcom/common/bcm.mk)
$(call inherit-product, build/make/target/product/product_launched_with_l.mk)
PRODUCT_NAME                     := avko_nvi
PRODUCT_MODEL                    := avko_nvi
PRODUCT_BRAND                    := broadcom
PRODUCT_DEVICE                   := avko_nvi

# additional setup per device.
PRODUCT_PROPERTY_OVERRIDES    += ro.hardware=avko_nvi
PRODUCT_PROPERTY_OVERRIDES    += ro.product.board=avko_nvi
