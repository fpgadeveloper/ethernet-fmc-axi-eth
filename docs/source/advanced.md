# Advanced: project structure and customization

This section is intended for users who want to modify the reference
designs — adding IP to the block design, changing constraints, modifying
the standalone application, or adding packages or drivers to the
PetaLinux project. It describes how the repository is laid out, how the
build flow works, how the Vitis and PetaLinux sides are
organised, and what modifications have been added on top of the stock
AMD BSPs.

The actual *build* instructions are in [build_instructions](build_instructions);
this section is about understanding the project well enough to modify
it.

## Repository layout

```
.
├── build.py                   <- Cross-platform build runner (the build logic)
├── build.sh / build.bat       <- Shims that invoke build.py (Linux/git bash, Windows)
├── Makefile                   <- Deprecated thin wrapper around build.sh (removed next version)
├── README.md
├── config/                    <- Source-of-truth design metadata and auto-generation
│   ├── data.json
│   └── update.py
├── docs/                      <- This documentation (Sphinx + Read the Docs)
├── EmbeddedSw/                <- Vendored AMD BSP libraries used by the Vitis build
├── PetaLinux/
│   └── bsp/                   <- Per-board and per-port-config BSP fragments
│       ├── pz/, zc702/, …     <-   board-specific overlays
│       └── ports-0123/, ports-01--/   <- port-config overlays
└── Vivado/
│   ├── scripts/
│   │   ├── build.tcl          <- Project creation + block design assembly
│   │   └── xsa.tcl            <- Synthesis, implementation, XSA export
│   └── src/
│       ├── bd/
│       │   ├── bd_mb-7s.tcl   <- Block design for MicroBlaze on 7-series carriers
│       │   ├── bd_mb-us.tcl   <- Block design for MicroBlaze on UltraScale carriers
│       │   ├── bd_zc702-dual.tcl <- Special-case BD for ZC702 dual-FMC
│       │   ├── bd_zynq.tcl    <- Block design for Zynq-7000 targets
│       │   └── bd_zynqmp.tcl  <- Block design for Zynq UltraScale+ targets
│       └── constraints/
│           └── <target>.xdc   <- One XDC per target (pin assignments, timing)
└── Vitis/
    ├── py/
    │   ├── args.json          <- Repo-specific Vitis flow configuration
    │   ├── build-vitis.py     <- Universal Vitis Python build driver
    │   ├── make-boot.py       <- BOOT.BIN / .mcs packaging
    │   ├── pre_build.py       <- Per-build hook (e.g. constants generation)
    │   └── pre_platform_build.py
    ├── common/
    │   └── src/               <- Standalone application source (echo_server)
    └── <target>_workspace/    <- Per-target Vitis workspace (generated)
```

Per-target build outputs are written to `Vivado/<target>/`,
`Vitis/<target>_workspace/`, and `PetaLinux/<target>/`; packaged
boot-image zips are written to `bootimages/`. None of these are
committed.

## Target naming

A *target label* is the canonical handle for a single design and is passed
to every build command via `--target`. It encodes the board and, for
boards with multiple FMC connectors, the connector:

```
<board>[_<connector>]
```

Examples: `zedboard`, `zcu102_hpc0`, `kc705_hpc`, `zc702_lpc2`,
`vc707_hpc2_hpc1` (the dual-FMC variant). The first
underscore-delimited token is taken as the *target board* and is what
the build runner uses to select the BSP under
`PetaLinux/bsp/<board>/` or `Yocto/bsp/<board>/` respectively.

The complete list of valid targets comes from `config/data.json`; run
`./build.sh list` (or `./build.sh labels` for one per line) to print it.

## `config/data.json` and `config/update.py`

`config/data.json` is the canonical source of truth for the set of
supported designs and their per-target metadata (board name, processor
family, FMC connector, port lane mapping, baremetal-vs-PetaLinux
support, etc.). The `build.py` runner reads it directly at runtime, so
the target list is never hand-maintained.

