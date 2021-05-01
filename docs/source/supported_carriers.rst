========================
Supported carrier boards
========================

List of supported boards
========================

+-----------------------------------------------------------------------+---------------------------+ 
| Carrier board                                                         | FMC connector             |
+=======================================================================+===========================+ 
| Zynq-7000 `ZedBoard`_                                                 | LPC                       |
+-----------------------------------------------------------------------+---------------------------+ 
| | Zynq-7000 `MicroZed FMC Carrier`_                                   | LPC                       |
| | with `MicroZed 7Z020`_.                                             |                           |
+-----------------------------------------------------------------------+---------------------------+ 
| | Zynq-7000 `PicoZed FMC Carrier Card V2`_                            | LPC                       |
| | with `PicoZed 7015/20/30`_                                          |                           |
+-----------------------------------------------------------------------+---------------------------+ 
| Artix-7 `AC701 Evaluation board`_                                     | HPC                       |
+-----------------------------------------------------------------------+---------------------------+ 
| Kintex-7 `KC705 Evaluation board`_                                    | LPC and HPC               |
+-----------------------------------------------------------------------+---------------------------+ 
| Kintex UltraScale `KCU105 Evaluation board`_                          | LPC and HPC               |
+-----------------------------------------------------------------------+---------------------------+ 
| Virtex-7 `VC707 Evaluation board`_                                    | HPC1 and HPC2             |
+-----------------------------------------------------------------------+---------------------------+ 
| Virtex-7 `VC709 Evaluation board`_                                    | HPC                       |
+-----------------------------------------------------------------------+---------------------------+ 
| Zynq-7000 `ZC702 Evaluation board`_                                   | LPC1 and LPC2             |
+-----------------------------------------------------------------------+---------------------------+ 
| Zynq-7000 `ZC706 Evaluation board`_                                   | LPC                       |
+-----------------------------------------------------------------------+---------------------------+ 
| Zynq UltraScale+ `ZCU102 Evaluation board`_                           | HPC0 and HPC1             |
|                                                                       | (HPC1 limited to 2 ports) |
+-----------------------------------------------------------------------+---------------------------+ 
| Zynq UltraScale+ `UltraZed EV Carrier Card`_                          | HPC                       |
+-----------------------------------------------------------------------+---------------------------+ 
| Virtex Ultrascale+ `VCU108 Evaluation board`_                         | HPC0 and HPC1             |
+-----------------------------------------------------------------------+---------------------------+ 
| Virtex Ultrascale+ `VCU118 Evaluation board`_                         | HPC1                      |
+-----------------------------------------------------------------------+---------------------------+ 
 
Unlisted boards
===============

If you need more information on whether the `Ethernet FMC`_ is compatible with a carrier that is not listed above, please first check the
`compatibility list`_. If the carrier is not listed there, please `contact Opsero`_,
provide us with the pinout of your carrier and we'll be happy to check compatibility and generate a Vivado constraints file for you.

Using 2x Ethernet FMCs for 8-ports
==================================

The only evaluation boards that can support two Ethernet FMCs simultaneously are: 

* `KC705 Evaluation board`_
* `KCU105 Evaluation board`_
* `ZC702 Evaluation board`_ and 
* `VC707 Evaluation board`_.

This repository contains example designs for using 2 x Ethernet FMCs on the same carrier. They all use 8
Xilinx AXI Ethernet Subsystem IPs that are configured with DMAs, except for the ZC702 design, which is configured with FIFOs.
The reason for this is a lack of FPGA resources as using 8 MACs configured with DMAs requires more resources than is
contained in the Zynq device of that board.

These notes provide more details on 8-port support:

* The KC705 and VC707 each have two FMC connectors that support the Ethernet FMC (use kc705-lpc-hpc.xdc and vc707-hpc2-hpc1.xdc respectively).
* The KCU105 can support two Ethernet FMCs however the LPC only supports 3 ports so the dual design contains
  only 7 ports total.
* The ZC702 has two FMC connectors that can support the Ethernet FMC, however note that the Zynq device on this board has limited FPGA resources
  for supporting 8 x Xilinx AXI Ethernet IPs (ie. the MACs). The device has enough resources when the 8 MACs are configured with FIFOs, however there are insufficient
  resources to configure them with DMAs. Alternatively, you could use a MAC that requires less resources. (use zc702-lpc2-lpc1.xdc)
* The ZC706 has two FMC connectors, but only one (the LPC) can support the Ethernet FMC (see detail in board specific notes below).


Board specific notes
====================

AC701
-----

* The AC701's on-board Ethernet port is not connected in this design.
* This design includes a reset GPIO so that the MicroBlaze can reset itself from PetaLinux.

KC705
-----

* The KC705's on-board Ethernet port is connected to AXI EthernetLite IP in these designs.
* This design includes a reset GPIO so that the MicroBlaze can reset itself from PetaLinux.

