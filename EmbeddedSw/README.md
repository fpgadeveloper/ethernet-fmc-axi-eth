Modified BSP files
==================

### lwIP modifications

The lwIP sources need a few small modifications to make it work with the Ethernet FMC.

A function is added to `xaxiemacif_physpeed.c` for the initialization of the Marvell 88E1510 Ethernet PHY

### AXI Ethernet driver modifications (applies only to versions 5.6, 5.7, 5.8 and 5.9)

There is a bug in the TCL script for the AXI Ethernet driver since version 5.6 (released with Xilinx SDK 2017.3).

For designs using the AXI FIFO (instead of AXI DMA), the below script fails at line 234 because variable
`target_periph_name` is not defined. This repo contains a fix for the bug.

Location of the original TCL script for SDK 2019.1:
`\Xilinx\SDK\2019.1\data\embeddedsw\XilinxProcessorIPLib\drivers\axiethernet_v5_9\data\axiethernet.tcl`