`config/update.py` reads `data.json` and regenerates the auto-managed
documentation and metadata that is *not* read at runtime: the target
tables in the top-level `README.md`, the `.gitignore`, and the residual
per-board section still embedded in `PetaLinux/Makefile` — each
delimited by `UPDATER START` / `UPDATER END` comment markers.

When adding or modifying a target, edit `data.json` and re-run
`update.py`. Do not hand-edit content between the `UPDATER START` /
`UPDATER END` markers; it will be overwritten on the next regeneration.

## Build runner

All build stages are driven by the cross-platform `build.py` runner at the
root of the repository, invoked through the `build.sh` shim on Linux / git
bash or `build.bat` on Windows (identical arguments). It reads the target
list and per-target attributes straight from `config/data.json`, builds
whatever a requested stage depends on automatically, skips anything already
built, and locates and sources the AMD tools itself — so there is no need to
source the Vivado / Vitis / PetaLinux settings scripts beforehand.

The build is organised into stages, each available as a sub-command:

| Command      | Stage                                                                                          |
|--------------|------------------------------------------------------------------------------------------------|
| `project`    | Create the Vivado project (`.xpr`) and block design.                                           |
| `xsa`        | Synthesise, implement and export the hardware (`.xsa`).                                         |
| `standalone` | Create the Vitis workspace, build the baremetal app, package `BOOT.BIN` / `.mcs`.              |
| `petalinux`  | Create the PetaLinux project from the XSA, apply the BSP overlays, build and package.          |
| `yocto`      | Generate a custom MACHINE from the XSA (`gen-machineconf parse-sdt`), apply the meta-user BSP, build with bitbake and package. |
| `package`    | Gather the built boot artifacts into `bootimages/*.zip`.                                        |
| `all`        | Build every stage the target supports, then `package`.                                         |

Run `./build.sh list` to see the targets and their attributes, `./build.sh
status --target <t>` for per-stage artifact state, and `./build.sh --help`
for the full command list.

Each target is flagged in `config/data.json` for the stages it supports —
the MicroBlaze targets are baremetal-only (no PetaLinux/Yocto), the rest
support the embedded-Linux flows as well. Because each stage builds its
prerequisites first, a single `./build.sh all --target <t>` cascades the
whole pipeline:

```
./build.sh all --target t
  -> xsa         : vivado creates the project (build.tcl), then synth/impl/XSA export (xsa.tcl)
  -> standalone  : vitis builds the platform + app, packages BOOT.BIN / .mcs
  -> petalinux   : petalinux-create -> -config --get-hw-description <XSA>
                   -> copy bsp/<board>/project-spec/* and bsp/<port-config>/project-spec/*
                   -> petalinux-build -> petalinux-package
     yocto       : init-workspace (repo sync) -> configure-build (SDT + gen-machineconf parse-sdt)
                   -> build-image (bitbake edf-linux-disk-image) -> package-output
  -> package     : zip the boot files into bootimages/
```

Build a single stage on its own with `./build.sh <stage> --target <t>`; the
runner still builds any missing prerequisite stages first.

Per-target lock files (`.<target>.lock` at the repository root) prevent two
concurrent builds of the same target from clobbering each other — so two
terminals can safely both run `./build.sh all --target all`.

## Vivado side

### Block design

The block-design scripts live under `Vivado/src/bd/`, one per
processor family (with one special-case script for the dual-FMC ZC702
target):

* `bd_mb-7s.tcl`     — MicroBlaze on 7-series carriers
* `bd_mb-us.tcl`     — MicroBlaze on UltraScale carriers
* `bd_zynq.tcl`      — Zynq-7000 (PicoZed, ZC702, ZC706, ZedBoard)
* `bd_zc702-dual.tcl`— ZC702 with both LPC and LPC2 connectors active
* `bd_zynqmp.tcl`    — Zynq UltraScale+ (UltraZed-EV, ZCU102)

Each script contains per-board conditional blocks where a target needs
to deviate from the family defaults — typically for clock-source
selection, PS configuration, or AXI Ethernet placement.

