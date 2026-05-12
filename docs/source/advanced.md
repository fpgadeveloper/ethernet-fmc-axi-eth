# Advanced: project structure and customization

This section is intended for users who want to modify the reference
designs — adding IP to the block design, changing constraints, modifying
the standalone application, or adding packages or drivers to the
PetaLinux project. It describes how the repository is laid out, how the
Make-driven build flow works, how the Vitis and PetaLinux sides are
organised, and what modifications have been added on top of the stock
AMD BSPs.

The actual *build* instructions are in [build_instructions](build_instructions);
this section is about understanding the project well enough to modify
it.

## Repository layout

```
.
├── Makefile                   <- Top-level build entry point
├── README.md
├── config/                    <- Source-of-truth design metadata and auto-generation
│   ├── data.json
│   └── update.py
├── docs/                      <- This documentation (Sphinx + Read the Docs)
├── EmbeddedSw/                <- Vendored AMD BSP libraries used by the Vitis build
├── PetaLinux/
│   ├── Makefile               <- PetaLinux build orchestration
│   └── bsp/                   <- Per-board and per-port-config BSP fragments
│       ├── pz/, zc702/, …     <-   board-specific overlays
│       └── ports-0123/, ports-01--/   <- port-config overlays
└── Vivado/
│   ├── Makefile               <- Vivado build orchestration
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
    ├── Makefile               <- Vitis workspace + boot-image orchestration
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

A `TARGET` is the canonical handle for a single design and is the only
parameter passed through the build flow. It encodes the board and, for
boards with multiple FMC connectors, the connector:

```
<board>[_<connector>]
```

Examples: `zedboard`, `zcu102_hpc0`, `kc705_hpc`, `zc702_lpc2`,
`vc707_hpc2_hpc1` (the dual-FMC variant). The first
underscore-delimited token is taken as the *target board* and is what
`PetaLinux/Makefile` uses to select the BSP under
`PetaLinux/bsp/<board>/`.

The complete list of valid targets is in the `UPDATER START` block of
each Makefile and is generated from `config/data.json` (see below).

## `config/data.json` and `config/update.py`

`config/data.json` is the canonical source of truth for the set of
supported designs and their per-target metadata (board name, processor
family, FMC connector, port lane mapping, baremetal-vs-PetaLinux
support, etc.). `config/update.py` reads `data.json` and regenerates
the auto-managed sections of the four Makefiles, the top-level
`README.md`, and `.gitignore` — the sections delimited by
`UPDATER START` / `UPDATER END` comment markers.

When adding or modifying a target, edit `data.json` and re-run
`update.py`. Do not hand-edit content between the `UPDATER START` /
`UPDATER END` markers; it will be overwritten on the next regeneration.

## Make-driven build flow

There are four Makefiles in the repository, each scoped to a stage of
the build:

| Makefile              | Scope                                                                                          |
|-----------------------|------------------------------------------------------------------------------------------------|
| `./Makefile`          | Top-level orchestration; assembles boot-image zips for one or all targets.                     |
| `./Vivado/Makefile`   | Creates the Vivado project, runs synthesis and implementation, exports the XSA.                |
| `./Vitis/Makefile`    | Creates the Vitis workspace and platform from the XSA, builds the standalone application, packages BOOT.BIN/.mcs. |
| `./PetaLinux/Makefile`| Creates the PetaLinux project from the XSA, applies BSP overlays, builds, packages.            |

Each target is flagged in the top-level Makefile as either
`baremetal_only` (Vitis only — all the MicroBlaze targets) or `both`
(Vitis + PetaLinux). A `make bootimage TARGET=<t>` invocation at the
top level cascades:

```
make bootimage TARGET=t
  -> Vitis side (if applicable):
       Vitis/Makefile workspace TARGET=t -> bootfile TARGET=t
         -> ensures Vivado XSA exists
              Vivado/Makefile xsa TARGET=t
                -> vivado -mode batch -source scripts/build.tcl   (creates project)
                -> vivado -mode batch -source scripts/xsa.tcl     (synth, impl, XSA export)
         -> python3 py/build-vitis.py  ... (creates platform + app, builds)
         -> python3 py/make-boot.py    ... (packages BOOT.BIN / .mcs)
  -> PetaLinux side (if applicable):
       PetaLinux/Makefile petalinux TARGET=t
         -> petalinux-create --template <microblaze|zynq|zynqMP> --name t
         -> petalinux-config --get-hw-description <XSA>
         -> copy bsp/<board>/project-spec/* into the project
         -> copy bsp/<port-config>/project-spec/* into the project   (overlay)
         -> petalinux-config --silentconfig
         -> petalinux-build
         -> petalinux-package boot ...
  -> zip the resulting boot files into bootimages/
```

Per-target lock files (`.<target>.lock` in each Makefile's directory)
prevent two concurrent builds of the same target from clobbering each
other.

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
  block design. Invoked via `make project TARGET=<t>`.
* `Vivado/scripts/xsa.tcl` opens the existing project, runs synthesis
  and implementation, exports the XSA, and writes the bitstream into
  the implementation run directory. Invoked via `make xsa TARGET=<t>`.

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
build through the Makefile:

```
make -C Vivado xsa TARGET=<target>
```

This re-creates the project, sources the modified BD script, runs
`validate_bd_design`, synthesises, implements, and re-exports the XSA.
Downstream Vitis / PetaLinux / boot-image steps will pick up the new
XSA on the next `make` at the top level.

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
├── Makefile
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

### Modifying the standalone application

Edit `Vitis/common/src/*.c` directly. The next `make -C Vitis bootfile
TARGET=<t>` rebuilds the application against the existing platform; if
you've changed the hardware (XSA) you'll need a fresh workspace
(`make -C Vitis clean TARGET=<t>` first).

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
  `CONFIG_SUBSYSTEM_USER_CMDLINE` (with `cma=1536M` for the AXI DMA
  buffers).
* **U-Boot patch `0001-ubifs-distroboot-support.patch`** on the
  appropriate boards.

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
