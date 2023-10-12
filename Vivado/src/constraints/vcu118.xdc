# These constraints are suitable for VCU118
# -----------------------------------------
# These constraints are for the vcu118-axieth design which
# uses 4x AXI Ethernet Subsystem IPs

# Notes on VCU118 HPC1 connector
# ------------------------------
#
# Ethernet FMC Port 0:
# --------------------
# * Requires LA00_CC, LA02, LA03, LA04, LA05, LA06, LA07, LA08
# * All are routed to Bank 66
# * LA00_CC is routed to a clock capable pin
#
# Ethernet FMC Port 1:
# --------------------
# * Requires LA01_CC, LA06, LA09, LA10, LA11, LA12, LA13, LA14, LA15, LA16
# * All are routed to Bank 66
# * LA01_CC is NOT routed to a clock capable pin
#
# Ethernet FMC Port 2:
# --------------------
# * Requires LA17_CC, LA19, LA20, LA21, LA22, LA23, LA24, LA25
# * All are routed to Bank 67
# * LA17_CC is routed to a clock capable pin
#
# Ethernet FMC Port 3:
# --------------------
# * Requires LA18_CC, LA26, LA27, LA28, LA29, LA30, LA31, LA32
# * All are routed to Bank 67
# * LA18_CC is NOT routed to a clock capable pin
#

# Enable internal termination resistor on LVDS 125MHz ref_clk
set_property DIFF_TERM TRUE [get_ports ref_clk_clk_p]
set_property DIFF_TERM TRUE [get_ports ref_clk_clk_n]

# Define I/O standards
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_0_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ref_clk_fsel[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_1_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_0_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_0]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ref_clk_oe[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_1_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_2_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[3]}]
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
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_txc]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_2_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_2]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_txc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_3_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_3_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_3]

set_property PACKAGE_PIN BD13 [get_ports {rgmii_port_1_rd[0]}]
set_property PACKAGE_PIN BE13 [get_ports mdio_io_port_0_mdio_io]
set_property PACKAGE_PIN BB12 [get_ports {rgmii_port_1_rd[2]}]
set_property PACKAGE_PIN AW8 [get_ports {ref_clk_fsel[0]}]
set_property PACKAGE_PIN AW7 [get_ports mdio_io_port_1_mdio_io]
set_property PACKAGE_PIN AP12 [get_ports rgmii_port_3_rxc]
set_property PACKAGE_PIN AR12 [get_ports rgmii_port_3_rx_ctl]
set_property PACKAGE_PIN AL14 [get_ports {rgmii_port_3_rd[1]}]
set_property PACKAGE_PIN AM14 [get_ports {rgmii_port_3_rd[3]}]
set_property PACKAGE_PIN BF10 [get_ports rgmii_port_1_rxc]
set_property PACKAGE_PIN BF9 [get_ports rgmii_port_1_rx_ctl]
set_property PACKAGE_PIN BE14 [get_ports mdio_io_port_0_mdc]
set_property PACKAGE_PIN BF14 [get_ports reset_port_0]
set_property PACKAGE_PIN BA14 [get_ports {rgmii_port_1_rd[1]}]
set_property PACKAGE_PIN BB14 [get_ports {rgmii_port_1_rd[3]}]
set_property PACKAGE_PIN AY8 [get_ports {ref_clk_oe[0]}]
set_property PACKAGE_PIN AY7 [get_ports mdio_io_port_1_mdc]
set_property PACKAGE_PIN AR14 [get_ports rgmii_port_2_rxc]
set_property PACKAGE_PIN AN16 [get_ports {rgmii_port_2_rd[2]}]
set_property PACKAGE_PIN AP16 [get_ports {rgmii_port_2_rd[3]}]
set_property PACKAGE_PIN AK15 [get_ports {rgmii_port_3_rd[0]}]
set_property PACKAGE_PIN AL15 [get_ports {rgmii_port_3_rd[2]}]
set_property PACKAGE_PIN AY9 [get_ports rgmii_port_0_rxc]
set_property PACKAGE_PIN BA9 [get_ports rgmii_port_0_rx_ctl]
set_property PACKAGE_PIN BD12 [get_ports {rgmii_port_0_rd[2]}]
set_property PACKAGE_PIN BE12 [get_ports {rgmii_port_0_rd[3]}]
set_property PACKAGE_PIN BE15 [get_ports {rgmii_port_0_td[1]}]
set_property PACKAGE_PIN BF15 [get_ports {rgmii_port_0_td[2]}]
set_property PACKAGE_PIN BC13 [get_ports {rgmii_port_1_td[0]}]
set_property PACKAGE_PIN AV9 [get_ports {rgmii_port_1_td[2]}]
set_property PACKAGE_PIN AV8 [get_ports {rgmii_port_1_td[3]}]
set_property PACKAGE_PIN AW11 [get_ports rgmii_port_2_rx_ctl]
set_property PACKAGE_PIN AY10 [get_ports {rgmii_port_2_rd[0]}]
set_property PACKAGE_PIN AW13 [get_ports {rgmii_port_2_td[1]}]
set_property PACKAGE_PIN AY13 [get_ports {rgmii_port_2_td[2]}]
set_property PACKAGE_PIN AT12 [get_ports rgmii_port_2_tx_ctl]
set_property PACKAGE_PIN AU12 [get_ports mdio_io_port_2_mdio_io]
set_property PACKAGE_PIN AP15 [get_ports {rgmii_port_3_td[0]}]
set_property PACKAGE_PIN AM13 [get_ports {rgmii_port_3_td[2]}]
set_property PACKAGE_PIN AM12 [get_ports {rgmii_port_3_td[3]}]
set_property PACKAGE_PIN BC9 [get_ports ref_clk_clk_p]
set_property PACKAGE_PIN BC8 [get_ports ref_clk_clk_n]
set_property PACKAGE_PIN BC11 [get_ports {rgmii_port_0_rd[0]}]
set_property PACKAGE_PIN BD11 [get_ports {rgmii_port_0_rd[1]}]
set_property PACKAGE_PIN BF12 [get_ports {rgmii_port_0_td[0]}]
set_property PACKAGE_PIN BF11 [get_ports rgmii_port_0_txc]
set_property PACKAGE_PIN BC15 [get_ports {rgmii_port_0_td[3]}]
set_property PACKAGE_PIN BD15 [get_ports rgmii_port_0_tx_ctl]
set_property PACKAGE_PIN BA16 [get_ports {rgmii_port_1_td[1]}]
set_property PACKAGE_PIN BA15 [get_ports rgmii_port_1_txc]
set_property PACKAGE_PIN BB16 [get_ports rgmii_port_1_tx_ctl]
set_property PACKAGE_PIN BC16 [get_ports reset_port_1]
set_property PACKAGE_PIN AW12 [get_ports {rgmii_port_2_rd[1]}]
set_property PACKAGE_PIN AY12 [get_ports {rgmii_port_2_td[0]}]
set_property PACKAGE_PIN AU11 [get_ports rgmii_port_2_txc]
set_property PACKAGE_PIN AV11 [get_ports {rgmii_port_2_td[3]}]
set_property PACKAGE_PIN AP13 [get_ports mdio_io_port_2_mdc]
set_property PACKAGE_PIN AR13 [get_ports reset_port_2]
set_property PACKAGE_PIN AV10 [get_ports {rgmii_port_3_td[1]}]
set_property PACKAGE_PIN AW10 [get_ports rgmii_port_3_txc]
set_property PACKAGE_PIN AK12 [get_ports rgmii_port_3_tx_ctl]
set_property PACKAGE_PIN AL12 [get_ports mdio_io_port_3_mdc]
set_property PACKAGE_PIN AJ13 [get_ports mdio_io_port_3_mdio_io]
set_property PACKAGE_PIN AJ12 [get_ports reset_port_3]