After sourcing the BD script, `scripts/build.tcl` runs
`validate_bd_design -force`, which triggers parameter propagation and
fills in connection-automation rules. As a result the final
implemented design may contain nets that aren't visible in the BD TCL
source — to see the actual netlist as built, inspect the saved `.bd`
file under `Vivado/<target>/<target>.srcs/sources_1/bd/<bd_name>/` or
use `write_bd_tcl` to export a complete script from an open project.

### Constraints

`Vivado/src/constraints/<target>.xdc` contains pin assignments and any
target-specific timing constraints. Constraints common to all targets
of a given family are not factored out — each target's XDC is
self-contained.

### Build scripts

* `Vivado/scripts/build.tcl` creates the Vivado project, adds the
  target's XDC, sources the appropriate `bd_*.tcl`, and validates the
  block design. Invoked via `./build.sh project --target <t>`.
* `Vivado/scripts/xsa.tcl` opens the existing project, runs synthesis
  and implementation, exports the XSA, and writes the bitstream into
  the implementation run directory. Invoked via `./build.sh xsa --target <t>`.

Both scripts check `XILINX_VIVADO` to confirm the installed Vivado
version matches the `version_required` constant at the top of the
file. Bumping the project to a new Vivado release means changing those
constants and re-testing — the BD TCL APIs are not stable across major
releases.

### Modifying the block design

Edit the block-design script for the appropriate processor family
directly. If the change applies only to some targets in the family,
wrap the additions in the appropriate per-board conditional block.

Once the script is edited, delete any existing per-target Vivado
project directory (`rm -rf Vivado/<target>`) and re-run the Vivado
build:

```
./build.sh xsa --target <target>
```

This re-creates the project, sources the modified BD script, runs
`validate_bd_design`, synthesises, implements, and re-exports the XSA.
Downstream Vitis / PetaLinux / boot-image steps will pick up the new
XSA on the next build.

### Adding or modifying constraints

Edit `Vivado/src/constraints/<target>.xdc` directly. If a constraint
applies to all targets in a family, it still needs to be replicated to
each target's XDC — there is no shared XDC.

## Vitis side

The standalone (baremetal) build runs the lwIP echo-server example on
the target, exercising the AXI Ethernet ports. The application source
is shared across all targets; per-target specialisation is handled by
the build driver, not by per-target source.

### Layout

```
Vitis/
├── py/
│   ├── args.json
│   ├── build-vitis.py        <- Universal Vitis Python build driver
│   ├── make-boot.py          <- BOOT.BIN / .mcs packaging
│   ├── pre_build.py          <- Hook run before each app build
│   └── pre_platform_build.py <- Hook run before each platform build
├── common/
│   └── src/                  <- Application source (echo_server)
├── boot/<target>/            <- Per-target packaged boot files (BOOT.BIN / .mcs)
└── <target>_workspace/       <- Generated Vitis workspace per target
```

### `args.json`

`Vitis/py/args.json` is the repo-specific configuration that drives the
universal `build-vitis.py` driver. The key fields are:

* `bd_name` — block-design name (`axieth`).
* `app_name` — name of the Vitis application (`echo_server`).
* `app_template` — the Vitis app template the build driver uses to
  scaffold the application (`lwip_echo_server`).
* `bsp_libs` — BSP libraries to add and configure (here: `lwip220` with
  DHCP + ACD check + an enlarged pbuf pool, and `xiltimer` with the
  interval timer enabled).
* `src` — application source mapping. `"all": "common/src"` means
  every target uses the same source directory.
* `pre_platform_build_script` / `pre_build_script` — hooks invoked at
  the appropriate point in the workspace build.

```{important}
The AXI Ethernet IPs in the block designs are configured with **Full TX/RX
checksum hardware offload** (`CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}` —
see `Vivado/src/bd/bd_*.tcl`). The lwIP BSP configuration in `args.json`
must be left consistent with that: the stock lwIP `LWIP_*_CSUM` settings
assume the hardware computes IP/TCP/UDP checksums. If you reconfigure the
AXI Ethernet IPs to *Partial* or no checksum offload, you must also update
the corresponding lwIP `bsp_libs.lwip220.config` entries — otherwise
incoming packets will fail the checksum check in software while the
hardware has already verified (and stripped) them, and outgoing packets
will go out with a zero checksum.
```

