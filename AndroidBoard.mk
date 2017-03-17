LOCAL_PATH := $(my-dir)

include $(LOCAL_PATH)/AndroidKernel.mk
include $(LOCAL_PATH)/AndroidPhony.mk

$(call add-radio-file, bootloader.img)
$(call add-radio-file, gpt.bin)