# Demote the error created by the sub-optimal RXC clock assignment
# -------------------------------------------------------------------
# The VCU118 HPC FMC connector routes LA01_CC and LA18_CC to 
# non-clock capable pins, creating the following error:
#
# ERROR: Sub-optimal placement for a global clock-capable IO pin 
# and BUFG pair.If this sub optimal condition is acceptable for this 
# design, you may use the CLOCK_DEDICATED_ROUTE constraint in the 
# .xdc file to demote this message to a WARNING. However, the use 
# of this override is highly discouraged. These examples can be used 
# directly in the .xdc file to override this clock rule.

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]
 
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]


# Rule violation (PDRC-203) BITSLICE0 not available during BISC - 
# The port mdio_io_port_3_mdio_io is assigned to a PACKAGE_PIN that 
# uses BITSLICE_1 of a Byte that will be using calibration. The 
# signal connected to mdio_io_port_3_mdio_io will not be available 
# during calibration and will only be available after RDY asserts. 
# If this condition is not acceptable for your design and board 
# layout, mdio_io_port_3_mdio_io will have to be moved to another 
# PACKAGE_PIN that is not undergoing calibration or be moved to a 
# PACKAGE_PIN location that is not BITSLICE_0 or BITSLICE_6 on 
# that same Byte. If this condition is acceptable for your design 
# and board layout, this DRC can be bypassed by acknowledging the 
# condition and setting the following XDC constraint: 

set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports mdio_io_port_3_mdio_io]

set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports rgmii_port_1_rxc]

set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports rgmii_port_3_rxc]

# The following constraints help timing closure on ports 1 and 3

set_property CLOCK_REGION X4Y7 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
set_property CLOCK_REGION X4Y8 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]

set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]
set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl}]

set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]
set_property DELAY_VALUE 1100 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl}]

# For timing closure on port 2

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_2/inst/mac/inst/rgmii_interface/delay_rgmii_tx_clk]

# Configuration via Quad SPI flash for VCU118
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