### Modifying the standalone application

Edit `Vitis/common/src/*.c` directly. The next `./build.sh standalone
--target <t>` rebuilds the application against the existing platform; if
you've changed the hardware (XSA) you'll need a fresh workspace
(`./build.sh clean --target <t> --stage standalone` first).

### Modifying BSP libraries or build hooks

Adjust the corresponding entry in `Vitis/py/args.json`. Configuration
changes propagate through the next `pre_platform_build` run. The two
hook scripts in `py/` are repo-specific Python; edit them when the
change is more elaborate than a `bsp_libs` config tweak (for example
generating a header containing platform-specific constants).

## PetaLinux side

### BSP composition

The PetaLinux project for a given target is composed at build time
from two BSP fragments copied into the target's project directory:

1. A **board BSP** at `PetaLinux/bsp/<board>/` (for example `pz/`,
   `zedboard/`, `zcu102/`). Provides board-specific kernel and U-Boot
   configuration, the system device-tree fragment for the board, and
   any board-specific patches.
2. A **port-config overlay** at `PetaLinux/bsp/<port-config>/` (one of
   `ports-0123/` or `ports-01--/`). Provides `port-config.dtsi` — the
   device-tree fragment that wires up the AXI Ethernet ports active
   on this target.

The mapping from target to (board BSP, port-config overlay) is encoded
in `PetaLinux/Makefile`'s `UPDATER` block. The last column names the
port-config overlay; the board BSP is derived from the first token of
the target name.

The two port-config variants are:

* `ports-0123` — four-port designs.
* `ports-01--` — two-port designs (currently `zcu102_hpc1`, which has
  only two FMC channels routed).

### Layout of a board BSP

```
PetaLinux/bsp/<board>/project-spec/
├── configs/
│   ├── config                <- petalinux-config: bootargs, rootfs, hostname
│   ├── rootfs_config         <- petalinux-config -c rootfs: included packages
│   ├── init-ifupdown/
│   │   └── interfaces        <- /etc/network/interfaces
│   └── busybox/
│       └── inetd.conf
└── meta-user/
    ├── conf/
    │   ├── user-rootfsconfig <- declares additional rootfs config options
    │   ├── petalinuxbsp.conf
    │   └── layer.conf
    ├── recipes-bsp/
    │   ├── device-tree/
    │   │   ├── device-tree.bbappend
    │   │   └── files/
    │   │       └── system-user.dtsi    <- board-specific DT additions
    │   └── u-boot/
    │       ├── u-boot-xlnx_%.bbappend
    │       └── files/
    │           ├── bsp.cfg             <- U-Boot Kconfig additions
    │           ├── platform-top.h      <- U-Boot platform header overrides
    │           └── *.patch             <- U-Boot source patches
    └── recipes-kernel/
        └── linux/
            ├── linux-xlnx_%.bbappend
            └── linux-xlnx/
                └── bsp.cfg             <- kernel Kconfig additions
```

### Adding a package to the root filesystem

1. Append the new option to `bsp/<board>/project-spec/configs/rootfs_config`:

   ```
   CONFIG_<package>=y
   ```

2. If the package is not in the default `petalinux-config -c rootfs`
   menu, also append a declaration line to
   `bsp/<board>/project-spec/meta-user/conf/user-rootfsconfig`.

3. If the package is not provided by an existing meta-layer, add a
   recipe under
   `bsp/<board>/project-spec/meta-user/recipes-apps/<package>/<package>.bb`.

### Adding a kernel config option

Append the option to
`bsp/<board>/project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg`:

```
CONFIG_<name>=y
```

The corresponding bbappend at `recipes-kernel/linux/linux-xlnx_%.bbappend`
registers `bsp.cfg` as a kernel configuration fragment.

### Adding a device-tree fragment

For per-board fragments, edit
`bsp/<board>/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi`.
For per-port-config fragments, edit the corresponding
`bsp/<port-config>/project-spec/meta-user/recipes-bsp/device-tree/files/port-config.dtsi`.

If you add new files, ensure they are listed in `SRC_URI:append` in
`device-tree.bbappend`.

