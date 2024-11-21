Modified BSP files
==================

### lwIP modifications

This project uses a modified version of the lwIP library in order for it to work with the Marvel 88E1510/88E1518
PHYs on the Ethernet FMC.

A function is added to `xaxiemacif_physpeed.c` for the initialization of the Marvell 88E1510 Ethernet PHY

### AXI Ethernet driver modifications (applies to versions 5.6-5.17)

For designs using the AXI FIFO (instead of AXI DMA), the `axiethernet.tcl` script requires correcting for the
following issues:

1. Variable `target_periph_name` is not defined in function `xdefine_axi_target_params`. This causes the script
to fail for the case when the device is Zynq and FIFO is used.
2. FIFO interrupt IDs are not correctly defined for the case when the device is ZynqMP and FIFO is used. This
is because the interrupt controller for ZynqMP is `psu_acpu_gic`, but this is not checked for, hence this case
is treated as a non-Zynq case.

Both issues are corrected by the sources in this repo. Location of the original TCL script for Vitis 2024.1:
`\Xilinx\Vitis\2024.1\data\embeddedsw\XilinxProcessorIPLib\drivers\axiethernet_v5_17\data\axiethernet.tcl`
