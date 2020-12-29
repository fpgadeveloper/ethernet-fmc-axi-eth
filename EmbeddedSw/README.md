Modified BSP files
==================

### lwIP modifications

This project uses a modified version of the lwIP library in order for it to work with the Marvel 88E1510/88E1518
PHYs on the Ethernet FMC.

A function is added to `xaxiemacif_physpeed.c` for the initialization of the Marvell 88E1510 Ethernet PHY

### AXI Ethernet driver modifications (applies to versions 5.6-5.11)

There is a bug in the TCL script for the AXI Ethernet driver since version 5.6 (released with Xilinx SDK 2017.3).

For designs using the AXI FIFO (instead of AXI DMA), the below script fails at line 234 because variable
`target_periph_name` is not defined. This repo contains a fix for the bug.

Location of the original TCL script for Vitis 2020.2:
`\Xilinx\Vitis\2020.2\data\embeddedsw\XilinxProcessorIPLib\drivers\axiethernet_v5_11\data\axiethernet.tcl`