### Adding a kernel patch or out-of-tree driver

1. Drop the patch file into
   `bsp/<board>/project-spec/meta-user/recipes-kernel/linux/linux-xlnx/`.
2. Add a line to `recipes-kernel/linux/linux-xlnx_%.bbappend`:

   ```
   SRC_URI:append = " file://<your-patch>.patch"
   ```

### Modifying U-Boot

The same pattern as the kernel, under
`bsp/<board>/project-spec/meta-user/recipes-bsp/u-boot/`. `bsp.cfg`
adds U-Boot Kconfig options; `platform-top.h` overrides the U-Boot
platform header; patches are listed in `SRC_URI:append` in
`u-boot-xlnx_%.bbappend`.

## Modifications layered on the stock BSPs

The board BSPs in this repository started as the corresponding stock
AMD reference BSPs and have been modified in the following ways. This
list is the answer to *"what would I lose if I overwrote the BSP with
the stock one?"* — it is what to re-apply if you ever do that.

### All BSPs

* **Root filesystem additions** in `configs/rootfs_config`:
  `ethtool`, `iperf3` (plus `ethtool-dev` and `ethtool-dbg` on ZynqMP).
* **Hostname / product name** set in `configs/config` via
  `CONFIG_SUBSYSTEM_HOSTNAME` and `CONFIG_SUBSYSTEM_PRODUCT`.
* **`system-user.dtsi`** includes `port-config.dtsi`. The matching
  `device-tree.bbappend` adds both files to `SRC_URI:append`.
* **Kernel configs** in `linux-xlnx/bsp.cfg`:
  `CONFIG_XILINX_GMII2RGMII`, `CONFIG_MVMDIO`, `CONFIG_MARVELL_PHY`,
  `CONFIG_AMD_PHY`, `CONFIG_XILINX_PHY`. These are needed for the
  GMII-to-RGMII shim and the on-board PHYs used by the AXI Ethernet
  ports.

### Zynq-7000 and ZynqMP BSPs

* **SD-card root filesystem** configured in `configs/config`:
  `CONFIG_SUBSYSTEM_ROOTFS_EXT4`, `CONFIG_SUBSYSTEM_SDROOT_DEV`,
  `CONFIG_SUBSYSTEM_USER_CMDLINE` with a per-board `cma=` reservation
  sized to the device's DDR:

  | BSP       | `cma=` reservation |
  |-----------|--------------------|
  | `zedboard`| `cma=256M`         |
  | `pz`      | `cma=512M`         |
  | `zc702`   | `cma=512M`         |
  | `zc706`   | `cma=512M`         |
  | `uzev`    | `cma=1536M`        |
  | `zcu102`  | `cma=1536M`        |

  These reservations back the AXI DMA buffers used by the AXI Ethernet
  Subsystem instances.
* **U-Boot patch `0001-ubifs-distroboot-support.patch`** is applied on
  the `uzev` and `zcu102` BSPs only. The patch wires up UBIFS
  distroboot support in `include/configs/xilinx_zynqmp.h` so U-Boot can
  load `boot.scr` from a UBI volume on QSPI (relevant when booting the
  ZynqMP designs from QSPI instead of SD card). The patch comes from
  the AMD/Xilinx U-Boot tree (Signed-off-by Ashok Reddy Soma).

### ZynqMP BSPs (additionally)

* **Kernel configs** in `linux-xlnx/bsp.cfg`:
  `CONFIG_XILINX_DMA_ENGINES`, `CONFIG_XILINX_DPDMA`,
  `CONFIG_XILINX_ZYNQMP_DMA`.

### UltraZed-EV (uzev) BSP

* **`CONFIG_YOCTO_MACHINE_NAME="zynqmp-generic"`** in `configs/config`
  (the UZ-EV is not a stock Xilinx eval board).
* **SD-card device set to `/dev/mmcblk1p2`** rather than the ZynqMP
  default `mmcblk0p2`.
* **`PRIMARY_SD_PSU_SD_1_SELECT=y`** to route the boot SD interface
  through PSU SD1 instead of SD0.
