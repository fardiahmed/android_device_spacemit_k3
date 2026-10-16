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
# Needs Wi-Fi Direct: not validated yet on the RTL8852BE (rtw89).
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

# K3 firmware: GPU (BXM-4-64), RTL8852BE Wi-Fi and Bluetooth.
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

# Audio. By default the SM10 carrier has no codec, so the primary output (the policy's
# "Speaker") and the HDMI path both play on the DisplayPort card (matched by name "DP1").
# With the Waveshare WM8960 Audio HAT attached, set SPACEMIT_WM8960_HAT=true: the WM8960
# simple-card ("snd-wm8960") becomes the primary speaker/headphone/mic, DP stays the HDMI
# path. The HAT's DT + kernel codec live in the K3 kernel (k3-bananapi-sm10.dts).
SPACEMIT_WM8960_HAT ?= false
ifeq ($(SPACEMIT_WM8960_HAT),true)
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.audio.primary.card_name=wm8960 \
    persist.vendor.audio.primary.device=0 \
    persist.vendor.audio.hdmi.card_name=DP1
# sh_vendor provides /vendor/bin/sh for the one-shot WM8960 routing setup.
PRODUCT_PACKAGES += sh_vendor
PRODUCT_COPY_FILES += \
    device/spacemit/k3/audio/mixer_controls.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_controls.xml \
    device/spacemit/k3/audio/wm8960_setup.sh:$(TARGET_COPY_OUT_VENDOR)/etc/wm8960_setup.sh \
    device/spacemit/k3/audio/init.wm8960.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.wm8960.rc
else
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.audio.primary.card_name=DP1 \
    persist.vendor.audio.primary.device=0 \
    persist.vendor.audio.hdmi.card_name=DP1
PRODUCT_COPY_FILES += \
    hardware/baylibre/audio/mixer_controls.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_controls.xml
endif

# Fstab (UFS)
PRODUCT_PACKAGES += \
    fstab.k3 \
    fstab.k3.vendor_ramdisk

# Init
PRODUCT_COPY_FILES += \
    device/spacemit/k3/init.k3.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.k3.rc \
    device/spacemit/k3/init.k3.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.k3.usb.rc \
    device/spacemit/k3/ueventd.k3.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Wi-Fi + Bluetooth: RTL8852BE M.2 module, in-kernel rtw89 (PCIe) and btusb; AOSP Wi-Fi HAL
# (nl80211, no vendor library) and the HCI-socket Bluetooth HAL.
PRODUCT_PACKAGES += \
    com.android.hardware.wifi \
    com.spacemit.hardware.wpa_supplicant.k3 \
    android.hardware.bluetooth-service.default

PRODUCT_VENDOR_PROPERTIES += \
    wifi.interface=wlan0

# Soong namespace of this directory (fstab)
PRODUCT_SOONG_NAMESPACES += \
    device/spacemit/k3

# Optional features (SPACEMIT_*): must come last, after the settings above.
$(call inherit-product, device/spacemit/common/spacemit-features.mk)
