# Enable internal termination resistor on LVDS 125MHz ref_clk
set_property DIFF_TERM TRUE [get_ports ref_clk_p]
set_property DIFF_TERM TRUE [get_ports ref_clk_n]

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
set_property IOSTANDARD LVDS [get_ports ref_clk_p]
set_property IOSTANDARD LVDS [get_ports ref_clk_n]
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

set_property PACKAGE_PIN K42 [get_ports {rgmii_port_1_rd[0]}]
set_property PACKAGE_PIN J42 [get_ports mdio_io_port_0_mdio_io]
set_property PACKAGE_PIN M39 [get_ports {rgmii_port_1_rd[2]}]
set_property PACKAGE_PIN N39 [get_ports {ref_clk_fsel[0]}]
set_property PACKAGE_PIN N40 [get_ports mdio_io_port_1_mdio_io]
set_property PACKAGE_PIN M32 [get_ports rgmii_port_3_rxc]
set_property PACKAGE_PIN L32 [get_ports rgmii_port_3_rx_ctl]
set_property PACKAGE_PIN J31 [get_ports {rgmii_port_3_rd[1]}]
set_property PACKAGE_PIN H31 [get_ports {rgmii_port_3_rd[3]}]
set_property PACKAGE_PIN J40 [get_ports rgmii_port_1_rxc]
set_property PACKAGE_PIN J41 [get_ports rgmii_port_1_rx_ctl]
set_property PACKAGE_PIN M41 [get_ports mdio_io_port_0_mdc]
set_property PACKAGE_PIN L41 [get_ports reset_port_0]
set_property PACKAGE_PIN R42 [get_ports {rgmii_port_1_rd[1]}]
set_property PACKAGE_PIN P42 [get_ports {rgmii_port_1_rd[3]}]
set_property PACKAGE_PIN H39 [get_ports {ref_clk_oe[0]}]
set_property PACKAGE_PIN G39 [get_ports mdio_io_port_1_mdc]
set_property PACKAGE_PIN L31 [get_ports rgmii_port_2_rxc]
set_property PACKAGE_PIN P30 [get_ports {rgmii_port_2_rd[2]}]
set_property PACKAGE_PIN N31 [get_ports {rgmii_port_2_rd[3]}]
set_property PACKAGE_PIN J30 [get_ports {rgmii_port_3_rd[0]}]
set_property PACKAGE_PIN H30 [get_ports {rgmii_port_3_rd[2]}]
set_property PACKAGE_PIN K39 [get_ports rgmii_port_0_rxc]
set_property PACKAGE_PIN K40 [get_ports rgmii_port_0_rx_ctl]
set_property PACKAGE_PIN M42 [get_ports {rgmii_port_0_rd[2]}]
set_property PACKAGE_PIN L42 [get_ports {rgmii_port_0_rd[3]}]
set_property PACKAGE_PIN M37 [get_ports {rgmii_port_0_td[1]}]
set_property PACKAGE_PIN M38 [get_ports {rgmii_port_0_td[2]}]
set_property PACKAGE_PIN P40 [get_ports {rgmii_port_1_td[0]}]
set_property PACKAGE_PIN K37 [get_ports {rgmii_port_1_td[2]}]
set_property PACKAGE_PIN K38 [get_ports {rgmii_port_1_td[3]}]
set_property PACKAGE_PIN Y29 [get_ports rgmii_port_2_rx_ctl]
set_property PACKAGE_PIN Y30 [get_ports {rgmii_port_2_rd[0]}]
set_property PACKAGE_PIN R28 [get_ports {rgmii_port_2_td[1]}]
set_property PACKAGE_PIN P28 [get_ports {rgmii_port_2_td[2]}]
set_property PACKAGE_PIN K29 [get_ports rgmii_port_2_tx_ctl]
set_property PACKAGE_PIN K30 [get_ports mdio_io_port_2_mdio_io]
set_property PACKAGE_PIN T30 [get_ports {rgmii_port_3_td[0]}]
set_property PACKAGE_PIN M28 [get_ports {rgmii_port_3_td[2]}]
set_property PACKAGE_PIN M29 [get_ports {rgmii_port_3_td[3]}]
set_property PACKAGE_PIN L39 [get_ports ref_clk_p]
set_property PACKAGE_PIN L40 [get_ports ref_clk_n]
set_property PACKAGE_PIN P41 [get_ports {rgmii_port_0_rd[0]}]
set_property PACKAGE_PIN N41 [get_ports {rgmii_port_0_rd[1]}]
set_property PACKAGE_PIN H40 [get_ports {rgmii_port_0_td[0]}]
set_property PACKAGE_PIN H41 [get_ports rgmii_port_0_txc]
set_property PACKAGE_PIN G41 [get_ports {rgmii_port_0_td[3]}]
set_property PACKAGE_PIN G42 [get_ports rgmii_port_0_tx_ctl]
set_property PACKAGE_PIN F40 [get_ports {rgmii_port_1_td[1]}]
set_property PACKAGE_PIN F41 [get_ports rgmii_port_1_txc]
set_property PACKAGE_PIN M36 [get_ports rgmii_port_1_tx_ctl]
set_property PACKAGE_PIN L37 [get_ports reset_port_1]
set_property PACKAGE_PIN W30 [get_ports {rgmii_port_2_rd[1]}]
set_property PACKAGE_PIN W31 [get_ports {rgmii_port_2_td[0]}]
set_property PACKAGE_PIN N28 [get_ports rgmii_port_2_txc]
set_property PACKAGE_PIN N29 [get_ports {rgmii_port_2_td[3]}]
set_property PACKAGE_PIN R30 [get_ports mdio_io_port_2_mdc]
set_property PACKAGE_PIN P31 [get_ports reset_port_2]
set_property PACKAGE_PIN L29 [get_ports {rgmii_port_3_td[1]}]
set_property PACKAGE_PIN L30 [get_ports rgmii_port_3_txc]
set_property PACKAGE_PIN V30 [get_ports rgmii_port_3_tx_ctl]
set_property PACKAGE_PIN V31 [get_ports mdio_io_port_3_mdc]
set_property PACKAGE_PIN V29 [get_ports mdio_io_port_3_mdio_io]
set_property PACKAGE_PIN U29 [get_ports reset_port_3]

#create_clock -period 8.000 -name ref_clk_p -waveform {0.000 4.000} [get_ports ref_clk_p]

