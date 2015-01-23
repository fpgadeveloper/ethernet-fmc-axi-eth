Vivado Constraint files
=======================

### Supported Series-7 Evaluation boards and connectors

The Ethernet FMC can be used on both low-pin-count (LPC) and high-pin-count (HPC) FMC connectors. Some of the
Xilinx Series-7 Evaluation boards have multiple FMC connectors, so be sure to use the constraint file that is
appropriate for the connector you want to use. 

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

### Not-supported

* Zynq-7000 [ZC706 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html "ZC706 Evaluation board") (HPC)
  * HPC connector: Pins LA18_CC and LA17_CC of the HPC connector are routed to non-clock-capable pins so they cannot
  properly receive the RGMII receive clocks for ports 2 and 3 of the Ethernet FMC. The constraints file zc706-hpc.xdc is
  provided for reference, however it will not pass compilation with the Xilinx tools due to this problem.

### Virtex-7 VC707 & VC709 Board Warning

Please be aware that the VC707 and VC709 boards can only support the 1.8V version Ethernet FMC. The devices
on these boards have only HP (high-performance) I/Os which do not support the 2.5V levels required by the standard
Ethernet FMC.

### Using two Ethernet FMCs on a single board

The only Series-7 Evaluation boards that can support two Ethernet FMCs simultaneously are the 
[KC705](http://www.xilinx.com/products/boards-and-kits/ek-k7-kc705-g.html "KC705 Evaluation board"), [ZC702](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc702-g.html "ZC702 Evaluation board") 
and [VC707](http://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html "VC707 Evaluation board").
These notes provide more details on 8-port support:

* The KC705 and VC707 each have two FMC connectors that support the Ethernet FMC (use kc705-lpc-hpc.xdc and vc707-hpc2-hpc1.xdc respectively).
* The ZC702 has two FMC connectors that can support the Ethernet FMC, however note that the Zynq device on this board has limited FPGA resources
for supporting 8 x Xilinx AXI Ethernet IPs (ie. the MACs). The device has enough resources when the 8 MACs are configured with FIFOs, however there are insufficient
resources to configure them with DMAs. Alternatively, you could use a MAC that requires less resources. (use zc702-lpc2-lpc1.xdc)
* The ZC706 has two FMC connectors, but only one (the LPC) can support the Ethernet FMC (see detail below).

### For more information

If you need more information on whether the Ethernet FMC is compatible with your carrier, please contact me [here](http://ethernetfmc.com/contact/ "Ethernet FMC Contact form").
Just provide me with the pinout of your carrier and I'll be happy to check compatibility and generate a Vivado constraints file for you.


Jeff Johnson
[FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer")