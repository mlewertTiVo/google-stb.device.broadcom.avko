# mandatory device configuration.
export NEXUS_PLATFORM            := 97439
export BCHP_VER                  := B0
export NEXUS_USE_7439_SFF        := y
export PLATFORM                  := 97439

# binary distribution
export BCM_BINDIST_BL_ROOT       := vendor/broadcom/prebuilts/bootloaders/avko
export BCM_BINDIST_LIBS_ROOT     := vendor/broadcom/prebuilts/nximg/4.9/avko
export BCM_BINDIST_KNL_ROOT      := device/broadcom/avko-kernel/4.9
export BCM_DIST_FORCED_BINDIST   := y

# compile the rc's for the device.
ifneq ($(LOCAL_NVI_LAYOUT),y)
ifeq ($(LOCAL_DEVICE_FULL_TREBLE),y)
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.ft.nx.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nx.rc
else
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.nx.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nx.rc
endif
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.fs.default.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.fs.rc  # NOT verity
LOCAL_DEVICE_RCS                 += device/broadcom/avko/rcs/init.block.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.block.rc      # block devices
LOCAL_DEVICE_RCS                 += device/broadcom/avko/rcs/init.bcm.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.bcm.usb.rc  # uses 'configfs'
else
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.nx.rc:root/init.nx.rc
LOCAL_DEVICE_RCS                 += device/broadcom/common/rcs/init.nvi.fs.default.rc:root/init.fs.rc  # NOT verity
LOCAL_DEVICE_RCS                 += device/broadcom/avko/rcs/init.block.rc:root/init.block.rc          # block devices
LOCAL_DEVICE_RCS                 += device/broadcom/avko/rcs/init.bcm.usb.rc:root/init.bcm.usb.rc      # uses 'configfs'
endif
export LOCAL_DEVICE_RCS

LOCAL_DEVICE_RECOVERY_RCS        += device/broadcom/avko/rcs/init.block.rc:root/init.recovery.block.rc        # block devices
LOCAL_DEVICE_RECOVERY_RCS        += device/broadcom/avko/rcs/init.recovery.usb.rc:root/init.recovery.usb.rc   # uses 'configfs'
export LOCAL_DEVICE_RECOVERY_RCS

LOCAL_DEVICE_RECOVERY_FSTAB      := device/broadcom/common/recovery/fstab.default/recovery.fstab
export LOCAL_DEVICE_RECOVERY_FSTAB

# compile the media codecs for the device.
LOCAL_DEVICE_MEDIA               := device/broadcom/common/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml
LOCAL_DEVICE_MEDIA               += device/broadcom/common/media/media_profiles.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml
LOCAL_DEVICE_MEDIA               += device/broadcom/avko/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml
export LOCAL_DEVICE_MEDIA

# optional device override/addition.
export LOCAL_DEVICE_OVERLAY      := device/broadcom/avko/overlay
LOCAL_DEVICE_SEPOLICY_BLOCK      := device/broadcom/avko/sepolicy/block
ifeq ($(LOCAL_DEVICE_FULL_TREBLE),y)
LOCAL_DEVICE_SEPOLICY_BLOCK      += device/broadcom/avko/sepolicy/treble
endif
export LOCAL_DEVICE_SEPOLICY_BLOCK
export LOCAL_DEVICE_KEY_POLL     := device/broadcom/common/keylayout/gpio_keys_polled.kl:system/usr/keylayout/gpio_keys_polled.kl
export LOCAL_DEVICE_REFERENCE_BUILD := device/broadcom/avko/reference_build.mk
export LOCAL_DEVICE_BT_CONFIG    := device/broadcom/avko/bluetooth/vnd_avko.txt
export LOCAL_DEVICE_USERDATA     := 5386518016 # ~5.0G
export V3D_VARIANT               := vc5
export BXPT_POWER_MANAGEMENT     := n
export BOLT_BOARD_VB             := BCM97252SSFFG_NOAVS
export LOCAL_DEVICE_PAK_BINARY   := pak.7252s.zd.bin

# kernel command line.
LOCAL_DEVICE_KERNEL_CMDLINE      := mem=984m@0m mem=32m@992m mem=1024m@2048m
LOCAL_DEVICE_KERNEL_CMDLINE      += bmem=328m@656m bmem=314m@2758m
LOCAL_DEVICE_KERNEL_CMDLINE      += brcm_cma=710m@2048m
LOCAL_DEVICE_KERNEL_CMDLINE      += ramoops.mem_address=0x3D800000 ramoops.mem_size=0x800000 ramoops.console_size=0x400000
export LOCAL_DEVICE_KERNEL_CMDLINE
