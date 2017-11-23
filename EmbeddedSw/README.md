Modified BSP files
==================

### lwIP modifications

The lwIP sources need a few small modifications to make it work with the Ethernet FMC.

1. A function is added to `xaxiemacif_physpeed.c` for the initialization of the Marvell 88E1510 Ethernet PHY
2. A fix is applied to `xaxiemacif_dma.c` to allow it to work with multiple ports

### AXI Ethernet driver modifications (applies only to version 5.6)

There is a bug in the TCL script for the AXI Ethernet driver version 5.6 (released with Xilinx SDK 2017.3).

For designs using the AXI FIFO (instead of AXI DMA), the below script fails at line 234 because variable
`target_periph_name` is not defined. This repo contains a fix for the bug.

`\Xilinx\SDK\2017.3\data\embeddedsw\XilinxProcessorIPLib\drivers\axiethernet_v5_6\data\axiethernet.tcl`
