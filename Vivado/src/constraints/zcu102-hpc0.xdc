# These constraints are suitable for ZCU102 Rev 1.0 (use earlier commits for Rev D)
# ---------------------------------------------------------------------------------
# Note that FMC pinout for ZCU102 Rev 1.0 (first released with the ES2 device) differs
# from the ZCU102 Rev D (released with the ES1 device). See answer record for
# more information: https://www.xilinx.com/support/answers/68050.html

# These constraints are for the ZCU102-HPC0-AXIETH design which
# uses 4x AXI Ethernet Subsystem IPs

# Notes on ZCU102 HPC0 connector
# ------------------------------
#
# Ethernet FMC Port 0:
# --------------------
# * Requires LA00, LA02, LA03, LA04, LA05, LA06, LA07, LA08
# * All are routed to Bank 66
# * LA00 is routed to a clock capable pin
#
# Ethernet FMC Port 1:
# --------------------
# * Requires LA01, LA06, LA09, LA10, LA11, LA12, LA13, LA14, LA15, LA16
# * All are routed to Bank 66
# * LA01 is NOT routed to a clock capable pin
#
# Ethernet FMC Port 2:
# --------------------
# * Requires LA17, LA19, LA20, LA21, LA22, LA23, LA24, LA25
# * All are routed to Bank 67
# * LA17 is routed to a clock capable pin
#
# Ethernet FMC Port 3:
# --------------------
# * Requires LA18, LA26, LA27, LA28, LA29, LA30, LA31, LA32
# * All are routed to Bank 67
# * LA18 is NOT routed to a clock capable pin
#

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

set_property PACKAGE_PIN AC2 [get_ports {rgmii_port_1_rd[0]}]
set_property PACKAGE_PIN AC1 [get_ports mdio_io_port_0_mdio_io]
set_property PACKAGE_PIN W4 [get_ports {rgmii_port_1_rd[2]}]
set_property PACKAGE_PIN AC7 [get_ports {ref_clk_fsel[0]}]
set_property PACKAGE_PIN AC6 [get_ports mdio_io_port_1_mdio_io]
set_property PACKAGE_PIN N9 [get_ports rgmii_port_3_rxc]
set_property PACKAGE_PIN N8 [get_ports rgmii_port_3_rx_ctl]
set_property PACKAGE_PIN M10 [get_ports {rgmii_port_3_rd[1]}]
set_property PACKAGE_PIN L10 [get_ports {rgmii_port_3_rd[3]}]
set_property PACKAGE_PIN AB4 [get_ports rgmii_port_1_rxc]
set_property PACKAGE_PIN AC4 [get_ports rgmii_port_1_rx_ctl]
set_property PACKAGE_PIN AB3 [get_ports mdio_io_port_0_mdc]
set_property PACKAGE_PIN AC3 [get_ports reset_port_0]
set_property PACKAGE_PIN W2 [get_ports {rgmii_port_1_rd[1]}]
set_property PACKAGE_PIN W1 [get_ports {rgmii_port_1_rd[3]}]
set_property PACKAGE_PIN AB8 [get_ports {ref_clk_oe[0]}]
set_property PACKAGE_PIN AC8 [get_ports mdio_io_port_1_mdc]
set_property PACKAGE_PIN P11 [get_ports rgmii_port_2_rxc]
set_property PACKAGE_PIN L16 [get_ports {rgmii_port_2_rd[2]}]
set_property PACKAGE_PIN K16 [get_ports {rgmii_port_2_rd[3]}]
set_property PACKAGE_PIN L15 [get_ports {rgmii_port_3_rd[0]}]
set_property PACKAGE_PIN K15 [get_ports {rgmii_port_3_rd[2]}]
set_property PACKAGE_PIN Y4 [get_ports rgmii_port_0_rxc]
set_property PACKAGE_PIN Y3 [get_ports rgmii_port_0_rx_ctl]
set_property PACKAGE_PIN Y2 [get_ports {rgmii_port_0_rd[2]}]
set_property PACKAGE_PIN Y1 [get_ports {rgmii_port_0_rd[3]}]
set_property PACKAGE_PIN V4 [get_ports {rgmii_port_0_td[1]}]
set_property PACKAGE_PIN V3 [get_ports {rgmii_port_0_td[2]}]
set_property PACKAGE_PIN W6 [get_ports {rgmii_port_1_td[0]}]
set_property PACKAGE_PIN Y12 [get_ports {rgmii_port_1_td[2]}]
set_property PACKAGE_PIN AA12 [get_ports {rgmii_port_1_td[3]}]
set_property PACKAGE_PIN N13 [get_ports rgmii_port_2_rx_ctl]
set_property PACKAGE_PIN M13 [get_ports {rgmii_port_2_rd[0]}]
set_property PACKAGE_PIN M15 [get_ports {rgmii_port_2_td[1]}]
set_property PACKAGE_PIN M14 [get_ports {rgmii_port_2_td[2]}]
set_property PACKAGE_PIN M11 [get_ports rgmii_port_2_tx_ctl]
set_property PACKAGE_PIN L11 [get_ports mdio_io_port_2_mdio_io]
set_property PACKAGE_PIN U8 [get_ports {rgmii_port_3_td[0]}]
set_property PACKAGE_PIN V8 [get_ports {rgmii_port_3_td[2]}]
set_property PACKAGE_PIN V7 [get_ports {rgmii_port_3_td[3]}]
set_property PACKAGE_PIN AA7 [get_ports ref_clk_clk_p]
set_property PACKAGE_PIN AA6 [get_ports ref_clk_clk_n]
set_property PACKAGE_PIN V2 [get_ports {rgmii_port_0_rd[0]}]
set_property PACKAGE_PIN V1 [get_ports {rgmii_port_0_rd[1]}]
set_property PACKAGE_PIN AA2 [get_ports {rgmii_port_0_td[0]}]
set_property PACKAGE_PIN AA1 [get_ports rgmii_port_0_txc]
set_property PACKAGE_PIN U5 [get_ports {rgmii_port_0_td[3]}]
set_property PACKAGE_PIN U4 [get_ports rgmii_port_0_tx_ctl]
set_property PACKAGE_PIN AB6 [get_ports {rgmii_port_1_td[1]}]
set_property PACKAGE_PIN AB5 [get_ports rgmii_port_1_txc]
set_property PACKAGE_PIN Y10 [get_ports rgmii_port_1_tx_ctl]
set_property PACKAGE_PIN Y9 [get_ports reset_port_1]
set_property PACKAGE_PIN L13 [get_ports {rgmii_port_2_rd[1]}]
set_property PACKAGE_PIN K13 [get_ports {rgmii_port_2_td[0]}]
set_property PACKAGE_PIN P12 [get_ports rgmii_port_2_txc]
set_property PACKAGE_PIN N12 [get_ports {rgmii_port_2_td[3]}]
set_property PACKAGE_PIN L12 [get_ports mdio_io_port_2_mdc]
set_property PACKAGE_PIN K12 [get_ports reset_port_2]
set_property PACKAGE_PIN T7 [get_ports {rgmii_port_3_td[1]}]
set_property PACKAGE_PIN T6 [get_ports rgmii_port_3_txc]
set_property PACKAGE_PIN V6 [get_ports rgmii_port_3_tx_ctl]
set_property PACKAGE_PIN U6 [get_ports mdio_io_port_3_mdc]
set_property PACKAGE_PIN U11 [get_ports mdio_io_port_3_mdio_io]
set_property PACKAGE_PIN T11 [get_ports reset_port_3]

# Constraints suggested by AR#65947 http://www.xilinx.com/support/answers/65947.html

# BUFG on 200 MHz input clock
set_property CLOCK_REGION X3Y2 [get_cells *_i/clk_wiz_0/inst/clkout2_buf]
# BUFG on GTX Clock
# Commented below because I removed the BUFG from clk_wiz_0 output 1 (in effort to save BUFG)
#set_property CLOCK_REGION X3Y3      [get_cells *_i/clk_wiz_0/inst/clkout1_buf]
# BUFG on RX Clock input
set_property CLOCK_REGION X3Y2 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
set_property CLOCK_REGION X3Y2 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]

set_property CLOCK_REGION X3Y2 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
set_property CLOCK_REGION X3Y2 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]

set_property CLOCK_REGION X3Y3 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/bufg_rgmii_rx_clk]
set_property CLOCK_REGION X3Y3 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/bufg_rgmii_rx_clk_iddr]

set_property CLOCK_REGION X3Y3 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
set_property CLOCK_REGION X3Y3 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]

# Clock definitions

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]

# BITSLICE0 not available during BISC - The port rgmii_port_1_rxc is assigned to a PACKAGE_PIN that uses BITSLICE_1 of
# a Byte that will be using calibration. The signal connected to rgmii_port_1_rxc will not be available during calibration
# and will only be available after RDY asserts. If this condition is not acceptable for your design and board layout,
# rgmii_port_1_rxc will have to be moved to another PACKAGE_PIN that is not undergoing calibration or be moved to a
# PACKAGE_PIN location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition is acceptable for your
# design and board layout, this DRC can be bypassed by acknowledging the condition and setting the following XDC constraint:

set_property UNAVAILABLE_DURING_CALIBRATION true [get_ports rgmii_port_1_rxc]
set_property UNAVAILABLE_DURING_CALIBRATION true [get_ports rgmii_port_3_rxc]

# Specify the BUFGCE to use for RGMII RX clocks (Vivado itself doesn't choose the best ones and timing fails)
set_property LOC BUFGCE_X0Y67 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
set_property LOC BUFGCE_X0Y66 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
set_property LOC BUFGCE_X0Y65 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
set_property LOC BUFGCE_X0Y64 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
set_property LOC BUFGCE_X0Y95 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/bufg_rgmii_rx_clk_iddr]
set_property LOC BUFGCE_X0Y94 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/bufg_rgmii_rx_clk]
set_property LOC BUFGCE_X0Y87 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
set_property LOC BUFGCE_X0Y86 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]

# Adjustment to the IDELAYs to make the timing pass
set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

