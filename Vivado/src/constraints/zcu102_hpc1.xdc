# These constraints are suitable for ZCU102 Rev 1.0 and newer boards
# ------------------------------------------------------------------
# Note that FMC pinout for ZCU102 Rev 1.0 (first released with the ES2 device) differs
# from the ZCU102 Rev D (released with the ES1 device). See answer record for
# more information: https://www.xilinx.com/support/answers/68050.html

# These constraints are for the ZCU102-HPC1-AXIETH design which
# uses 2x AXI Ethernet Subsystem IPs

# Notes on ZCU102 HPC1 connector
# ------------------------------
# 
# Ethernet FMC Port 0:
# --------------------
# * Requires LA00, LA02, LA03, LA04, LA05, LA06, LA07, LA08
# * All are routed to Bank 65
# * LA00 is routed to a clock capable pin
# 
# Ethernet FMC Port 1:
# --------------------
# * Requires LA01, LA06, LA09, LA10, LA11, LA12, LA13, LA14, LA15, LA16
# * All are routed to Bank 65
# * LA01 is NOT routed to a clock capable pin
# 
# Ethernet FMC Port 2:
# --------------------
# * Requires LA17, LA19, LA20, LA21, LA22, LA23, LA24, LA25
# * LA22, LA23, LA24, LA25 are routed to Bank 65
# * LA17, LA19, LA20, LA21 are routed to Bank 66
# * LA17 is routed to a clock capable pin
# 
# Ethernet FMC Port 3:
# --------------------
# * Requires LA18, LA26, LA27, LA28, LA29, LA30, LA31, LA32
# * LA30, LA31 and LA32 are not connected on the ZCU102
# * Port 3 cannot be used due to the missing connections
# 
# Port 2 cannot be used in this design because its RGMII pins are connected to separate I/O banks
# on the FPGA. When trying to create a design to use Port 2, we get this Critical Warning message:
# ------------------------------------------------------------------------------------------------
# Cannot set LOC property of ports, Could not legally place terminal rgmii_port_2_txc at AC12 (IOB_X1Y104) 
# since it belongs to a shape containing instance 
# zcu102_hpc1_axieth_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_tx_clk_casc.
# The shape requires relative placement between rgmii_port_2_txc and 
# zcu102_hpc1_axieth_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_tx_clk_casc 
# that can not be honoured because it would result in an invalid location for 
# zcu102_hpc1_axieth_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_tx_clk_casc.

# Enable internal termination resistor on LVDS 125MHz ref_clk
set_property DIFF_TERM TRUE [get_ports ref_clk_clk_p]
set_property DIFF_TERM TRUE [get_ports ref_clk_clk_n]

# Define I/O standards
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_0_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ref_clk_fsel[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_1_mdio_io]
#set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_rxc]
#set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_rx_ctl]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_0_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_0]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ref_clk_oe[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_1_mdc]
#set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_rxc]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[2]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[3]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[3]}]
#set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_rx_ctl]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[2]}]
#set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_tx_ctl]
#set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_2_mdio_io]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[2]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[3]}]
set_property IOSTANDARD LVDS [get_ports ref_clk_clk_p]
set_property IOSTANDARD LVDS [get_ports ref_clk_clk_n]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_txc]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_txc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_1]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_txc]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[3]}]
#set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_2_mdc]
#set_property IOSTANDARD LVCMOS18 [get_ports reset_port_2]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_txc]
#set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_tx_ctl]
#set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_3_mdc]
#set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_3_mdio_io]
#set_property IOSTANDARD LVCMOS18 [get_ports reset_port_3]

