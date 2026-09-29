#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# First: replacements of AOSP default files (PRODUCT_COPY_FILES is first-wins)
$(call inherit-product, device/spacemit/common/early-overrides.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, device/spacemit/k3/device.mk)

PRODUCT_NAME := aosp_bananapi_sm10
PRODUCT_DEVICE := k3
PRODUCT_BRAND := BananaPi
PRODUCT_MODEL := BananaPi SM10 RISC V
PRODUCT_MANUFACTURER := Sinovoip
