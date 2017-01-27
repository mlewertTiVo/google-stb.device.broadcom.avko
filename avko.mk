# mandatory device configuration.
export NEXUS_PLATFORM            := 97439
export BCHP_VER                  := B0
export NEXUS_USE_7439_SFF        := y
export PLATFORM                  := 97439
export ANDROID_PRODUCT_OUT       := avko

# compile the rc's for the device.
LOCAL_DEVICE_RCS                 := device/broadcom/common/rcs/init.rc:root/init.avko.rc
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.nx.rc:root/init.nx.rc
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/ueventd.rc:root/ueventd.avko.rc
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.fs.default.rc:root/init.fs.rc  # NOT verity
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.eth.eth0.rc:root/init.eth.rc   # uses 'eth0'
LOCAL_DEVICE_RCS                 += device/broadcom/avko/rcs/init.block.rc:root/init.block.rc   # block devices
LOCAL_DEVICE_RCS                 += device/broadcom/avko/rcs/init.bcm.usb.rc:root/init.bcm.usb.rc   # uses 'configfs'
export LOCAL_DEVICE_RCS

LOCAL_DEVICE_RECOVERY_RCS        := device/broadcom/common/rcs/init.recovery.rc:root/init.recovery.avko.rc
LOCAL_DEVICE_RECOVERY_RCS        += device/broadcom/avko/rcs/init.block.rc:root/init.recovery.block.rc   # block devices
LOCAL_DEVICE_RECOVERY_RCS        += device/broadcom/avko/rcs/init.recovery.usb.rc:root/init.recovery.usb.rc   # uses 'configfs'
export LOCAL_DEVICE_RECOVERY_RCS

LOCAL_DEVICE_FSTAB               := device/broadcom/common/fstab/fstab.default:root/fstab.avko
LOCAL_DEVICE_FSTAB               += device/broadcom/common/fstab/fstab.default:root/fstab.bcm
export LOCAL_DEVICE_FSTAB

LOCAL_DEVICE_RECOVERY_FSTAB      := device/broadcom/common/recovery/fstab.default/recovery.fstab
export LOCAL_DEVICE_RECOVERY_FSTAB

# compile the media codecs for the device.
LOCAL_DEVICE_MEDIA               := device/broadcom/common/media/media_codecs.xml:system/etc/media_codecs.xml
LOCAL_DEVICE_MEDIA               += device/broadcom/common/media/media_profiles.xml:system/etc/media_profiles.xml
LOCAL_DEVICE_MEDIA               += device/broadcom/common/media/media_codecs_performance.xml:system/etc/media_codecs_performance.xml
export LOCAL_DEVICE_MEDIA

# optional device override/addition.
export LOCAL_DEVICE_OVERLAY      := device/broadcom/avko/overlay
export LOCAL_DEVICE_SEPOLICY_BLOCK := device/broadcom/avko/sepolicy-block
export LOCAL_DEVICE_AON_GPIO     := device/broadcom/avko/aon_gpio.cfg:system/vendor/power/aon_gpio.cfg
export LOCAL_DEVICE_KEY_POLL     := device/broadcom/common/keylayout/gpio_keys_polled.kl:system/usr/keylayout/gpio_keys_polled_5.kl
export LOCAL_DEVICE_REFERENCE_BUILD := device/broadcom/avko/reference_build.mk
export LOCAL_DEVICE_BT_CONFIG    := device/broadcom/avko/bluetooth/vnd_avko.txt
export LOCAL_DEVICE_USERDATA     := 6137298432 # ~5.7G
export LOCAL_DEVICE_GPT          := device/broadcom/common/gpts/default.conf
export V3D_VARIANT               := vc5
export BXPT_POWER_MANAGEMENT     := n
export BOLT_BOARD_VB             := BCM97252SSFFG_NOAVS

# kernel command line.
LOCAL_DEVICE_KERNEL_CMDLINE      := mem=1024m@0m mem=1024m@2048m
LOCAL_DEVICE_KERNEL_CMDLINE      += bmem=339m@669m bmem=237m@2048m
LOCAL_DEVICE_KERNEL_CMDLINE      += brcm_cma=780m@2288m
LOCAL_DEVICE_KERNEL_CMDLINE      += ramoops.mem_address=0x3F400000 ramoops.mem_size=0x800000 ramoops.console_size=0x400000 pmem=8m@1012m
export LOCAL_DEVICE_KERNEL_CMDLINE

# baseline the common support.
$(call inherit-product, device/broadcom/common/bcm.mk)
PRODUCT_NAME                     := avko
PRODUCT_MODEL                    := avko
PRODUCT_BRAND                    := google
PRODUCT_DEVICE                   := avko

# additional setup per device.
PRODUCT_PROPERTY_OVERRIDES    += ro.hardware=avko
PRODUCT_PROPERTY_OVERRIDES    += ro.product.board=avko


