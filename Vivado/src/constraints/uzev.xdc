# These constraints are suitable for UltraZed EV Carrier
# ------------------------------------------------------

# These constraints are for the UZEV-AXIETH design which
# uses 4x AXI Ethernet Subsystem IPs

# Notes on UltraZed EV Carrier HPC connector
# ------------------------------------------
#
# Ethernet FMC Port 0:
# --------------------
# * Requires LA00, LA02, LA03, LA04, LA05, LA06, LA07, LA08
# * All are routed to Bank 64
# * LA00 is routed to a clock capable pin
#
# Ethernet FMC Port 1:
# --------------------
# * Requires LA01, LA06, LA09, LA10, LA11, LA12, LA13, LA14, LA15, LA16
# * All are routed to Bank 64
# * LA01 is routed to a clock capable pin
#
# Ethernet FMC Port 2:
# --------------------
# * Requires LA17, LA19, LA20, LA21, LA22, LA23, LA24, LA25
# * All are routed to Bank 65
# * LA17 is routed to a clock capable pin
#
# Ethernet FMC Port 3:
# --------------------
# * Requires LA18, LA26, LA27, LA28, LA29, LA30, LA31, LA32
# * All are routed to Bank 65
# * LA18 is routed to a clock capable pin
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

set_property PACKAGE_PIN AC17 [get_ports {rgmii_port_1_rd[0]}]
set_property PACKAGE_PIN AC18 [get_ports mdio_io_port_0_mdio_io]
set_property PACKAGE_PIN AH16 [get_ports {rgmii_port_1_rd[2]}]
set_property PACKAGE_PIN AF15 [get_ports {ref_clk_fsel[0]}]
set_property PACKAGE_PIN AG15 [get_ports mdio_io_port_1_mdio_io]
set_property PACKAGE_PIN AH6 [get_ports rgmii_port_3_rxc]
set_property PACKAGE_PIN AJ6 [get_ports rgmii_port_3_rx_ctl]
set_property PACKAGE_PIN AG8 [get_ports {rgmii_port_3_rd[1]}]
set_property PACKAGE_PIN AH8 [get_ports {rgmii_port_3_rd[3]}]
set_property PACKAGE_PIN AD17 [get_ports rgmii_port_1_rxc]
set_property PACKAGE_PIN AE17 [get_ports rgmii_port_1_rx_ctl]
set_property PACKAGE_PIN AD19 [get_ports mdio_io_port_0_mdc]
set_property PACKAGE_PIN AE19 [get_ports reset_port_0]
set_property PACKAGE_PIN AK17 [get_ports {rgmii_port_1_rd[1]}]
set_property PACKAGE_PIN AK18 [get_ports {rgmii_port_1_rd[3]}]
set_property PACKAGE_PIN AJ15 [get_ports {ref_clk_oe[0]}]
set_property PACKAGE_PIN AK15 [get_ports mdio_io_port_1_mdc]
set_property PACKAGE_PIN AG6 [get_ports rgmii_port_2_rxc]
set_property PACKAGE_PIN AJ5 [get_ports {rgmii_port_2_rd[2]}]
set_property PACKAGE_PIN AK5 [get_ports {rgmii_port_2_rd[3]}]
set_property PACKAGE_PIN AK9 [get_ports {rgmii_port_3_rd[0]}]
set_property PACKAGE_PIN AK8 [get_ports {rgmii_port_3_rd[2]}]
set_property PACKAGE_PIN AF16 [get_ports rgmii_port_0_rxc]
set_property PACKAGE_PIN AF17 [get_ports rgmii_port_0_rx_ctl]
set_property PACKAGE_PIN AE18 [get_ports {rgmii_port_0_rd[2]}]
set_property PACKAGE_PIN AF18 [get_ports {rgmii_port_0_rd[3]}]
set_property PACKAGE_PIN AJ16 [get_ports {rgmii_port_0_td[1]}]
set_property PACKAGE_PIN AK16 [get_ports {rgmii_port_0_td[2]}]
set_property PACKAGE_PIN AK14 [get_ports {rgmii_port_1_td[0]}]
set_property PACKAGE_PIN AG13 [get_ports {rgmii_port_1_td[2]}]
set_property PACKAGE_PIN AH13 [get_ports {rgmii_port_1_td[3]}]
set_property PACKAGE_PIN AJ10 [get_ports rgmii_port_2_rx_ctl]
set_property PACKAGE_PIN AK10 [get_ports {rgmii_port_2_rd[0]}]
set_property PACKAGE_PIN AF12 [get_ports {rgmii_port_2_td[1]}]
set_property PACKAGE_PIN AF11 [get_ports {rgmii_port_2_td[2]}]
set_property PACKAGE_PIN AF6 [get_ports rgmii_port_2_tx_ctl]
set_property PACKAGE_PIN AF5 [get_ports mdio_io_port_2_mdio_io]
set_property PACKAGE_PIN AK4 [get_ports {rgmii_port_3_td[0]}]
set_property PACKAGE_PIN AF3 [get_ports {rgmii_port_3_td[2]}]
set_property PACKAGE_PIN AF2 [get_ports {rgmii_port_3_td[3]}]
set_property PACKAGE_PIN AG14 [get_ports ref_clk_clk_p]
set_property PACKAGE_PIN AH14 [get_ports ref_clk_clk_n]
set_property PACKAGE_PIN AG18 [get_ports {rgmii_port_0_rd[0]}]
set_property PACKAGE_PIN AH18 [get_ports {rgmii_port_0_rd[1]}]
set_property PACKAGE_PIN AH17 [get_ports {rgmii_port_0_td[0]}]
set_property PACKAGE_PIN AJ17 [get_ports rgmii_port_0_txc]
set_property PACKAGE_PIN AA16 [get_ports {rgmii_port_0_td[3]}]
set_property PACKAGE_PIN AB16 [get_ports rgmii_port_0_tx_ctl]
set_property PACKAGE_PIN AC16 [get_ports {rgmii_port_1_td[1]}]
set_property PACKAGE_PIN AD16 [get_ports rgmii_port_1_txc]
set_property PACKAGE_PIN AK13 [get_ports rgmii_port_1_tx_ctl]
set_property PACKAGE_PIN AK12 [get_ports reset_port_1]
set_property PACKAGE_PIN AF10 [get_ports {rgmii_port_2_rd[1]}]
set_property PACKAGE_PIN AG10 [get_ports {rgmii_port_2_td[0]}]
set_property PACKAGE_PIN AF8 [get_ports rgmii_port_2_txc]
set_property PACKAGE_PIN AF7 [get_ports {rgmii_port_2_td[3]}]
set_property PACKAGE_PIN AK7 [get_ports mdio_io_port_2_mdc]
set_property PACKAGE_PIN AK6 [get_ports reset_port_2]
set_property PACKAGE_PIN AJ11 [get_ports {rgmii_port_3_td[1]}]
set_property PACKAGE_PIN AK11 [get_ports rgmii_port_3_txc]
set_property PACKAGE_PIN AJ2 [get_ports rgmii_port_3_tx_ctl]
set_property PACKAGE_PIN AJ1 [get_ports mdio_io_port_3_mdc]
set_property PACKAGE_PIN AH9 [get_ports mdio_io_port_3_mdio_io]
set_property PACKAGE_PIN AJ9 [get_ports reset_port_3]

# For timing closure

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/delay_rgmii_tx_clk]
set_property DELAY_VALUE 1100 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/delay_rgmii_tx_clk]
set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_tx_clk]
set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/delay_rgmii_tx_clk]
