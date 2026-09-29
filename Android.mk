LOCAL_PATH := $(call my-dir)

# Make visits every Android.mk whatever the product: keep these PRODUCT_OUT rules to K3 builds.
ifeq ($(TARGET_DEVICE),k3)

#
# Bootloader prebuilts (SpacemiT K3 U-Boot/OpenSBI for the SM10) and the partition table, copied
# to PRODUCT_OUT next to the images. Source: vendor/spacemit/k3/bootloader/, same layout as
# vendor/spacemit/k1/bootloader/ (see device/spacemit/k1/Android.mk). Inert until it exists.
#
BL_PREBUILT := vendor/spacemit/k3/bootloader

ifneq ($(wildcard $(BL_PREBUILT)/u-boot-release.itb),)

SPACEMIT_K3_FLASH_FILES :=

$(PRODUCT_OUT)/u-boot.itb: $(BL_PREBUILT)/u-boot-release.itb
	cp $< $@
SPACEMIT_K3_FLASH_FILES += $(PRODUCT_OUT)/u-boot.itb

ifneq ($(wildcard $(BL_PREBUILT)/fw_dynamic.itb),)
$(PRODUCT_OUT)/fw_dynamic.itb: $(BL_PREBUILT)/fw_dynamic.itb
	cp $< $@
SPACEMIT_K3_FLASH_FILES += $(PRODUCT_OUT)/fw_dynamic.itb
endif

ifneq ($(wildcard $(BL_PREBUILT)/env-release.bin),)
$(PRODUCT_OUT)/env.bin: $(BL_PREBUILT)/env-release.bin
	cp $< $@
SPACEMIT_K3_FLASH_FILES += $(PRODUCT_OUT)/env.bin
endif

ifneq ($(wildcard $(BL_PREBUILT)/factory/FSBL.bin),)
$(PRODUCT_OUT)/factory/FSBL.bin: $(BL_PREBUILT)/factory/FSBL.bin
	mkdir -p $(dir $@)
	cp $< $@
SPACEMIT_K3_FLASH_FILES += $(PRODUCT_OUT)/factory/FSBL.bin
endif

ifneq ($(wildcard $(BL_PREBUILT)/partition_android.json),)
$(PRODUCT_OUT)/partition_android.json: $(BL_PREBUILT)/partition_android.json
	cp $< $@
SPACEMIT_K3_FLASH_FILES += $(PRODUCT_OUT)/partition_android.json
endif

droidcore: $(SPACEMIT_K3_FLASH_FILES)

endif # u-boot-release.itb exists

endif # TARGET_DEVICE == k3
