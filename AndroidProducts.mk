#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/bananapi_sm10/aosp_bananapi_sm10.mk \
    $(LOCAL_DIR)/bananapi_sm10/aosp_bananapi_sm10_tablet.mk

COMMON_LUNCH_CHOICES := \
    aosp_bananapi_sm10-trunk_staging-userdebug \
    aosp_bananapi_sm10-trunk_staging-eng \
    aosp_bananapi_sm10_tablet-trunk_staging-userdebug \
    aosp_bananapi_sm10_tablet-trunk_staging-eng
