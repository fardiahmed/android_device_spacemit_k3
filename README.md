# BananaPi BPI-SM10 (SpacemiT K3) — Android 16

Status: **build configuration only, not booted** (no board yet). The kernel dist, fstab,
sepolicy and DTB image build; everything that depends on the SM10 carrier board is a placeholder.

## Layout

| Path | What |
|---|---|
| `device/spacemit/common/` | Shared by K1 and K3: `device-common.mk`, `spacemit-features.mk` (feature flags), `BoardConfigCommon.mk`, audio APEX/policy, overlays, shared sepolicy |
| `device/spacemit/k1/` | BananaPi F3 (K1): HDMI-CEC, Realtek 8852bs Wi-Fi and recovery UI configuration, eMMC fstab, F3 bootloader |
| `device/spacemit/k3/` | BananaPi SM10 (K3): this directory |
| `device/spacemit/k3-kernel/mainline/` | Kernel dist (Image, `k3-*.dtb`, `ramdisk/`, `vendor_dlkm/`, `system_dlkm/` modules) |
| `vendor/spacemit/hardware/` | HALs and prebuilts, one repository each: `mesa` (PowerVR Vulkan + Zink), `codec2` (VPU), `hdmi` (CEC), `wifi` (8852bs), `recovery` (UI), `sensors` |
| `vendor/spacemit/apps/`, `vendor/spacemit/ai/llama` | Apps (WfdSink, MicTest, AiChat, ExoPlayer) and the on-device LLM |

## Build

```
./build.sh k3                     # kernel (kernel/spacemit) + Android images
./build.sh k3 -p aosp_bananapi_sm10
```

Kernel — same tree as the K1, its own Kleaf target `//devices/spacemit/bananapi_sm10:spacemit_k3_dist`,
staged into `device/spacemit/k3-kernel/mainline` (not versioned). There are no K3 bootloader sources yet.

Config = `gki_defconfig` + `bananapi_f3/spacemit_k1x.fragment` (shared settings) +
`bananapi_sm10/spacemit_k3.fragment` (K3 drivers). The K3 VPU module is `amvx_k3.ko` (the K1 one
is `amvx.ko`; both are built by the shared config).

## Features (`SPACEMIT_*`, defaults in common/spacemit-features.mk)

| Flag | K3 | Why |
|---|---|---|
| `SPACEMIT_HW_CODEC2` | on | Same Linlon-V5 VPU as the K1 (all v4l2_codec2 fixes apply) |
| `SPACEMIT_EXOPLAYER`, `SPACEMIT_MICROG` | on | |
| `SPACEMIT_AVF_ENABLED` | **on** | X100 cores have RVH 1.0 → `/dev/kvm`, crosvm (non-protected VMs; no riscv64 pvmfw upstream) |
| `SPACEMIT_HDMI_CEC` | off | No HDMI on the K3 (eDP/DP only) |
| `SPACEMIT_WFD_SINK` | off | Needs Wi-Fi Direct, not validated yet on the RTL8852BE (rtw89) |
| `SPACEMIT_LLM` | off | llama.cpp build targets the K1 IME instructions; A100 AI cores need a port |
| `SPACEMIT_SENSORS`, `SPACEMIT_AUTO_ROTATE` | off | HAL/sepolicy/init follow the F3 header I2C4 wiring |
| `SPACEMIT_MIC_TEST` | off | F3 ES8326 built-in mics |
| `SPACEMIT_OPTEE` | off | No OP-TEE port (bootloader sources) for the K3 yet: software KeyMint/Gatekeeper |

Forced off with `:=` in `device.mk` (before `spacemit-features.mk` is inherited); turn one on
there once the hardware support exists.

## Bring-up TODO (board arriving; BPI-SM10 = K3-CoM260 module on the CoM260 kit V02 carrier)

Hardware: UFS boot, SD, DisplayPort 1.2 + MIPI DSI, USB-C OTG (FUSB301) + VL817 4x USB 3.0 hub,
RTL8211F Gigabit Ethernet, RTL8852BE M.2 (PCIe Wi-Fi, USB Bluetooth), 2x M.2 M-key, CAN-FD,
**no audio codec** (audio over DP, USB or Bluetooth only). Console: UART0 on the 12-pin debug
header (pin 3 RX, 4 TX), 115200. Download mode: hold FC_REC at power-on, USB-C to the host.
Schematic/BOM: cdn-resource.spacemit.com/file/product/K3/k3_com260_hw/.

Base: BayLibre's K3 Pico-ITX BSP (same SoC, sister Banana Pi board), ported to Android 16.

1. **Board DTS**: done, `k3-bananapi-sm10.dts` + `k3-com260.dtsi` in the kernel tree (from the
   SpacemiT linux-6.18 BSP `k3_com260_kit_v02.dts`), DP audio on. Missing: x4 M.2 on PCIe
   port A (two PHYs per controller), CTF2301 fan, power button, DSI panel, cameras.
2. **GPU firmware**: done, BXM-4-64 `rogue_36.56.104.183_v1.fw` in `vendor/spacemit/k3`.
3. **VPU firmware**: none needed so far (the BayLibre Pico-ITX BSP ships none for the K3).
4. **Bootloader**: done, BayLibre's U-Boot 2026.07 K3 port + the SM10 board
   (`bootloader/spacemit/k3-u-boot`) and K3 OpenSBI, built by `./build.sh k3` into
   `vendor/spacemit/k3/bootloader`, on the module SPI-NOR. To confirm on the board: the boot
   strap really selects the NOR (else the SPL needs UFS loading).
5. **Flashing**: `flash_bpi_sm10.sh` (BayLibre's Pico-ITX flasher): bootloader to NOR, GPT from
   the U-Boot `partitions` env, Android to UFS. Not validated.
6. **USB gadget**: `init.k3.usb.rc` uses `cad00000.usb3` (USB3 port A, the USB-C port); confirm
   with `ls /sys/class/udc`.
7. **Wi-Fi/BT**: done, RTL8852BE through rtw89 + btusb, AOSP Wi-Fi HAL (no vendor library),
   supplicant APEX `com.spacemit.hardware.wpa_supplicant.k3`, HCI-socket Bluetooth HAL. Wi-Fi
   Direct (WfdSink) off until tested.
8. **Audio**: done, the audio HAL's primary and HDMI cards are the DP card (`DP1`); USB and
   Bluetooth audio as on the F3.

## Kernel changes made for the K3 (shared tree)

- `drivers/gpu/drm/spacemit_k3/spacemit_planes.c`: per-commit rdma assignment when userspace does
  not set `rdma_id` — only rdma1 reads raw YUV on saturn-hee; same fix as the K1 driver, where
  NV12 video otherwise always fell back to GPU composition.
- `drivers/media/platform/spacemit/vpu_k3`: module renamed `amvx_k3`; vb2 `wait_prepare/finish`
  → `q->lock`, include order, static helpers (7.1 API, as done for `vpu_k1x`).
- `drivers/thermal`: SpacemiT K3 thermal Kconfig renamed `SPACEMIT_K3_THERMAL` (clashed with the TI
  K3 symbol) + `MODULE_LICENSE`; `drivers/remoteproc/k3-rproc.c`: inline `frozen()` (not exported).
