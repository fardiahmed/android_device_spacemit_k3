#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit common configuration
include device/spacemit/common/BoardConfigCommon.mk

# Platform
TARGET_BOARD_PLATFORM := k3
TARGET_BOOTLOADER_BOARD_NAME := k3

# CPU: SpacemiT X100 (RVA23); no x100 arch variant yet, generic riscv64 flags.
TARGET_ARCH_VARIANT :=

# Kernel: same KERNEL_RISCV tree as the K1; dist of the Kleaf bananapi_sm10 target.
TARGET_KERNEL_USE ?= mainline
KERNEL_MODULES_PATH := device/spacemit/k3-kernel/$(TARGET_KERNEL_USE)

TARGET_PREBUILT_KERNEL := $(KERNEL_MODULES_PATH)/Image

# Kernel modules: same load-order constraints as the K1.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(KERNEL_MODULES_PATH)/ramdisk/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    $(filter %/spacemit-ccu.ko,$(BOARD_VENDOR_RAMDISK_KERNEL_MODULES)) \
    $(filter-out %/spacemit-ccu.ko,$(BOARD_VENDOR_RAMDISK_KERNEL_MODULES))

BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(KERNEL_MODULES_PATH)/vendor_dlkm/*.ko)
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(filter %/phy_package.ko %/realtek.ko,$(BOARD_VENDOR_KERNEL_MODULES)) \
    $(filter-out %/phy_package.ko %/realtek.ko,$(BOARD_VENDOR_KERNEL_MODULES))
BOARD_SYSTEM_KERNEL_MODULES := $(wildcard $(KERNEL_MODULES_PATH)/system_dlkm/*.ko)
BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(BOARD_SYSTEM_KERNEL_MODULES)

# Boot storage: UFS on the K3-CoM260 (soc/c0e00000.ufshc).
BOARD_BOOTCONFIG += androidboot.hardware=k3
BOARD_BOOTCONFIG += androidboot.boot_devices=soc/c0e00000.ufshc
BOARD_BOOTCONFIG += androidboot.fstab_suffix=k3
BOARD_BOOTCONFIG += androidboot.selinux=permissive

# Partition sizes: same layout as the K1 for now; revisit with the K3 partition table
# (vendor/spacemit/k3/bootloader/partition_android.json) -- UFS is 128/256 GB.
BOARD_SUPER_PARTITION_SIZE := 4831838208
BOARD_SPACEMIT_DYNAMIC_PARTITIONS_SIZE := 2411724800
BOARD_USERDATAIMAGE_PARTITION_SIZE := 10662837248

# Wi-Fi / Bluetooth: TODO once the SM10 module's chip is known (see device/spacemit/k1).

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += device/spacemit/k3/sepolicy/vendor

# Recovery. The K1's librecovery_ui_k1 (Ethernet fastboot UI, power-key-only navigation) is
# board-specific; the K3 uses the stock recovery UI until the SM10 keys are known.
TARGET_RECOVERY_FSTAB_GENRULE := gen_fstab_k3

# VINTF
DEVICE_MANIFEST_FILE := device/spacemit/k3/manifest.xml
