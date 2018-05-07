LOCAL_PATH := $(my-dir)

include $(LOCAL_PATH)/AndroidKernel.mk
include $(LOCAL_PATH)/AndroidPhony.mk

$(call add-radio-file, bootloader.img)

ifneq ($(BCM_DIST_BLIM_BINS),y)
$(call add-radio-file, gpt.bin)
endif