set_property PACKAGE_PIN AH2 [get_ports {rgmii_port_1_rd[0]}]
set_property PACKAGE_PIN AJ2 [get_ports mdio_io_port_0_mdio_io]
set_property PACKAGE_PIN AJ4 [get_ports {rgmii_port_1_rd[2]}]
set_property PACKAGE_PIN AH7 [get_ports {ref_clk_fsel[0]}]
set_property PACKAGE_PIN AH6 [get_ports mdio_io_port_1_mdio_io]
#set_property PACKAGE_PIN Y8 [get_ports rgmii_port_3_rxc]
#set_property PACKAGE_PIN Y7 [get_ports rgmii_port_3_rx_ctl]
#set_property PACKAGE_PIN U10 [get_ports {rgmii_port_3_rd[1]}]
#set_property PACKAGE_PIN T10 [get_ports {rgmii_port_3_rd[3]}]
set_property PACKAGE_PIN AJ6 [get_ports rgmii_port_1_rxc]
set_property PACKAGE_PIN AJ5 [get_ports rgmii_port_1_rx_ctl]
set_property PACKAGE_PIN AG3 [get_ports mdio_io_port_0_mdc]
set_property PACKAGE_PIN AH3 [get_ports reset_port_0]
set_property PACKAGE_PIN AE2 [get_ports {rgmii_port_1_rd[1]}]
set_property PACKAGE_PIN AE1 [get_ports {rgmii_port_1_rd[3]}]
set_property PACKAGE_PIN AG8 [get_ports {ref_clk_oe[0]}]
set_property PACKAGE_PIN AH8 [get_ports mdio_io_port_1_mdc]
#set_property PACKAGE_PIN Y5 [get_ports rgmii_port_2_rxc]
#set_property PACKAGE_PIN AE12 [get_ports {rgmii_port_2_rd[2]}]
#set_property PACKAGE_PIN AF12 [get_ports {rgmii_port_2_rd[3]}]
#set_property PACKAGE_PIN T12 [get_ports {rgmii_port_3_rd[0]}]
#set_property PACKAGE_PIN R12 [get_ports {rgmii_port_3_rd[2]}]
set_property PACKAGE_PIN AE5 [get_ports rgmii_port_0_rxc]
set_property PACKAGE_PIN AF5 [get_ports rgmii_port_0_rx_ctl]
set_property PACKAGE_PIN AH1 [get_ports {rgmii_port_0_rd[2]}]
set_property PACKAGE_PIN AJ1 [get_ports {rgmii_port_0_rd[3]}]
set_property PACKAGE_PIN AE3 [get_ports {rgmii_port_0_td[1]}]
set_property PACKAGE_PIN AF3 [get_ports {rgmii_port_0_td[2]}]
set_property PACKAGE_PIN AD6 [get_ports {rgmii_port_1_td[0]}]
set_property PACKAGE_PIN AG10 [get_ports {rgmii_port_1_td[2]}]
set_property PACKAGE_PIN AG9 [get_ports {rgmii_port_1_td[3]}]
#set_property PACKAGE_PIN AB11 [get_ports rgmii_port_2_rx_ctl]
#set_property PACKAGE_PIN AB10 [get_ports {rgmii_port_2_rd[0]}]
#set_property PACKAGE_PIN AF11 [get_ports {rgmii_port_2_td[1]}]
#set_property PACKAGE_PIN AG11 [get_ports {rgmii_port_2_td[2]}]
#set_property PACKAGE_PIN AE10 [get_ports rgmii_port_2_tx_ctl]
#set_property PACKAGE_PIN AF10 [get_ports mdio_io_port_2_mdio_io]
#set_property PACKAGE_PIN W11 [get_ports {rgmii_port_3_td[0]}]
set_property PACKAGE_PIN AE7 [get_ports ref_clk_clk_p]
set_property PACKAGE_PIN AF7 [get_ports ref_clk_clk_n]
set_property PACKAGE_PIN AD2 [get_ports {rgmii_port_0_rd[0]}]
set_property PACKAGE_PIN AD1 [get_ports {rgmii_port_0_rd[1]}]
set_property PACKAGE_PIN AF2 [get_ports {rgmii_port_0_td[0]}]
set_property PACKAGE_PIN AF1 [get_ports rgmii_port_0_txc]
set_property PACKAGE_PIN AD4 [get_ports {rgmii_port_0_td[3]}]
set_property PACKAGE_PIN AE4 [get_ports rgmii_port_0_tx_ctl]
set_property PACKAGE_PIN AE8 [get_ports {rgmii_port_1_td[1]}]
set_property PACKAGE_PIN AF8 [get_ports rgmii_port_1_txc]
set_property PACKAGE_PIN AD10 [get_ports rgmii_port_1_tx_ctl]
set_property PACKAGE_PIN AE9 [get_ports reset_port_1]
#set_property PACKAGE_PIN AA11 [get_ports {rgmii_port_2_rd[1]}]
#set_property PACKAGE_PIN AA10 [get_ports {rgmii_port_2_td[0]}]
#set_property PACKAGE_PIN AC12 [get_ports rgmii_port_2_txc]
#set_property PACKAGE_PIN AC11 [get_ports {rgmii_port_2_td[3]}]
#set_property PACKAGE_PIN AH12 [get_ports mdio_io_port_2_mdc]
#set_property PACKAGE_PIN AH11 [get_ports reset_port_2]
#set_property PACKAGE_PIN T13 [get_ports {rgmii_port_3_td[1]}]
#set_property PACKAGE_PIN R13 [get_ports rgmii_port_3_txc]

# Clock definitions

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]

# BITSLICE0 not available during BISC - The port rgmii_port_1_rxc is assigned to a PACKAGE_PIN that uses BITSLICE_1 of
# a Byte that will be using calibration. The signal connected to rgmii_port_1_rxc will not be available during calibration
# and will only be available after RDY asserts. If this condition is not acceptable for your design and board layout,
# rgmii_port_1_rxc will have to be moved to another PACKAGE_PIN that is not undergoing calibration or be moved to a
# PACKAGE_PIN location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition is acceptable for your
# design and board layout, this DRC can be bypassed by acknowledging the condition and setting the following XDC constraint:

set_property UNAVAILABLE_DURING_CALIBRATION true [get_ports rgmii_port_1_rxc]

# Specify the BUFGCE to use for RGMII RX clocks (Vivado itself doesn't choose the best ones and timing fails)
set_property LOC BUFGCE_X0Y47 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
set_property LOC BUFGCE_X0Y46 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]

# Adjustment to the IDELAYs to make the timing pass
set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]