VC707 & VC709
-------------

* These boards can only support the 1.8V version Ethernet FMC. The device on these boards have only HP (high-performance)
  I/Os which do not support 2.5V levels.

ZC706
-----

* Zynq-7000 `ZC706 Evaluation board`_ (HPC)

  * HPC connector: Pins LA18_CC and LA17_CC of the HPC connector are routed to non-clock-capable pins so they cannot
    properly receive the RGMII receive clocks for ports 2 and 3 of the Ethernet FMC. The constraints file zc706-hpc.xdc is
    provided for reference, however it will not pass compilation with the Xilinx tools due to this problem.

KCU105
------

* This board can only support the 1.8V version Ethernet FMC. The device on this board has only HP (high-performance)
  I/Os which do not support 2.5V levels.
* KCU105 board design for the LPC connector is configured for only 3 ports as there is a strange placement error which occurs when trying
  to build a design with 4 ports. The placement error has to do with IDELAYs and I have not reached a solution for this yet. There
  is no such problem with the HPC for this board.

ZCU102
------

* These designs support the ZCU102 Rev 1.0 and newer boards. Use a commit before 2016-02-13 for the older Rev-D board design.
  Note that the FMC pinouts differ between Rev 1.0 and Rev D: https://www.xilinx.com/support/answers/68050.html
* This board can only support the 1.8V version Ethernet FMC. The device on this board has only HP (high-performance)
  I/Os which do not support 2.5V levels.
* The HPC1 design only supports 2 ports due to the HPC1 pin assignment to the Zynq US+ (see constraints file for more details).

PicoZed
-------

This repository contains a Vivado design for these PicoZed versions: 7Z020, 7Z015 and 7Z030.
The main differences between the designs are described below:

* 7Z020: We use 4x AXI Ethernet IPs. The constraints file uses the 2.5V IO standards.
* 7Z015: We use 4x AXI Ethernet IPs. The constraints file uses the 2.5V IO standards.
* 7Z030: We use 4x AXI Ethernet IPs. The constraints file uses the 1.8V IO standards because this device has HP I/Os.

Installation of MicroZed, PicoZed and UltraZed board definition files
---------------------------------------------------------------------

To use the projects for the MicroZed, PicoZed and UltraZed, you must first install the board definition files
for those boards into your Vivado and Vitis installation.

The following folders contain the board definition files and can be found in this project repository at this location:

https://github.com/Avnet/bdf

* ``microzed_7010``
* ``microzed_7020``
* ``picozed_7010_fmc2``
* ``picozed_7015_fmc2``
* ``picozed_7020_fmc2``
* ``picozed_7030_fmc2``
* ``ultrazed_7ev_cc``

Copy those folders and their contents into the ``C:\Xilinx\Vivado\2020.2\data\boards\board_files`` folder (this may
be different on your machine, depending on your Vivado installation directory). You also need to make a copy into the
Vitis installation at this location: ``C:\Xilinx\Vitis\2020.2\data\boards\board_files``.

Microblaze design differences
-----------------------------

The designs for AC701, KC705, VC707, VC709, KCU105, VCU108 & VCU118 all use the Microblaze soft processor. These designs
have some specific differences when compared to the Zynq based designs:

* MIG - the MIG is required to exploit the DDR3/4 memory of the eval boards.
* AXI Timer - the lwIP echo server application requires a timer (Microblaze does not have one inherently).
* AXI UART16550 - the lwIP echo server application requires a UART for console output.


.. _contact Opsero: https://opsero.com/contact-us
.. _compatibility list: https://ethernetfmc.com/documentation/compatiblility.html
.. _Ethernet FMC: https://ethernetfmc.com
.. _ZedBoard: http://zedboard.org
.. _MicroZed FMC Carrier: http://zedboard.org/product/microzed-fmc-carrier
.. _MicroZed 7Z020: http://microzed.org
.. _PicoZed FMC Carrier Card V2: http://zedboard.org/product/picozed-fmc-carrier-card-v2
.. _PicoZed 7015/20/30: http://picozed.org
.. _UltraZed EV Carrier Card: http://zedboard.org/product/ultrazed-ev-carrier-card
.. _AC701 Evaluation board: https://www.xilinx.com/ac701
.. _KC705 Evaluation board: https://www.xilinx.com/kc705
.. _KCU105 Evaluation board: https://www.xilinx.com/kcu105
.. _VC707 Evaluation board: https://www.xilinx.com/vc707
.. _VC709 Evaluation board: https://www.xilinx.com/vc709
.. _ZC702 Evaluation board: https://www.xilinx.com/zc702
.. _ZC706 Evaluation board: https://www.xilinx.com/zc706
.. _ZCU102 Evaluation board: https://www.xilinx.com/zcu102
.. _VCU108 Evaluation board: https://www.xilinx.com/vcu108
.. _VCU118 Evaluation board: https://www.xilinx.com/vcu118
