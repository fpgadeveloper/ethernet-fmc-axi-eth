# Adjustment to the set_input_delay constraints to inform tools that the RGMII RX data will come in without a delay on the RXC clock

set_input_delay -clock [get_clocks design_1_i/axi_ethernet_1/inst/eth_mac/inst_rgmii_rx_clk] -max 0.5 [get_ports {rgmii_port_1_rd[*] rgmii_port_1_rx_ctl}]
set_input_delay -clock [get_clocks design_1_i/axi_ethernet_1/inst/eth_mac/inst_rgmii_rx_clk] -min -0.5 [get_ports {rgmii_port_1_rd[*] rgmii_port_1_rx_ctl}]
set_input_delay -clock [get_clocks design_1_i/axi_ethernet_1/inst/eth_mac/inst_rgmii_rx_clk] -clock_fall -max 0.5 -add_delay [get_ports {rgmii_port_1_rd[*] rgmii_port_1_rx_ctl}]
set_input_delay -clock [get_clocks design_1_i/axi_ethernet_1/inst/eth_mac/inst_rgmii_rx_clk] -clock_fall -min -0.5 -add_delay [get_ports {rgmii_port_1_rd[*] rgmii_port_1_rx_ctl}]

set_input_delay -clock [get_clocks design_1_i/axi_ethernet_3/inst/eth_mac/inst_rgmii_rx_clk] -max 0.5 [get_ports {rgmii_port_3_rd[*] rgmii_port_3_rx_ctl}]
set_input_delay -clock [get_clocks design_1_i/axi_ethernet_3/inst/eth_mac/inst_rgmii_rx_clk] -min -0.5 [get_ports {rgmii_port_3_rd[*] rgmii_port_3_rx_ctl}]
set_input_delay -clock [get_clocks design_1_i/axi_ethernet_3/inst/eth_mac/inst_rgmii_rx_clk] -clock_fall -max 0.5 -add_delay [get_ports {rgmii_port_3_rd[*] rgmii_port_3_rx_ctl}]
set_input_delay -clock [get_clocks design_1_i/axi_ethernet_3/inst/eth_mac/inst_rgmii_rx_clk] -clock_fall -min -0.5 -add_delay [get_ports {rgmii_port_3_rd[*] rgmii_port_3_rx_ctl}]

# Adjustment to the IDELAYs to make the timing pass

set_property DELAY_VALUE 300 [get_cells design_1_i/axi_ethernet_1/inst/eth_mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 300 [get_cells {design_1_i/axi_ethernet_1/inst/eth_mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 300 [get_cells {design_1_i/axi_ethernet_1/inst/eth_mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 300 [get_cells {design_1_i/axi_ethernet_1/inst/eth_mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 300 [get_cells {design_1_i/axi_ethernet_1/inst/eth_mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

set_property DELAY_VALUE 300 [get_cells design_1_i/axi_ethernet_3/inst/eth_mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 300 [get_cells {design_1_i/axi_ethernet_3/inst/eth_mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 300 [get_cells {design_1_i/axi_ethernet_3/inst/eth_mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 300 [get_cells {design_1_i/axi_ethernet_3/inst/eth_mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 300 [get_cells {design_1_i/axi_ethernet_3/inst/eth_mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]




