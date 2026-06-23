# AXI Ethernet Reference Designs for Ethernet FMC

## Description

This project demonstrates the use of the Opsero [Ethernet FMC] (OP031) and [Robust Ethernet FMC] (OP041) and it supports
several FPGA/MPSoC development boards. The design contains 4 AXI Ethernet blocks configured with DMAs.

![Block diagram](docs/source/images/axi-eth-block-diagram.png "AXI Ethernet block diagram")

Important links:

* Datasheets of the [Ethernet FMC] and [Robust Ethernet FMC]
* The user guide for these reference designs is hosted here: [AXI Ethernet for Ethernet FMC docs](https://axieth.ethernetfmc.com "AXI Ethernet for Ethernet FMC docs")
* To report a bug: [Report an issue](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/issues "Report an issue").
* For technical support: [Contact Opsero](https://opsero.com/contact-us "Contact Opsero").
* To purchase the mezzanine card: [Ethernet FMC order page](https://opsero.com/product/ethernet-fmc "Ethernet FMC order page").

## Requirements

This project is designed for version 2025.2 of the Xilinx tools (Vivado/Vitis/PetaLinux). 
If you are using an older version of the Xilinx tools, then refer to the 
[release tags](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/tags "releases")
to find the version of this repository that matches your version of the tools.

In order to test this design on hardware, you will need the following:

* Vivado 2025.2
* Vitis 2025.2
* PetaLinux Tools 2025.2
* [Ethernet FMC] or [Robust Ethernet FMC]
* One of the target platforms listed below
* [Xilinx Soft TEMAC license](https://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

## Target designs

This repo contains several designs that target various supported development boards and their
FMC connectors. The table below lists the target design name, the number of ports supported by the design and 
the FMC connector on which to connect the mezzanine card. Some of the target designs
require a license to generate a bitstream with the AMD Xilinx tools.

<!-- updater start -->
### FPGA designs

| Target board          | Target design      | Ports       | FMC Slot(s) | Standalone<br> Echo Server | PetaLinux | Yocto | Vivado<br> Edition | IP<br>License |
|-----------------------|--------------------|-------------|-------------|-------|-------|-------|-------|-------|
| [AC701]               | `ac701`            | 4x          | HPC         | :white_check_mark: | :x:   | :x:   | Standard :free: | Required |
| [KC705]               | `kc705_hpc`        | 4x          | HPC         | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [KC705]               | `kc705_lpc`        | 4x          | LPC         | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [KC705]               | `kc705_lpc_hpc`    | 8x          | LPC & HPC   | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [VC707]               | `vc707_hpc1`       | 4x          | HPC1        | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [VC707]               | `vc707_hpc2`       | 4x          | HPC2        | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [VC707]               | `vc707_hpc2_hpc1`  | 8x          | HPC2 & HPC1 | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [VC709]               | `vc709`            | 4x          | HPC         | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [KCU105]              | `kcu105_hpc`       | 4x          | HPC         | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [KCU105]              | `kcu105_lpc`       | 3x          | LPC         | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [KCU105]              | `kcu105_dual`      | 7x          | LPC & HPC   | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [VCU108]              | `vcu108_hpc0`      | 4x          | HPC0        | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [VCU108]              | `vcu108_hpc1`      | 4x          | HPC1        | :white_check_mark: | :x:   | :x:   | Enterprise | Required |
| [VCU118]              | `vcu118`           | 4x          | FMCP        | :white_check_mark: | :x:   | :x:   | Enterprise | Required |

### Zynq-7000 designs

| Target board          | Target design      | Ports       | FMC Slot(s) | Standalone<br> Echo Server | PetaLinux | Yocto | Vivado<br> Edition | IP<br>License |
|-----------------------|--------------------|-------------|-------------|-------|-------|-------|-------|-------|
| [PicoZed 7015]        | `pz_7015`          | 4x          | LPC         | :white_check_mark: | :white_check_mark: | :white_check_mark: | Standard :free: | Required |
| [PicoZed 7020]        | `pz_7020`          | 4x          | LPC         | :white_check_mark: | :white_check_mark: | :white_check_mark: | Standard :free: | Required |
| [PicoZed 7030]        | `pz_7030`          | 4x          | LPC         | :white_check_mark: | :white_check_mark: | :white_check_mark: | Standard :free: | Required |
| [ZC702]               | `zc702_lpc1`       | 4x          | LPC1        | :white_check_mark: | :white_check_mark: | :white_check_mark: | Standard :free: | Required |
| [ZC702]               | `zc702_lpc2`       | 4x          | LPC2        | :white_check_mark: | :white_check_mark: | :white_check_mark: | Standard :free: | Required |
| [ZC702]               | `zc702_lpc2_lpc1`  | 8x          | LPC2 & LPC1 | :white_check_mark: | :x:   | :x:   | Standard :free: | Required |
| [ZC706]               | `zc706_lpc`        | 4x          | LPC         | :white_check_mark: | :white_check_mark: | :white_check_mark: | Enterprise | Required |
| [ZedBoard]            | `zedboard`         | 4x          | LPC         | :white_check_mark: | :white_check_mark: | :white_check_mark: | Standard :free: | Required |

### Zynq UltraScale+ designs

| Target board          | Target design      | Ports       | FMC Slot(s) | Standalone<br> Echo Server | PetaLinux | Yocto | Vivado<br> Edition | IP<br>License |
|-----------------------|--------------------|-------------|-------------|-------|-------|-------|-------|-------|
| [UltraZed-EV Carrier] | `uzev`             | 4x          | HPC         | :white_check_mark: | :white_check_mark: | :white_check_mark: | Standard :free: | Required |
| [ZCU102]              | `zcu102_hpc0`      | 4x          | HPC0        | :white_check_mark: | :white_check_mark: | :white_check_mark: | Enterprise | Required |
| [ZCU102]              | `zcu102_hpc1`      | 2x          | HPC1        | :white_check_mark: | :white_check_mark: | :white_check_mark: | Enterprise | Required |

[AC701]: https://www.xilinx.com/ac701
[KC705]: https://www.xilinx.com/kc705
[VC707]: https://www.xilinx.com/vc707
[VC709]: https://www.xilinx.com/vc709
[KCU105]: https://www.xilinx.com/kcu105
[VCU108]: https://www.xilinx.com/vcu108
[VCU118]: https://www.xilinx.com/vcu118
[PicoZed 7015]: https://www.xilinx.com/products/boards-and-kits/1-hypn9d.html
[PicoZed 7020]: https://www.xilinx.com/products/boards-and-kits/1-hypn9d.html
[PicoZed 7030]: https://www.xilinx.com/products/boards-and-kits/1-hypn9d.html
[ZC702]: https://www.xilinx.com/zc702
[ZC706]: https://www.xilinx.com/zc706
[ZedBoard]: https://www.xilinx.com/products/boards-and-kits/1-8dyf-11.html
[UltraZed-EV Carrier]: https://www.xilinx.com/products/boards-and-kits/1-1s78dxb.html
[ZCU102]: https://www.xilinx.com/zcu102
<!-- updater end -->

Notes:

1. The Vivado Edition column indicates which designs are supported by the Vivado *Standard* Edition, the
   FREE edition which can be used without a license. Vivado *Enterprise* Edition requires
   a license however a 30-day evaluation license is available from the AMD Xilinx Licensing site.

## Software

These reference designs can be driven by a **standalone** (bare-metal) application or from
within an embedded **Linux** environment. The repository includes all the scripts and code
needed to build either one.

For Linux, two build flows are provided, both based on AMD's 2025.2 tools:

* **PetaLinux** — AMD's long-standing embedded Linux build tool (see the `PetaLinux/`
  directory).
* **Yocto / EDF** — AMD's Embedded Development Framework, the announced successor to
  PetaLinux, built with the `gen-machineconf parse-sdt` flow (see the `Yocto/` directory).

> [!IMPORTANT]
> **The PetaLinux flow is being retired for this repository.** Version 2025.2 is the
> last tool release for which we will support PetaLinux; from the next tool version
> onward, Linux images will be built with the Yocto / EDF flow only. New work should
> use the Yocto flow.

For 2025.2, both flows produce an equivalent Linux image with the same applications, so you
can pick whichever fits your workflow. The [target design tables](#target-designs) show which
boards are supported by each flow.

| Environment | Build flow          | Available applications |
|-------------|---------------------|------------------------|
| Standalone  | Vitis               | lwIP echo server |
| Linux       | PetaLinux  /  Yocto | Built-in Linux commands<br>Additional tools: ethtool, phytool, iperf3 |

The standalone application runs the lwIP echo server on the target, exercising the AXI
Ethernet ports. Under Linux, the same ports come up as network interfaces that you can bring
up, assign IP addresses, and test with the bundled tools.

## Build instructions

Clone the repo and change into its directory:
```
git clone https://github.com/fpgadeveloper/ethernet-fmc-axi-eth.git
cd ethernet-fmc-axi-eth
```

### Cross-platform build runner

All builds are driven by `build.py` at the repo root, on both Windows
(git bash) and Linux. The `build.sh` / `build.bat` shim finds a suitable
Python 3 automatically (including the one bundled with the AMD tools).
Pick a target design label from the tables above (or run `./build.sh
list`), then run the build command for the stage(s) you want — each
command builds whatever it depends on automatically and skips anything
already built. On Windows without git bash, run the same commands from
Command Prompt or PowerShell using `build.bat` (e.g. `build.bat xsa
--target <target>`).

You don't need to source the AMD tools first — the build runner finds
Vivado, Vitis and PetaLinux automatically in their standard install
locations and sets up the environment each stage needs. If your tools
are installed somewhere non-standard and the runner can't find them,
source the tool settings yourself before running the build.

#### Build the Vivado project (bitstream + XSA)

```
./build.sh xsa --target <target>
```

#### Build the standalone application

Builds the Vitis workspace and the baremetal boot file (`BOOT.BIN` or
bit file, depending on the device family):

```
./build.sh standalone --target <target>
```

#### Build PetaLinux (Linux only)

```
./build.sh petalinux --target <target>
```

Note: this release supports both PetaLinux and Yocto; PetaLinux will be
dropped in favor of the Yocto flow at the next version update.

#### Build Yocto (Linux only)

```
./build.sh yocto --target <target>
```

#### Build everything

Builds all of the above that the target supports, then gathers the boot
images into `bootimages/*.zip`:

```
./build.sh all --target <target>
./build.sh all --target all          # every target in the repo
```

Also available: `status`, `clean`, `project` — see
`./build.sh --help`. On Windows, the PetaLinux and Yocto stages require a
Linux machine; the runner says so and prints the hand-off command. The
legacy `make` interface still works on Linux (each Makefile now wraps
`build.sh`) but is deprecated and will be removed at the next version
update.

## Contribute

We strongly encourage community contribution to these projects. Please make a pull request if you
would like to share your work:
* if you've spotted and fixed any issues
* if you've added designs for other target platforms

Thank you to everyone who supports us!

## About us

This project was developed by [Opsero Inc.](https://opsero.com "Opsero Inc."),
a tight-knit team of FPGA experts delivering FPGA products and design services to start-ups and tech companies. 
Follow our blog, [FPGA Developer](https://www.fpgadeveloper.com "FPGA Developer"), for news, tutorials and
updates on the awesome projects we work on.

[Ethernet FMC]: https://docs.opsero.com/op031/datasheet/overview/
[Robust Ethernet FMC]: https://docs.opsero.com/op041/datasheet/overview/

