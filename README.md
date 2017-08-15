ethernet-fmc-axi-eth
====================

Example design for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") using 4 AXI Ethernet blocks.

## Requirements

This project is designed for Vivado 2017.2. If you are using an older version of Vivado, then you *MUST* use an older version
of this repository. Refer to the [list of commits](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/commits/master "list of commits")
to find links to the older versions of this repository.

* Vivado 2017.2
* [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
* One of the above listed evaluation boards
* [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

## Supported boards

* Zynq-7000 [ZedBoard](http://zedboard.org "ZedBoard")
  * LPC connector (use zedboard.xdc)
* Zynq-7000 [MicroZed FMC Carrier](http://zedboard.org/product/microzed-fmc-carrier "MicroZed FMC Carrier") with [MicroZed 7Z020](http://microzed.org "MicroZed")
  * LPC connector (use mzfmc-7z010-7z020.xdc)
* Zynq-7000 [PicoZed FMC Carrier Card V2](http://zedboard.org/product/picozed-fmc-carrier-card-v2 "PicoZed FMC Carrier Card V2") with [PicoZed 7015/20/30](http://picozed.org "PicoZed")
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
* Zynq UltraScale+ ZCU102 Evaluation board Rev 1.0
  * HPC0 connector (use zcu102-hpc0.xdc)
* Virtex Ultrascale [VCU108 Evaluation board] (https://www.xilinx.com/products/boards-and-kits/ek-u1-vcu108-g.html "VCU108 Evaluation board")
  * HPC0 connector (use vcu108-hpc0.xdc)
  * HPC1 connector (use vcu108-hpc1.xdc)
* Virtex Ultrascale+ [VCU118 ES1 Evaluation board] (https://www.xilinx.com/products/boards-and-kits/ek-u1-vcu118-es1-g.html "VCU118 ES1 Evaluation board")
  * HPC1 connector (use vcu118-es1.xdc)
  
## 8-port Support (2 x Ethernet FMCs)

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

## Description

This project demonstrates the use of the Opsero [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC").
The design contains 4 AXI Ethernet blocks configured with DMAs.

![Block diagram](http://ethernetfmc.com/wp-content/uploads/2014/10/qgige_all_axi_ethernet.png "Zynq Quad Gig Ethernet All AXI Ethernet")

> Note: Zynq PS block is replaced by MicroBlaze processor for the Artix, Kintex and Virtex boards.

## Build instructions

To use the sources in this repository, please follow these steps:

1. Download the repo as a zip file and extract the files to a directory
   on your hard drive --OR-- Git users: clone the repo to your hard drive
2. Open Windows Explorer, browse to the repo files on your hard drive.
3. In the Vivado directory, you will find multiple batch files (*.bat).
   Double click on the batch file that is appropriate to your hardware,
   for example, double-click `build-zedboard.bat` if you are using the ZedBoard.
   This will generate a Vivado project for your hardware platform.
4. Run Vivado and open the project that was just created.
5. Click Generate bitstream.
6. When the bitstream is successfully generated, select `File->Export->Export Hardware`.
   In the window that opens, tick "Include bitstream" and "Local to project".
7. Return to Windows Explorer and browse to the SDK directory in the repo.
8. Double click the `build-sdk.bat` batch file. The batch file will run the
   `build-sdk.tcl` script and build the SDK workspace containing the hardware
   design and the software application.
9. Run Xilinx SDK (DO NOT use the Launch SDK option from Vivado) and select the workspace to be the SDK directory of the repo.
10. Select `Project->Build automatically`.
11. Connect and power up the hardware.
12. Open a Putty terminal to view the UART output.
13. In the SDK, select `Xilinx Tools->Program FPGA`.
14. Right-click on the application and select `Run As->Launch on Hardware (System Debugger)`

The software application used to test these projects is the lwIP Echo Server example that is built into
Xilinx SDK. The application relies on the lwIP library (also built into Xilinx SDK) but with a few modifications.
The modified version of the lwIP library is contained in the `EmbeddedSw` directory, which is added as a
local SDK repository to the SDK workspace. See the readme in the SDK directory for more information.

## Single port limit

The echo server example design currently can only target one Ethernet port at a time.
Selection of the Ethernet port can be changed by modifying the defines contained in the
`platform_config.h` file in the application sources. Set `PLATFORM_EMAC_BASEADDR`
to one of the following values depending on the port you want to target:

* Ethernet FMC Port 0: `XPAR_AXIETHERNET_0_BASEADDR`
* Ethernet FMC Port 1: `XPAR_AXIETHERNET_1_BASEADDR`
* Ethernet FMC Port 2: `XPAR_AXIETHERNET_2_BASEADDR`
* Ethernet FMC Port 3: `XPAR_AXIETHERNET_3_BASEADDR`

## Board specific notes

### VC707, VC709 & VCU108

* These boards can only support the 1.8V version Ethernet FMC. The device on these boards have only HP (high-performance)
I/Os which do not support 2.5V levels.

### ZC706

* Zynq-7000 [ZC706 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html "ZC706 Evaluation board") (HPC)
  * HPC connector: Pins LA18_CC and LA17_CC of the HPC connector are routed to non-clock-capable pins so they cannot
  properly receive the RGMII receive clocks for ports 2 and 3 of the Ethernet FMC. The constraints file zc706-hpc.xdc is
  provided for reference, however it will not pass compilation with the Xilinx tools due to this problem.

### KCU105

* This board can only support the 1.8V version Ethernet FMC. The device on this board has only HP (high-performance)
I/Os which do not support 2.5V levels.
* KCU105 board design for the LPC connector is configured for only 3 ports as there is a strange placement error which occurs when trying
to build a design with 4 ports. The placement error has to do with IDELAYs and I have not reached a solution for this yet. There
is no such problem with the HPC for this board.

### ZCU102

* This design supports the ZCU102 Rev 1.0 board. Use a commit before 2016-02-13 for the older Rev-D board design.
Note that the FMC pinouts differ between Rev 1.0 and Rev D: https://www.xilinx.com/support/answers/68050.html
* This board can only support the 1.8V version Ethernet FMC. The device on this board has only HP (high-performance)
I/Os which do not support 2.5V levels.
* Known issue: On this board, DHCP does not function correctly in the echo server application and produces error message
`Error set buf addr 201116 with 4 and 3, 2`. To get around this issue, disable DHCP by inserting `#define LWIP_DHCP 0`
into the `main.c` file.

### PicoZed

#### Differences between designs

This repository contains a Vivado design for these PicoZed versions: 7Z020, 7Z015 and 7Z030.
The main differences between the designs are described below:

* 7Z020: We use 4x AXI Ethernet IPs. The constraints file uses the 2.5V IO standards.
* 7Z015: We use 4x AXI Ethernet IPs. The constraints file uses the 2.5V IO standards.
* 7Z030: We use 4x AXI Ethernet IPs. The constraints file uses the 1.8V IO standards because this device has HP I/Os.

#### Installation of MicroZed and PicoZed board definition files

To use the projects for the MicroZed and PicoZed, you must first install the board definition files
for those boards into your Vivado installation.

The following folders contain the board definition files and can be found in this project repository at this location:

https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/tree/master/Vivado/boards/board_files

* `microzed_7010`
* `microzed_7020`
* `picozed_7010_fmc2`
* `picozed_7015_fmc2`
* `picozed_7020_fmc2`
* `picozed_7030_fmc2`

Copy those folders and their contents into the `C:\Xilinx\Vivado\2017.2\data\boards\board_files` folder (this may
be different on your machine, depending on your Vivado installation directory).

## Microblaze design differences

The designs for AC701, KC705, VC707, VC709, KCU105 & VCU108 all use the Microblaze soft processor. These designs
have some specific differences when compared to the Zynq based designs:

* MIG - the MIG is required to exploit the DDR3/4 memory of the eval boards.
* AXI Timer - the lwIP echo server application requires a timer (Microblaze does not have one inherently).
* AXI UART16550 - the lwIP echo server application requires a UART for console output.

## Troubleshooting

Check the following if the project fails to build or generate a bitstream:

### 1. Are you using the correct version of Vivado for this version of the repository?
Check the version specified in the Requirements section of this readme file. Note that this project is regularly maintained to the latest
version of Vivado and you may have to refer to an earlier commit of this repo if you are using an older version of Vivado.

### 2. Did you correctly follow the Build instructions in this readme file?
All the projects in the repo are built, synthesised and implemented to a bitstream before being committed, so if you follow the
instructions, there should not be any build issues.

### 3. Did you copy/clone the repo into a short directory structure?
Vivado doesn't cope well with long directory structures, so copy/clone the repo into a short directory structure such as
`C:\projects\`. When working in long directory structures, you can get errors relating to missing files, particularly files 
that are normally generated by Vivado (FIFOs, etc).

## For more information

If you need more information on whether the Ethernet FMC is compatible with your carrier, please contact me [here](http://ethernetfmc.com/contact/ "Ethernet FMC Contact form").
Just provide me with the pinout of your carrier and I'll be happy to check compatibility and generate a Vivado constraints file for you.

## License

Feel free to modify the code for your specific application.

## About us

This project was developed by [Opsero Inc.](http://opsero.com "Opsero Inc."),
a tight-knit team of FPGA experts delivering FPGA products and design services to start-ups and tech companies. 
Follow our blog, [FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer"), for news, tutorials and
updates on the awesome projects we work on.