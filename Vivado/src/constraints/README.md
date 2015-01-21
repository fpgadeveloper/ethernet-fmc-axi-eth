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
* Zynq-7000 [ZC706 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html "ZC706 Evaluation board")
  * LPC connector (use zc706-lpc.xdc)
  * HPC connector (use zc706-hpc.xdc)

### Virtex-7 VC707 & VC709 Board Warning

Please be aware that the VC707 and VC709 boards can only support the 1.8V version Ethernet FMC. The devices
on these boards have only HP (high-performance) I/Os which do not support the 2.5V levels required by the standard
Ethernet FMC.

### Using two Ethernet FMCs on a single board

If you want to use two Ethernet FMCs on the same board, you must combine the two constraint files for the board you are using.
You will also have to rename the second set of net names so that they do not override the first set of constraints.


Jeff Johnson
[FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer")