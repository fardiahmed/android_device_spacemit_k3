#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# SpacemiT K3: BananaPi BPI-SM10. Same kernel tree as the K1; configuration only,
# not booted yet (see README.md).

# Features the K3/SM10 cannot support (yet), forced off before spacemit-features.mk.
# No HDMI on the K3 (eDP/DP only).
SPACEMIT_HDMI_CEC := false
# Needs Wi-Fi Direct; the SM10 Wi-Fi chip is not identified yet.
SPACEMIT_WFD_SINK := false
# The llama.cpp build targets the K1 IME instructions.
SPACEMIT_LLM := false
# The sensors setup follows the BPI-F3 header I2C4 wiring.
SPACEMIT_SENSORS := false
SPACEMIT_AUTO_ROTATE := false
# For the BPI-F3 ES8326 built-in mics.
SPACEMIT_MIC_TEST := false
# No OP-TEE port (bootloader sources) for the K3 yet.
SPACEMIT_OPTEE := false

# X100 cores have the H extension: AVF on.
SPACEMIT_AVF_ENABLED := true

# Inherit common
$(call inherit-product, device/spacemit/common/device-common.mk)

# K3 firmware (BXM-4-64 GPU BVNC, VPU, Wi-Fi) from the K3 BSP, once available.
$(call inherit-product-if-exists, vendor/spacemit/k3/k3.mk)

# Platform
PRODUCT_PLATFORM := k3

# Kernel: same KERNEL_RISCV tree as the K1, dist of the Kleaf bananapi_sm10 target.
TARGET_KERNEL_USE ?= mainline
LOCAL_KERNEL := device/spacemit/k3-kernel/$(TARGET_KERNEL_USE)/Image

PRODUCT_COPY_FILES += \
    $(LOCAL_KERNEL):kernel

# Properties (see device/spacemit/k1/device.mk).
PRODUCT_PROPERTY_OVERRIDES += \
    ro.minui.pixel_format=RGBX_8888 \
    ro.recovery.ui.long_press_ms=2000 \
    ro.hardware.gralloc=minigbm \
    sys.usb.configfs=1 \
    vendor.thermal.hardware=spacemit \
    ro.vendor.boot_security_patch=2025-01-05 \
    config.disable_renderscript=true \
    ro.vendor.hwc.use_overlay_planes=true \
    ro.sf.lcd_density=240

# Audio HAL mixer control names: BayLibre's generic list until the SM10 codec is known (a board
# file replaces it, like device/spacemit/k1/audio/mixer_controls.xml for the F3's ES8326).
PRODUCT_COPY_FILES += \
    hardware/baylibre/audio/mixer_controls.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_controls.xml

# Fstab (UFS)
PRODUCT_PACKAGES += \
    fstab.k3 \
    fstab.k3.vendor_ramdisk

# Init
PRODUCT_COPY_FILES += \
    device/spacemit/k3/init.k3.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.k3.rc \
    device/spacemit/k3/init.k3.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.k3.usb.rc \
    device/spacemit/k3/ueventd.k3.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Wi-Fi / Bluetooth: TODO once the SM10 module's chip is known (on the K1 this is the Realtek
# 8852bs HAL in vendor/spacemit/hardware/wifi + supplicant APEX from device/spacemit/k1/wifi).

# Soong namespace of this directory (fstab)
PRODUCT_SOONG_NAMESPACES += \
    device/spacemit/k3

# Optional features (SPACEMIT_*): must come last, after the settings above.
$(call inherit-product, device/spacemit/common/spacemit-features.mk)
