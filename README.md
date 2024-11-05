# AXI Ethernet Reference Designs for Ethernet FMC

## Description

This project demonstrates the use of the Opsero [Ethernet FMC] and [Robust Ethernet FMC] and it supports
several FPGA/MPSoC development boards. The design contains 4 AXI Ethernet blocks configured with DMAs.

![Block diagram](docs/source/images/axi-eth-block-diagram.png "AXI Ethernet block diagram")

Important links:

* Datasheet of the [Ethernet FMC]
* Datasheet of the [Robust Ethernet FMC]
* The user guide for these reference designs is hosted here: [AXI Ethernet for Ethernet FMC docs](https://axieth.ethernetfmc.com "AXI Ethernet for Ethernet FMC docs")
* To report a bug: [Report an issue](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/issues "Report an issue").
* For technical support: [Contact Opsero](https://opsero.com/contact-us "Contact Opsero").
* To purchase the mezzanine card: [Ethernet FMC order page](https://opsero.com/product/ethernet-fmc "Ethernet FMC order page").

## Requirements

This project is designed for version 2024.1 of the Xilinx tools (Vivado/Vitis/PetaLinux). 
If you are using an older version of the Xilinx tools, then refer to the 
[release tags](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/tags "releases")
to find the version of this repository that matches your version of the tools.

In order to test this design on hardware, you will need the following:

* Vivado 2024.1
* Vitis 2024.1
* PetaLinux Tools 2024.1
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

| Target board          | Target design      | Ports       | FMC Slot(s) | Standalone<br> Echo Server | PetaLinux | Vivado<br> Edition |
|-----------------------|--------------------|-------------|-------------|-------|-------|-------|
| [AC701]               | `ac701`            | 4x          | HPC         | :white_check_mark: | :x:   | Standard :free: |
| [KC705]               | `kc705_hpc`        | 4x          | HPC         | :white_check_mark: | :x:   | Enterprise |
| [KC705]               | `kc705_lpc`        | 4x          | LPC         | :white_check_mark: | :x:   | Enterprise |
| [KC705]               | `kc705_lpc_hpc`    | 8x          | LPC & HPC   | :white_check_mark: | :x:   | Enterprise |
| [VC707]               | `vc707_hpc1`       | 4x          | HPC1        | :white_check_mark: | :x:   | Enterprise |
| [VC707]               | `vc707_hpc2`       | 4x          | HPC2        | :white_check_mark: | :x:   | Enterprise |
| [VC707]               | `vc707_hpc2_hpc1`  | 8x          | HPC2 & HPC1 | :white_check_mark: | :x:   | Enterprise |
| [VC709]               | `vc709`            | 4x          | HPC         | :white_check_mark: | :x:   | Enterprise |
| [KCU105]              | `kcu105_hpc`       | 4x          | HPC         | :white_check_mark: | :x:   | Enterprise |
| [KCU105]              | `kcu105_lpc`       | 3x          | LPC         | :white_check_mark: | :x:   | Enterprise |
| [KCU105]              | `kcu105_dual`      | 7x          | LPC & HPC   | :white_check_mark: | :x:   | Enterprise |
| [VCU108]              | `vcu108_hpc0`      | 4x          | HPC0        | :white_check_mark: | :x:   | Enterprise |
| [VCU108]              | `vcu108_hpc1`      | 4x          | HPC1        | :white_check_mark: | :x:   | Enterprise |
| [VCU118]              | `vcu118`           | 4x          | FMCP        | :white_check_mark: | :x:   | Enterprise |

### Zynq-7000 designs

| Target board          | Target design      | Ports       | FMC Slot(s) | Standalone<br> Echo Server | PetaLinux | Vivado<br> Edition |
|-----------------------|--------------------|-------------|-------------|-------|-------|-------|
| [PicoZed 7015]        | `pz_7015`          | 4x          | LPC         | :white_check_mark: | :white_check_mark: | Standard :free: |
| [PicoZed 7020]        | `pz_7020`          | 4x          | LPC         | :white_check_mark: | :white_check_mark: | Standard :free: |
| [PicoZed 7030]        | `pz_7030`          | 4x          | LPC         | :white_check_mark: | :white_check_mark: | Standard :free: |
| [ZC702]               | `zc702_lpc1`       | 4x          | LPC1        | :white_check_mark: | :white_check_mark: | Standard :free: |
| [ZC702]               | `zc702_lpc2`       | 4x          | LPC2        | :white_check_mark: | :white_check_mark: | Standard :free: |
| [ZC702]               | `zc702_lpc2_lpc1`  | 8x          | LPC2 & LPC1 | :white_check_mark: | :x:   | Standard :free: |
| [ZC706]               | `zc706_lpc`        | 4x          | LPC         | :white_check_mark: | :white_check_mark: | Enterprise |
| [ZedBoard]            | `zedboard`         | 4x          | LPC         | :white_check_mark: | :white_check_mark: | Standard :free: |

### Zynq UltraScale+ designs

| Target board          | Target design      | Ports       | FMC Slot(s) | Standalone<br> Echo Server | PetaLinux | Vivado<br> Edition |
|-----------------------|--------------------|-------------|-------------|-------|-------|-------|
| [UltraZed-EV Carrier] | `uzev`             | 4x          | HPC         | :white_check_mark: | :white_check_mark: | Standard :free: |
| [ZCU102]              | `zcu102_hpc0`      | 4x          | HPC0        | :white_check_mark: | :white_check_mark: | Enterprise |
| [ZCU102]              | `zcu102_hpc1`      | 2x          | HPC1        | :white_check_mark: | :white_check_mark: | Enterprise |

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

These reference designs can be driven by either a standalone application or within a PetaLinux environment. 
The repository includes all necessary scripts and code to build both environments. The table 
below outlines the corresponding applications available in each environment:

| Environment      | Available Applications  |
|------------------|-------------------------|
| Standalone       | lwIP Echo Server |
| PetaLinux        | Built-in Linux commands<br>Additional tools: ethtool, phytool, iperf3 |

## Build instructions

Clone the repo:
```
git clone https://github.com/fpgadeveloper/ethernet-fmc-axi-eth.git
```

Source Vivado and PetaLinux tools:

```
source <path-to-petalinux>/2024.1/settings.sh
source <path-to-vivado>/2024.1/settings64.sh
```

To build the standalone lwIP echo server application (Vivado project and Vitis workspace):

```
cd ethernet-fmc-axi-eth/Vitis
make workspace TARGET=zedboard
```

To build the PetaLinux image (Vivado project and PetaLinux):

```
cd ethernet-fmc-axi-eth/PetaLinux
make petalinux TARGET=zedboard
```

Replace the target label in these commands with the one corresponding to the target design of your
choice from the tables above.

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

[Ethernet FMC]: https://ethernetfmc.com/docs/ethernet-fmc/overview/
[Robust Ethernet FMC]: https://ethernetfmc.com/docs/robust-ethernet-fmc/overview/

