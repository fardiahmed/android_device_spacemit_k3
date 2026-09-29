#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Generate dtb.img from the K3 DTB files of the kernel dist

ifeq ($(TARGET_DEVICE),k3)

MKDTIMG := prebuilts/misc/linux-x86/libufdt/mkdtimg
DTBIMAGE := $(PRODUCT_OUT)/dtb.img

LOCAL_DTB := device/spacemit/k3-kernel/$(TARGET_KERNEL_USE)

# All K3 DTBs of the kernel dist; U-Boot picks the board's one.
DTB_FILES := $(sort $(wildcard $(LOCAL_DTB)/k3-*.dtb))

$(DTBIMAGE): $(DTB_FILES) $(MKDTIMG)
	$(if $(DTB_FILES),,$(error No K3 DTB in $(LOCAL_DTB): run the Kleaf bananapi_sm10 dist first))
	$(MKDTIMG) create $@ --page_size=4096 $(DTB_FILES)

include $(CLEAR_VARS)
LOCAL_MODULE := dtbimage
LOCAL_LICENSE_KINDS := legacy_notice
LOCAL_LICENSE_CONDITIONS := notice
LOCAL_ADDITIONAL_DEPENDENCIES := $(DTBIMAGE)
include $(BUILD_PHONY_PACKAGE)

droidcore: dtbimage

endif
