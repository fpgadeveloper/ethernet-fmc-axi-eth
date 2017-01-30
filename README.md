ethernet-fmc-axi-eth
====================

Example design for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") using 4 AXI Ethernet blocks.

### Supported boards

* Zynq-7000 [ZedBoard](http://zedboard.org "ZedBoard")
  * LPC connector (use zedboard.xdc)
* Zynq-7000 [MicroZed FMC Carrier](http://zedboard.org/product/microzed-fmc-carrier "MicroZed FMC Carrier") with [MicroZed 7Z020](http://microzed.org "MicroZed")
  * LPC connector (use mzfmc-7z010-7z020.xdc)
* Zynq-7000 [PicoZed FMC Carrier Card V2](http://zedboard.org/product/picozed-fmc-carrier-card-v2 "PicoZed FMC Carrier Card V2") with [PicoZed 7010/15/20/30](http://picozed.org "PicoZed")
  * LPC connector (use pzfmc-7z0xx.xdc)
* Artix-7 [AC701 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-a7-ac701-g.html "AC701 Evaluation board")
  * HPC connector (use ac701.xdc)
* Kintex-7 [KC705 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-k7-kc705-g.html "KC705 Evaluation board")
  * LPC connector (use kc705-lpc.xdc)
  * HPC connector (use kc705-hpc.xdc)
* Kintex UltraScale [KCU105 Evaluation board](http://www.xilinx.com/products/boards-and-kits/kcu105.html "KCU105 Evaluation board")
  * LPC connector (use kcu105-lpc.xdc)
  * HPC connector (use kcu105-hpc.xdc)
* Virtex-7 [VC707 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html "VC707 Evaluation board")
  * HPC connector 1 (use vc707-hpc1.xdc)
  * HPC connector 2 (use vc707-hpc2.xdc)
* Virtex-7 [VC709 Evaluation board](http://www.xilinx.com/products/boards-and-kits/dk-v7-vc709-g.html "VC709 Evaluation board")
  * HPC connector (use vc709.xdc)
* Zynq-7000 [ZC702 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc702-g.html "ZC702 Evaluation board")
  * LPC connector 1 (use zc702-lpc1.xdc)
  * LPC connector 2 (use zc702-lpc2.xdc)
* Zynq-7000 [ZC706 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html "ZC706 Evaluation board") (LPC only)
  * LPC connector (use zc706-lpc.xdc)
* Zynq UltraScale+ ZCU102 Evaluation board
  * HPC0 connector (use zcu102-hpc0.xdc)
* Virtex Ultrascale [VCU108 Evaluation board] (https://www.xilinx.com/products/boards-and-kits/ek-u1-vcu108-g.html "VCU108 Evaluation board")
  * HPC0 connector (use vcu108-hpc0.xdc)
  * HPC1 connector (use vcu108-hpc1.xdc)
  
### 8-port Support (2 x Ethernet FMCs)

The only Evaluation boards that can support two Ethernet FMCs simultaneously are the 
[KC705](http://www.xilinx.com/products/boards-and-kits/ek-k7-kc705-g.html "KC705 Evaluation board"), 
[KCU105](http://www.xilinx.com/products/boards-and-kits/kcu105.html "KC705 Evaluation board"), 
[ZC702](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc702-g.html "ZC702 Evaluation board") 
and [VC707](http://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html "VC707 Evaluation board").

This repository contains example designs for using 2 x Ethernet FMCs on the same carrier. They all use 8
Xilinx AXI Ethernet Subsystem IPs that are configured with DMAs, except for the ZC702 design, which is configured with FIFOs.
The reason for this is a lack of FPGA resources as using 8 MACs configured with DMAs requires more resources than is
contained in the Zynq device of that board.

These notes provide more details on 8-port support:

* The KC705 and VC707 each have two FMC connectors that support the Ethernet FMC (use kc705-lpc-hpc.xdc and vc707-hpc2-hpc1.xdc respectively).
* The KCU105 can support two Ethernet FMCs however the LPC only supports 3 ports so the dual design contains
only 7 ports total.
The critical block which does not pass timing requirements is the axi_mem_intercon.
* The ZC702 has two FMC connectors that can support the Ethernet FMC, however note that the Zynq device on this board has limited FPGA resources
for supporting 8 x Xilinx AXI Ethernet IPs (ie. the MACs). The device has enough resources when the 8 MACs are configured with FIFOs, however there are insufficient
resources to configure them with DMAs. Alternatively, you could use a MAC that requires less resources. (use zc702-lpc2-lpc1.xdc)
* The ZC706 has two FMC connectors, but only one (the LPC) can support the Ethernet FMC (see detail in board specific notes below).

### Description

This project demonstrates the use of the Opsero [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC").
The design contains 4 AXI Ethernet blocks configured with DMAs.

![Block diagram](http://ethernetfmc.com/wp-content/uploads/2014/10/qgige_all_axi_ethernet.png "Zynq Quad Gig Ethernet All AXI Ethernet")

> Note: Zynq PS block is replaced by MicroBlaze processor for the Artix, Kintex and Virtex boards.

### Requirements

* Vivado 2016.4
* [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
* One of the above listed evaluation boards
* [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

### Single port limit

The echo server example design currently can only target one Ethernet port at a time.
Selection of the Ethernet port can be changed by modifying the defines contained in the
`platform_config.h` file in the application sources. Set `PLATFORM_EMAC_BASEADDR`
to one of the following values depending on the port you want to target:

* Ethernet FMC Port 0: `XPAR_AXIETHERNET_0_BASEADDR`
* Ethernet FMC Port 1: `XPAR_AXIETHERNET_1_BASEADDR`
* Ethernet FMC Port 2: `XPAR_AXIETHERNET_2_BASEADDR`
* Ethernet FMC Port 3: `XPAR_AXIETHERNET_3_BASEADDR`

### Board specific notes

#### VC707, VC709 & VCU108

* These boards can only support the 1.8V version Ethernet FMC. The device on these boards have only HP (high-performance)
I/Os which do not support 2.5V levels.

#### ZC706

* Zynq-7000 [ZC706 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html "ZC706 Evaluation board") (HPC)
  * HPC connector: Pins LA18_CC and LA17_CC of the HPC connector are routed to non-clock-capable pins so they cannot
  properly receive the RGMII receive clocks for ports 2 and 3 of the Ethernet FMC. The constraints file zc706-hpc.xdc is
  provided for reference, however it will not pass compilation with the Xilinx tools due to this problem.

#### KCU105

* This board can only support the 1.8V version Ethernet FMC. The device on this board has only HP (high-performance)
I/Os which do not support 2.5V levels.
* KCU105 board design for the LPC connector is configured for only 3 ports as there is a strange placement error which occurs when trying
to build a design with 4 ports. The placement error has to do with IDELAYs and I have not reached a solution for this yet. There
is no such problem with the HPC for this board.

#### ZCU102

* This board can only support the 1.8V version Ethernet FMC. The device on this board has only HP (high-performance)
I/Os which do not support 2.5V levels.
* For optimal timing of the RGMII bus, the PHYs of ports 1 and 3 must be configured with RX clock skew
DISABLED. This is due to the fact that signals LA01_CC and LA18_CC are not routed to clock capable pins on
the ZCU102 board, and are thus subject to extra delay in the FPGA fabric. To disable the RX clock skew
in Linux, use phy-mode "rgmii-txid" or "rgmii". To disable the RX clock skew in stand-alone applications,
refer to this [technical guide](http://ethernetfmc.com/rgmii-interface-timing-considerations/ "RGMII Interface Timing Considerations").

#### PicoZed

##### Differences between designs

This repository contains a Vivado design for each of the PicoZed versions: 7Z010, 7Z020, 7Z015 and 7Z030.
The main differences between the designs are described below:

* 7Z010: We can't fit 4x AXI Ethernet IPs with DMAs into the 7Z010 device, so instead we use 3x AXI Ethernet and 1x
GMII-to-RGMII connected to GEM1 (GEM0 could be connected to the PicoZed's onboard PHY if desired).
* 7Z020: We use 4x AXI Ethernet IPs. The constraints file uses the 2.5V IO standards.
* 7Z015: We use 4x AXI Ethernet IPs. The constraints file uses the 2.5V IO standards.
* 7Z030: We use 4x AXI Ethernet IPs. The constraints file uses the 1.8V IO standards because this device has HP I/Os.

##### Installation of PicoZed board definition files

To use this project, you must first install the board definition files
for the PicoZed into your Vivado installation.

The following folders contain the board definition files and can be found in this project repository at this location:

https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/tree/master/Vivado/boards/board_files

* `picozed_7010_fmc2`
* `picozed_7015_fmc2`
* `picozed_7020_fmc2`
* `picozed_7030_fmc2`

Copy those folders and their contents into the `C:\Xilinx\Vivado\2016.4\data\boards\board_files` folder (this may
be different on your machine, depending on your Vivado installation directory).

### Building the SDK workspace

The software application used to test these projects is the lwIP Echo Server example that is built into
Xilinx SDK. The application relies on the lwIP library (also built into Xilinx SDK) but with a few modifications.
The modified version of the lwIP library is contained in the `EmbeddedSw` directory, which is added as a
local SDK repository to the SDK workspace.

Instructions for building the SDK workspace can be found in the `SDK` directory of this repo.

### Microblaze design differences

The designs for AC701, KC705, VC707, VC709, KCU105 & VCU108 all use the Microblaze soft processor. These designs
have some specific differences when compared to the Zynq based designs:

* MIG - the MIG is required to exploit the DDR3/4 memory of the eval boards.
* AXI Timer - the lwIP echo server application requires a timer (Microblaze does not have one inherently).
* AXI UART16550 - the lwIP echo server application requires a UART for console output.

### For more information

If you need more information on whether the Ethernet FMC is compatible with your carrier, please contact me [here](http://ethernetfmc.com/contact/ "Ethernet FMC Contact form").
Just provide me with the pinout of your carrier and I'll be happy to check compatibility and generate a Vivado constraints file for you.

### License

Feel free to modify the code for your specific application.

### About us

This project was developed by [Opsero Inc.](http://opsero.com "Opsero Inc."),
a tight-knit team of FPGA experts delivering FPGA products and design services to start-ups and tech companies. 
Follow our blog, [FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer"), for news, tutorials and
updates on the awesome projects we work on.