* **Custom `system-user.dtsi`** with UZ-EV-specific peripheral
  configuration (overwrites the file copied in from a stock UZ-EV BSP).
* **`meta-xilinx-tools/recipes-bsp/uboot-device-tree/`** overlay that
  overrides the U-Boot device tree.

### AC701 BSP

* **`CONFIG_SUBSYSTEM_MACHINE_NAME="ac701-lite"`** to use the lite
  template (saves build time and image size).

### Port-config overlays

The two overlays in `PetaLinux/bsp/ports-*/` are not derived from any
stock BSP — they exist solely to add the device-tree fragment that
wires up the AXI Ethernet ports. Each contains a single
`port-config.dtsi` (the surrounding directory structure is needed so
that Yocto picks it up via the `SRC_URI:append = " file://port-config.dtsi"`
line in `device-tree.bbappend`).

## Yocto / EDF side

In addition to PetaLinux, the repository can build Linux images with the AMD
Yocto / Embedded Development Framework (EDF) flow — the announced successor to
PetaLinux. It lives in the `Yocto/` directory and is documented end-to-end in
[`Yocto/README.md`](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/blob/master/Yocto/README.md);
this section summarises how it is organised and what is modified on top of stock.

### Yocto scripts

The Yocto / EDF flow is driven by the build runner (`./build.sh yocto`), which
runs the four scripts in `Yocto/scripts/` directly:

| Script               | Role (rough PetaLinux analogue)                                          |
|----------------------|--------------------------------------------------------------------------|
| `init-workspace.sh`  | `repo init` + `repo sync` of the AMD yocto-manifests (≈ `petalinux-create`) |
| `configure-build.sh` | XSA → System Device Tree (sdtgen) → custom MACHINE via `gen-machineconf parse-sdt` (≈ importing the XSA + `petalinux-config`) |
| `build-image.sh`     | `bitbake edf-linux-disk-image` (≈ `petalinux-build`)                     |
| `package-output.sh`  | gather the flashable artifacts into `images/linux/` (≈ `petalinux-package`) |

