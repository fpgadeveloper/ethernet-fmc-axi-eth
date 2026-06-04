# Yocto / EDF builds

This folder builds Linux images for the AXI Ethernet reference designs using the
AMD Yocto / Embedded Development Framework (EDF) flow — the announced successor
to PetaLinux Tools.

## How it works: the parse-sdt flow

The build generates a **custom Yocto MACHINE directly from the Vivado XSA** —
there is no dependency on an AMD-provided machine config. This is what lets the
design serve any board (including third-party boards with no AMD machine, like
the Avnet UltraZed-EV) and lets a customer change the PS in Vivado and have it
flow through automatically:

```
XSA  --sdtgen-->  System Device Tree  --gen-machineconf parse-sdt-->  MACHINE + DTS
```

`scripts/configure-build.sh` runs `xsct`/`sdtgen` on the XSA to produce a System
Device Tree (which includes `pl.dtsi`, the PL hardware extracted from the
design), then runs `gen-machineconf parse-sdt` to emit
`conf/machine/axieth-<target>.conf` plus the lopper-generated per-domain device
trees. The PL **AXI Ethernet cores** therefore come from the design's own SDT —
no hand-curated PL device tree. Because no PL overlay is requested, the Vivado
bitstream is embedded into `BOOT.BIN` (the FSBL programs the PL at boot).

The external Ethernet PHYs, however, live off-chip on the Ethernet FMC and are
**not** in the XSA, so two small hand-written device-tree files are layered on
top of the generated tree:

* **`bsp/<board>/…/system-user.dtsi`** — SoC-side board quirks (see "Per-board
  fixups").
* **`bsp/port-configs/<ports-*>/…/port-config.dtsi`** — the per-target AXI
  Ethernet PHY wiring (see "Port-config overlays").

## Prerequisites

Host packages on Ubuntu 22.04 / 24.04:

```
sudo apt-get install repo gawk wget git diffstat unzip texinfo gcc \
    build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 \
    python3-subunit zstd liblz4-tool file locales libacl1 bmap-tools
```

Plus Vivado 2025.2 (used to produce the XSA this flow consumes).
**Vitis 2025.2 must also be sourced** in the shell that runs `make`, because
`sdtgen`/`xsct` (used to turn the XSA into a System Device Tree) ship with
Vitis, not Vivado, in 2025.2:

```
source <xilinx-install>/2025.2/Vivado/settings64.sh
source <xilinx-install>/2025.2/Vitis/settings64.sh
```

## Build

```
cd Yocto
make yocto TARGET=zcu102_hpc0      # or any target listed by `make help`
```

The first build for a target:

1. Builds the Vivado project and exports the XSA (via `../Vivado/Makefile`) if
   one isn't already present.
2. Initializes a manifest workspace under `Yocto/<TARGET>/` with
   `repo init -u https://github.com/Xilinx/yocto-manifests.git -b rel-v2025.2 -m default-edf.xml`
   and `repo sync` (≈5 GB of git history).
3. Sources `edf-init-build-env` to set up the bitbake environment.
4. Generates the System Device Tree from the XSA and runs
   `gen-machineconf parse-sdt` to create `MACHINE = "axieth-<target>"`.
5. Layers `bsp/<board>/conf/local.conf.append` (hostname, kernel cmdline) and
   `bsp/<board>/meta-user/` (kernel config, `system-user.dtsi` board fixups,
   image bbappend) over the EDF default config, plus — when the target has a
   port config — the `bsp/port-configs/<ports-*>/meta-user/` overlay layer.
6. Runs `bitbake edf-linux-disk-image`.
7. Gathers `BOOT.BIN` (with the PL bitstream embedded), `uImage`/`Image`,
   `system.dtb`, `boot.scr`, `rootfs.tar.gz`, `rootfs.wic.xz`, and
   `rootfs.wic.bmap` into `Yocto/<TARGET>/images/linux/`.

Subsequent builds skip `repo sync`. To force a re-config (e.g. after editing
`bsp/<board>/conf/local.conf.append`), remove `Yocto/<TARGET>/configdone.txt`.

`make all` builds every target; `make status_all` reports which are built.

## Port-config overlays (`port-config.dtsi`)

The external Ethernet-FMC PHYs are board knowledge the XSA does not carry, and
the set of active ports differs per target (a four-port design vs. the two-port
`zcu102_hpc1`). Two targets can share one board BSP (e.g. `zcu102_hpc0` and
`zcu102_hpc1` both use `bsp/zcu102`) but need *different* PHY wiring, so the
wiring is factored into per-config overlay **layers** rather than into the board
BSP:

```
bsp/port-configs/
  ports-0123/meta-user/   four-port designs  (axi_ethernet_0..3)
  ports-01--/meta-user/   two-port designs   (axi_ethernet_0..1, e.g. zcu102_hpc1)
```

Each overlay is a small Yocto layer whose `device-tree.bbappend` adds its
`port-config.dtsi` to the Linux device tree via `EXTRA_DT_INCLUDE_FILES`. Which
overlay applies is selected per target by the **second field** of the target's
Yocto Makefile line (e.g. `zcu102_hpc1_target := zynqMP ports-01--`):
`configure-build.sh` adds `bsp/port-configs/<that-config>/meta-user` to
`bblayers.conf` alongside the board layer. A repo/target with no port config
(empty second field) simply gets no overlay — the mechanism is a no-op there, so
the Makefile and scripts stay identical across repos.

`port-config.dtsi` sets, for each active port, the `local-mac-address`,
`phy-handle`, `xlnx,has-mdio`, `phy-mode = "rgmii-rxid"` and the MDIO `phy@0`
child on the `&axi_ethernet_N` node (the node itself comes from the SDT's
`pl.dtsi`).

## Per-board fixups (`system-user.dtsi`)

Each board's `bsp/<board>/meta-user/recipes-bsp/device-tree/files/system-user.dtsi`
is layered onto the generated Linux device tree (via `EXTRA_DT_INCLUDE_FILES`,
guarded so it only applies to the Linux domain DT — the FSBL/PMU domain DTs
don't define the SoC peripheral labels). It contains only SoC-side board quirks,
not PL hardware or PHY wiring (that's the port-config overlay):

* **Zynq-7000 boards (`pz`, `zc702`, `zc706`, `zedboard`)** carry an identical
  set of SoC-side fixups, because the board-specific PS config comes from each
  target's XSA via parse-sdt:
  * `compatible = "xlnx,zynq-7000"` — the parse-sdt/lopper board merge overwrites
    the root `compatible` with only the board string and drops the SoC-family
    string. Without it the kernel falls back to the generic ARM machine,
    `zynq_early_slcr_init()` never runs, and the clock PLL setup NULL-derefs →
    panic during `of_clk_init`.
  * `/chosen/bootargs` — the Zynq-7000 EDF boot.scr reads bootargs from the
    device tree and only appends `root=`; parse-sdt emits none, so without this
    the kernel boots with no console and appears to hang. Sets
    `console=ttyPS0,115200` and `cma=256M`.
  * `&gem0 { status = "disabled"; }` — the design uses the PL AXI Ethernet
    cores, not the PS GEM; the 2025.x U-Boot data-aborts probing a `gem0` left
    without a PHY handle by `pcw.dtsi`.
* **UART mapping (`zcu102`, `uzev`)**: the 2025.2 flow leaves `port-number = <0>`
  on both `uart0` and `uart1`, so the `ttyPS0`/`ttyPS1` mapping is left to probe
  order. These boards pin the port numbers and serial aliases so the console
  (cabled to UART0) is deterministic.
* **`uzev` only**: the Avnet UltraZed-EV is a third-party SOM+carrier, so its
  `system-user.dtsi` is larger — external GTR reference clocks + `&psgtr` mapping
  (for the PS-GTR-routed SATA/USB3), the on-SOM `gem3` PHY (with its MAC read
  from the board EEPROM via `nvmem-cells`), the I2C power/clock/EEPROM tree,
  eMMC, QSPI and SATA. It is ported from the proven PetaLinux `uzev` BSP.

Kernel config fragments live in
`bsp/<board>/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg`:

* **All boards**: `CONFIG_XILINX_GMII2RGMII`, `CONFIG_MVMDIO`,
  `CONFIG_MARVELL_PHY` (plus `CONFIG_AMD_PHY`, `CONFIG_XILINX_PHY` on z7) — the
  GMII-to-RGMII shim and PHY drivers the AXI Ethernet ports use.
* **Zynq UltraScale+**: `CONFIG_XILINX_DMA_ENGINES`, `CONFIG_XILINX_DPDMA`,
  `CONFIG_XILINX_ZYNQMP_DMA`.
* **Zynq-7000**: `CONFIG_NFSD` / `CONFIG_NFSD_V4` — the z7 (arm) kernel defconfig
  omits NFSD (the zynqMP aarch64 defconfig has it), so without this the
  `nfs-utils` server / `proc-fs-nfsd.mount` fails at boot. Non-fatal, but enabled
  for parity.

## Flashing to SD card

The build produces a full wic disk image (`rootfs.wic.xz`). Flash it to the SD
card's raw device; per-partition file copies do **not** work because the boot
script boots from the device it finds itself on.

The EDF wks uses a 4-partition layout (`esp` (vfat), `boot` (ext4), `root`
(ext4), `storage` (vfat)). It leaves the `esp` partition empty and installs
`BOOT.BIN` onto the ext4 `boot` partition (which the BootROM cannot read). The
BootROM reads `BOOT.BIN` from the first FAT partition (`esp`), so after flashing
you must drop `BOOT.BIN` onto `esp` by hand.

### 1. Identify the SD card device — carefully

`dd`-style writes to a block device cannot be undone. With the SD card
**un**plugged, run `lsblk -o NAME,SIZE,RM,TYPE,MOUNTPOINT`; insert the card and
re-run it. The new entry (typically `/dev/sdX`, `RM=1`, size matching your card)
is your target. Confirm with
`udevadm info --query=property --name=/dev/sdX | grep -E "ID_BUS|ID_MODEL"`
(`ID_BUS=usb`). **Do not proceed until you are certain `/dev/sdX` is your SD card
and not an internal disk.**

### 2. Unmount any auto-mounted partitions

```
for p in /dev/sdX?*; do sudo umount "$p" 2>/dev/null; done
```

### 3. Flash the wic image to the raw device

```
sudo bmaptool copy \
    --bmap Yocto/<TARGET>/images/linux/rootfs.wic.bmap \
          Yocto/<TARGET>/images/linux/rootfs.wic.xz \
          /dev/sdX
```

Fallback (slower): `xzcat …/rootfs.wic.xz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync`.

### 4. Install BOOT.BIN on the esp partition

```
sudo partprobe /dev/sdX
sudo mkdir -p /mnt/sd_esp
sudo mount /dev/sdX1 /mnt/sd_esp
sudo cp Yocto/<TARGET>/images/linux/BOOT.BIN /mnt/sd_esp/BOOT.BIN
sync
sudo umount /mnt/sd_esp && sudo rmdir /mnt/sd_esp
```

### 5. Eject and boot

Eject the card cleanly (`sudo eject /dev/sdX`) so pending writes flush. Insert it
into the board, set the boot-mode switches to SD (see
[Boot PetaLinux](../docs/source/petalinux.md) for the per-board switch settings),
power-cycle, and attach a UART terminal at 115200 8N1.

> On `uzev` the on-SOM eMMC enumerates as `mmcblk0` and the SD card as
> `mmcblk1`; the boot script's dynamic `root=` handles this (rootfs mounts on
> `mmcblk1p3`). On the Zynq-7000 boards the SD card is `mmcblk0` (rootfs on
> `mmcblk0p3`).

## Offline / faster builds

Place the absolute path to a directory containing an extracted AMD sstate-cache
mirror in `Yocto/offline.txt` — `configure-build.sh` auto-detects which
architecture subdirs exist under it and wires one `SSTATE_MIRRORS` entry per
arch (plus `SOURCE_MIRROR_URL` if a `downloads/` dir is present).

Expected layout under that path:

```
<sstate root>/
  aarch64/      (Zynq UltraScale+ Linux)
  arm/          (Zynq-7000 Linux)
  microblaze/   (the ZynqMP PMU firmware multiconfig)
  downloads/    (optional — the source-mirror tarballs)
```

The sstate-cache and downloads archives are available behind login at the AMD
Embedded Design Tools download page under "sstate-cache & Downloads - 2025.2".

## Layout

```
Yocto/
  Makefile                  driver, mirrors PetaLinux/Makefile conventions
  README.md                 this file
  .gitignore                excludes per-target workspaces + local state
  offline.txt               (optional, gitignored) path to an extracted sstate mirror
  scripts/
    init-workspace.sh       repo init + sync
    configure-build.sh      sdtgen + gen-machineconf parse-sdt + apply BSP (+ overlay) + sstate
    build-image.sh          bitbake the image recipe
    package-output.sh       gather deploy artifacts into images/linux/
  bsp/
    <board>/                one per board (zcu102 is shared by hpc0 + hpc1)
      conf/local.conf.append   board overrides (hostname, kernel cmdline)
      meta-user/               Yocto layer: kernel cfg, system-user.dtsi, image bbappend
    port-configs/
      ports-0123/, ports-01--/ per-target AXI Ethernet PHY overlay layers
  <TARGET>/                 (gitignored) per-target workspace built by make
  logs/                     (gitignored) build logs
```

## Architectural notes

* **The Makefile and the four scripts are universal** — identical across all of
  our reference repos. The only per-repo content lives between the
  `# UPDATER START` / `# UPDATER END` markers in the Makefile, which
  `config/update.py` generates from `config/data.json` (the target list,
  `BD_NAME`, and each target's `<template> [<port-config>]`).

* **The MACHINE is generated from the XSA** by `gen-machineconf parse-sdt` (the
  flow AMD recommends; `parse-xsa` is deprecated). There is no pinned
  AMD-validated MACHINE and no per-target flow selection. The custom machine is
  named `${BD_NAME}-<target>` (i.e. `axieth-<target>`); `configure-build.sh`
  takes `BD_NAME` as an argument so the script stays repo-agnostic.

* **The bitstream lives in BOOT.BIN**, not loaded at runtime via FPGA manager.
  Because no PL overlay is requested, the bitstream `sdtgen` extracted from the
  XSA is embedded into `BOOT.BIN` and the FSBL programs the PL during boot.

* **`system-user.dtsi` and `port-config.dtsi` are scoped to the Linux device
  tree** (via a guard on `CONFIG_DTFILE`). The FSBL and PMU domain device-trees
  don't define the SoC peripheral / `axi_ethernet` labels the overrides
  reference, so including them there makes `dtc` fail with "Label or path …
  not found".

* **Adding a target**: set `"yocto": true` for the design in `config/data.json`
  and run `config/update.py` (regenerates the Makefile target list and the README
  table), then create `bsp/<board>/` following an existing board (start from
  `zcu102` for a stock AMD ZynqMP board, `zc706` for Zynq-7000, or `uzev` for a
  board needing a rich `system-user.dtsi`). If the target uses a port count not
  already covered, add a `bsp/port-configs/<ports-XXXX>/` overlay.
```
