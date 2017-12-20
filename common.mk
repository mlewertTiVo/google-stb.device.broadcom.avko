# mandatory device configuration.
export NEXUS_PLATFORM            := 97439
export BCHP_VER                  := B0
export NEXUS_USE_7439_SFF        := y
export PLATFORM                  := 97439

# binary distribution
export BCM_BINDIST_BL_ROOT       := vendor/broadcom/prebuilts/bootloaders/avko
export BCM_BINDIST_LIBS_ROOT     := vendor/broadcom/prebuilts/nximg/4.1/avko
export BCM_BINDIST_KNL_ROOT      := device/broadcom/avko-kernel/4.1
export BCM_DIST_FORCED_BINDIST   := y
export BCM_DIST_BLIM_BINS        := y

# compile the rc's for the device.
ifeq ($(LOCAL_DEVICE_FULL_TREBLE),y)
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.ft.nx.rc:root/init.nx.rc
else
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.nx.rc:root/init.nx.rc
endif
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.fs.default.rc:root/init.fs.rc  # NOT verity
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.eth.eth0.rc:root/init.eth.rc   # uses 'eth0'
LOCAL_DEVICE_RCS                 += device/broadcom/avko/rcs/init.block.rc:root/init.block.rc   # block devices
LOCAL_DEVICE_RCS                 += device/broadcom/avko/rcs/init.bcm.usb.rc:root/init.bcm.usb.rc   # uses 'configfs'
export LOCAL_DEVICE_RCS

LOCAL_DEVICE_RECOVERY_RCS        += device/broadcom/avko/rcs/init.block.rc:root/init.recovery.block.rc   # block devices
LOCAL_DEVICE_RECOVERY_RCS        += device/broadcom/avko/rcs/init.recovery.usb.rc:root/init.recovery.usb.rc   # uses 'configfs'
export LOCAL_DEVICE_RECOVERY_RCS

LOCAL_DEVICE_RECOVERY_FSTAB      := device/broadcom/common/recovery/fstab.default/recovery.fstab
export LOCAL_DEVICE_RECOVERY_FSTAB

# compile the media codecs for the device.
LOCAL_DEVICE_MEDIA               := device/broadcom/common/media/media_codecs.xml:system/etc/media_codecs.xml
LOCAL_DEVICE_MEDIA               += device/broadcom/common/media/media_profiles.xml:system/etc/media_profiles.xml
LOCAL_DEVICE_MEDIA               += device/broadcom/avko/media_codecs_performance.xml:system/etc/media_codecs_performance.xml
export LOCAL_DEVICE_MEDIA

# optional device override/addition.
export LOCAL_DEVICE_OVERLAY      := device/broadcom/avko/overlay
LOCAL_DEVICE_SEPOLICY_BLOCK      := device/broadcom/avko/sepolicy/block
ifeq ($(LOCAL_DEVICE_FULL_TREBLE),y)
LOCAL_DEVICE_SEPOLICY_BLOCK      += device/broadcom/avko/sepolicy/treble
endif
export LOCAL_DEVICE_SEPOLICY_BLOCK
export LOCAL_DEVICE_AON_GPIO     := device/broadcom/avko/aon_gpio.cfg:$(TARGET_COPY_OUT_VENDOR)/power/aon_gpio.cfg
export LOCAL_DEVICE_KEY_POLL     := device/broadcom/common/keylayout/gpio_keys_polled.kl:system/usr/keylayout/gpio_keys_polled.kl
export LOCAL_DEVICE_REFERENCE_BUILD := device/broadcom/avko/reference_build.mk
export LOCAL_DEVICE_BT_CONFIG    := device/broadcom/avko/bluetooth/vnd_avko.txt
export LOCAL_DEVICE_USERDATA     := 6137298432 # ~5.7G
export V3D_VARIANT               := vc5
export BXPT_POWER_MANAGEMENT     := n
export BOLT_BOARD_VB             := BCM97252SSFFG_NOAVS

# kernel command line.
LOCAL_DEVICE_KERNEL_CMDLINE      := mem=984m@0m mem=32m@992m mem=1024m@2048m
LOCAL_DEVICE_KERNEL_CMDLINE      += bmem=328m@656m bmem=263m@2809m
LOCAL_DEVICE_KERNEL_CMDLINE      += brcm_cma=731m@2048m
LOCAL_DEVICE_KERNEL_CMDLINE      += ramoops.mem_address=0x3D800000 ramoops.mem_size=0x800000 ramoops.console_size=0x400000
export LOCAL_DEVICE_KERNEL_CMDLINE