The four scripts are **universal** — byte-identical across all of our reference
repos. They take no repo-specific content; the build runner supplies the
per-target values it reads from `config/data.json` — the target list, `BD_NAME`,
and each target's `<template> [<port-config>]` (e.g. `zcu102_hpc1 → zynqMP
ports-01--`). For example `configure-build.sh` takes `BD_NAME` as an argument
and builds `MACHINE = "${BD_NAME}-<target>"`.

### parse-sdt: MACHINE generated from the XSA

`configure-build.sh` runs `xsct`/`sdtgen` on the target's XSA to produce a System
Device Tree, then `gen-machineconf parse-sdt` to emit a custom
`MACHINE = axieth-<target>` plus the per-domain device trees. The PL AXI Ethernet
cores come from the design's own SDT (`pl.dtsi`); the Vivado bitstream is
embedded into `BOOT.BIN` and the FSBL programs the PL at boot. There is no pinned
AMD MACHINE and no per-target flow selection.

### BSP composition

A Yocto BSP is a `meta-user` **layer** (distinct from PetaLinux's `project-spec`
tree). Each target's build layers, over the EDF default config:

1. A **board BSP** at `Yocto/bsp/<board>/` — `conf/local.conf.append` (hostname,
   kernel cmdline) plus a `meta-user/` layer (kernel `bsp.cfg`,
   `system-user.dtsi` board fixups, image bbappend). Selected by the first token
   of the target name.
2. A **port-config overlay layer** at `Yocto/bsp/port-configs/<ports-*>/` —
   selected from the target's entry in `config/data.json`, added to
   `bblayers.conf` by `configure-build.sh` alongside the board layer. It supplies
   `port-config.dtsi`, the AXI Ethernet PHY wiring (MAC, `phy-handle`, MDIO,
   `phy-mode`) the XSA does not carry. This is what lets `zcu102_hpc0` (4 ports,
   `ports-0123`) and `zcu102_hpc1` (2 ports, `ports-01--`) share `bsp/zcu102`
   while wiring different port counts. A target with no port config gets no
   overlay (no-op), so the mechanism stays universal.

Both `system-user.dtsi` and `port-config.dtsi` are added to the **Linux** device
tree via `EXTRA_DT_INCLUDE_FILES`, guarded so they only apply to the Linux-domain
DT — the FSBL/PMU domain DTs don't define the SoC / `axi_ethernet` labels, so
including them there makes `dtc` fail with "Label or path … not found".

### Modifications on the stock EDF config

* **All boards** — `bsp.cfg`: `CONFIG_XILINX_GMII2RGMII`, `CONFIG_MVMDIO`,
  `CONFIG_MARVELL_PHY` (+ `CONFIG_AMD_PHY`, `CONFIG_XILINX_PHY` on z7); rootfs:
  `ethtool`, `iperf3` and common utilities (via `edf-linux-disk-image.bbappend`).
* **Zynq-7000** (`pz`, `zc702`, `zc706`, `zedboard`) — identical SoC-side
  `system-user.dtsi`: restore `compatible = "xlnx,zynq-7000"` (the parse-sdt board
  merge drops it → kernel clock-init panic otherwise), set `/chosen/bootargs`
  (`console=ttyPS0,115200 … cma=256M`; the z7 boot.scr reads bootargs from the
  DT), and disable `&gem0` (PS GEM unused; 2025.x U-Boot data-aborts on it). The
  z7 `bsp.cfg` also adds `CONFIG_NFSD`/`CONFIG_NFSD_V4` — the arm kernel defconfig
  omits NFSD (the aarch64 one has it), so without it the NFS server fails to start
  at boot (non-fatal).
* **Zynq UltraScale+** — `bsp.cfg`: `CONFIG_XILINX_DMA_ENGINES`,
  `CONFIG_XILINX_DPDMA`, `CONFIG_XILINX_ZYNQMP_DMA`; `system-user.dtsi` pins the
  `uart0`/`uart1` `port-number` + serial aliases (the console is on UART0). `uzev`
  additionally carries the full UZ7EV carrier description (GTR clocks + `&psgtr`,
  `gem3` with MAC from the board EEPROM, the I2C tree, eMMC/QSPI/SATA), ported from
  the PetaLinux `uzev` BSP.

```{note}
**CMA reservation.** On Zynq-7000 the `cma=256M` set in the
`system-user.dtsi` `/chosen/bootargs` takes effect (verified at boot). On Zynq
UltraScale+ the `APPEND:append` line in `local.conf.append` does **not** currently
reach the kernel command line, so those targets boot with the kernel-default CMA
(256 MiB) — sufficient for the AXI Ethernet DMA buffers, but be aware the
`local.conf.append` `cma=` value is presently a no-op on ZynqMP.
```

The MicroBlaze (pure-FPGA) targets have no Linux flow (standalone only), so they
are not in the Yocto target set.

## Where build outputs land

| Path                                | Contents                                                                       |
|-------------------------------------|--------------------------------------------------------------------------------|
| `Vivado/<target>/`                  | Vivado project. `<bd_name>_wrapper.xsa` is the export.                          |
| `Vivado/<target>/<target>.runs/impl_1/<bd_name>_wrapper.bit` | Bitstream.                                              |
| `Vivado/logs/`                      | Per-target Vivado build logs (xpr + xsa).                                       |
| `Vitis/<target>_workspace/`         | Per-target Vitis workspace (platform + application + BSP).                      |
| `Vitis/boot/<target>/`              | Packaged Vitis boot files (`BOOT.BIN` for Zynq/ZynqMP, `.mcs` for MicroBlaze).  |
| `PetaLinux/<target>/`               | PetaLinux project. All Yocto build state lives here.                            |
| `PetaLinux/<target>/images/linux/`  | `BOOT.BIN`, `image.ub`, `boot.scr`, `rootfs.tar.gz`, etc.                       |
| `PetaLinux/<target>/build/build.log`| PetaLinux build log.                                                            |
| `bootimages/`                       | Per-target zipped boot files (`<prj>_<target>_petalinux-<ver>.zip` and `<prj>_<target>_standalone-<ver>.zip`). |

None of these directories are committed to the repository.
