#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Tablet build for BananaPi BPI-SM10 (K3-CoM260 module on its carrier board)

# First: replacements of AOSP default files (PRODUCT_COPY_FILES is first-wins)
$(call inherit-product, device/spacemit/common/early-overrides.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, device/spacemit/k3/device.mk)

# Tablet characteristics
PRODUCT_CHARACTERISTICS := tablet

# Product identification
PRODUCT_NAME := aosp_bananapi_sm10_tablet
PRODUCT_DEVICE := k3
PRODUCT_BRAND := BananaPi
PRODUCT_MODEL := BananaPi SM10 Tablet RISC V
PRODUCT_MANUFACTURER := Sinovoip

# Tablet packages
PRODUCT_PACKAGES += \
    Launcher3QuickStep
