series7-qgige-axieth
====================

Example design for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") on ALL the Xilinx Series-7 Evaluation boards using 4 AXI Ethernet blocks

### Supported boards

* Artix-7 [AC701 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-a7-ac701-g.html "AC701 Evaluation board")
  * HPC connector (use ac701.xdc)
* Kintex-7 [KC705 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-k7-kc705-g.html "KC705 Evaluation board")
  * LPC connector (use kc705-lpc.xdc)
  * HPC connector (use kc705-hpc.xdc)
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

### 8-port Support (2 x Ethernet FMCs)

The only Series-7 Evaluation boards that can support two Ethernet FMCs simultaneously are the 
[KC705](http://www.xilinx.com/products/boards-and-kits/ek-k7-kc705-g.html "KC705 Evaluation board"), [ZC702](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc702-g.html "ZC702 Evaluation board") 
and [VC707](http://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html "VC707 Evaluation board").

This repository contains example designs for using 2 x Ethernet FMCs on the same carrier. They all use 8
Xilinx AXI Ethernet Subsystem IPs that are configured with FIFOs, as opposed to all the single Ethernet FMC example designs
which are configured with DMAs. For the KC705 and VC707, the reason for this is that we would need to route 8 DMAs to the DDR3 memory, each DMA having 3 ports to
map (ie. 8 x 3 = 24), however the AXI Interconnect is limited to only 16 slave ports. For the ZC702, the problem is a lack of FPGA
resources as using 8 MACs configured with DMAs requires more resources than is contained in the Zynq device of that board.

These notes provide more details on 8-port support:

* The KC705 and VC707 each have two FMC connectors that support the Ethernet FMC (use kc705-lpc-hpc.xdc and vc707-hpc2-hpc1.xdc respectively).
* The ZC702 has two FMC connectors that can support the Ethernet FMC, however note that the Zynq device on this board has limited FPGA resources
for supporting 8 x Xilinx AXI Ethernet IPs (ie. the MACs). The device has enough resources when the 8 MACs are configured with FIFOs, however there are insufficient
resources to configure them with DMAs. Alternatively, you could use a MAC that requires less resources. (use zc702-lpc2-lpc1.xdc)
* The ZC706 has two FMC connectors, but only one (the LPC) can support the Ethernet FMC (see detail below).

### Not-supported

* Zynq-7000 [ZC706 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html "ZC706 Evaluation board") (HPC)
  * HPC connector: Pins LA18_CC and LA17_CC of the HPC connector are routed to non-clock-capable pins so they cannot
  properly receive the RGMII receive clocks for ports 2 and 3 of the Ethernet FMC. The constraints file zc706-hpc.xdc is
  provided for reference, however it will not pass compilation with the Xilinx tools due to this problem.

### Description

This project demonstrates the use of the Opsero [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC").
The design contains 4 AXI Ethernet blocks configured with DMAs.

![Block diagram](http://ethernetfmc.com/wp-content/uploads/2014/10/qgige_all_axi_ethernet.png "Zynq Quad Gig Ethernet All AXI Ethernet")

> Note: Zynq PS block is replaced by MicroBlaze processor for the Artix, Kintex and Virtex boards.

### Requirements

* Vivado 2014.4 (see Library modifications below)
* [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
* One of the above listed evaluation boards
* [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

### Library modifications for Vivado 2014.4

To use this project, a modification must be made to the lwIP libraries
provided by the Xilinx SDK. The modification can be made either to the
BSP code of your SDK workspace, or to the SDK sources. I personally
recommend modifying the SDK sources as every rebuild of the BSP results
in the BSP sources being overwritten with the SDK sources.

#### Modification to xaxiemacif_dma.c 

Open the following file:

`C:\Xilinx\SDK\2014.4\data\embeddedsw\ThirdParty\sw_services\lwip140_v2_2\src\contrib\ports\xilinx\netif\xaxiemacif_dma.c`

Replace this line of code:

`DMAConfig = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);`

With this one:

`DMAConfig = XAxiDma_LookupConfig(xemac->topology_index);`

### For more information

If you need more information on whether the Ethernet FMC is compatible with your carrier, please contact me [here](http://ethernetfmc.com/contact/ "Ethernet FMC Contact form").
Just provide me with the pinout of your carrier and I'll be happy to check compatibility and generate a Vivado constraints file for you.

### License

Feel free to modify the code for your specific application.

### Fork and share

If you port this project to another hardware platform, please send me the
code or push it onto GitHub and send me the link so I can post it on my
website. The more people that benefit, the better.

### About the author

I'm an FPGA consultant and I provide FPGA design services to innovative
companies around the world. I believe in sharing knowledge and
I regularly contribute to the open source community.

Jeff Johnson
[FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer")