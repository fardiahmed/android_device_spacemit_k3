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

# BROM boot descriptors and the SPI-NOR layout (bootloader on the module NOR)
define spacemit-k3-bootinfo
$(PRODUCT_OUT)/factory/bootinfo_$(1).bin: $(BL_PREBUILT)/factory/bootinfo_$(1).bin
	mkdir -p $$(dir $$@)
	cp $$< $$@
SPACEMIT_K3_FLASH_FILES += $(PRODUCT_OUT)/factory/bootinfo_$(1).bin
endef
$(foreach b,spinor spinand block,$(if $(wildcard $(BL_PREBUILT)/factory/bootinfo_$(b).bin),\
    $(eval $(call spacemit-k3-bootinfo,$(b)))))

ifneq ($(wildcard $(BL_PREBUILT)/partition_nor.json),)
$(PRODUCT_OUT)/partition_nor.json: $(BL_PREBUILT)/partition_nor.json
	cp $< $@
SPACEMIT_K3_FLASH_FILES += $(PRODUCT_OUT)/partition_nor.json
endif

$(PRODUCT_OUT)/flash_bpi_sm10.sh: device/spacemit/k3/flash_bpi_sm10.sh
	cp $< $@
	chmod +x $@
SPACEMIT_K3_FLASH_FILES += $(PRODUCT_OUT)/flash_bpi_sm10.sh

droidcore: $(SPACEMIT_K3_FLASH_FILES)

endif # u-boot-release.itb exists

endif # TARGET_DEVICE == k3
