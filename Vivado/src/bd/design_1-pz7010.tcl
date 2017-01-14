################################################################
# Block diagram build script
################################################################

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

create_bd_design $design_name

current_bd_design $design_name

set parentCell [get_bd_cells /]

# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
   puts "ERROR: Unable to find parent cell <$parentCell>!"
   return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
   puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
   return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# Set parent object as current
current_bd_instance $parentObj

# Add the Processor System and apply board preset
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Configure the PS: Generate 200MHz clock, Enable ETH1, Enable GP0, Enable interrupts
startgroup
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {125} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {1}] [get_bd_cells processing_system7_0]
endgroup

# Connect the FCLK_CLK0 to the PS GP0
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]

# Add the concat for the interrupts
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0
endgroup
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins processing_system7_0/IRQ_F2P]
startgroup
set_property -dict [list CONFIG.NUM_PORTS {9}] [get_bd_cells xlconcat_0]
endgroup

# Add the AXI Ethernet IPs
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_2
endgroup

# Configure ports 0 and 2 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_0]

# Configure all AXI Ethernet for no frame filter and no statistics counter (saves LUTs)
set_property -dict [list CONFIG.Frame_Filter {false} CONFIG.Statistics_Counters {false}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.Frame_Filter {false} CONFIG.Statistics_Counters {false}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.Frame_Filter {false} CONFIG.Statistics_Counters {false}] [get_bd_cells axi_ethernet_2]

# Configure AXI Ethernet blocks for RGMII interfaces
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_2]

# Create AXI Stream FIFOs
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s axi_ethernet_0_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s axi_ethernet_1_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s axi_ethernet_2_fifo

set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_0_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_1_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_2_fifo]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_0_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins axi_ethernet_1_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins axi_ethernet_2_fifo/AXI_STR_RXD]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_0/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_2/s_axis_txd]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_0/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_1/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_2/s_axis_txc]

connect_bd_net [get_bd_pins axi_ethernet_0_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_2/axi_txd_arstn]

connect_bd_net [get_bd_pins axi_ethernet_0_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_1/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_2/axi_txc_arstn]

connect_bd_net [get_bd_pins axi_ethernet_0_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_2/axi_rxd_arstn]

connect_bd_net -net [get_bd_nets axi_ethernet_0_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins axi_ethernet_0_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_1_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins axi_ethernet_1_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_2_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins axi_ethernet_2_fifo/s2mm_prmry_reset_out_n]

connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
endgroup

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2_fifo/S_AXI]
endgroup

# Add the GMII-to-RGMII
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:gmii_to_rgmii gmii_to_rgmii_0
endgroup
set_property -dict [list CONFIG.SupportLevel {Include_Shared_Logic_in_Core}] [get_bd_cells gmii_to_rgmii_0]
connect_bd_intf_net [get_bd_intf_pins gmii_to_rgmii_0/MDIO_GEM] [get_bd_intf_pins processing_system7_0/MDIO_ETHERNET_1]
connect_bd_intf_net [get_bd_intf_pins gmii_to_rgmii_0/GMII] [get_bd_intf_pins processing_system7_0/GMII_ETHERNET_1]

# Make AXI Ethernet/GMII-to-RGMII ports external: MDIO, RGMII and RESET
# MDIO
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/mdio] [get_bd_intf_ports mdio_io_port_0]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/mdio] [get_bd_intf_ports mdio_io_port_1]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/mdio] [get_bd_intf_ports mdio_io_port_2]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_3
connect_bd_intf_net [get_bd_intf_pins gmii_to_rgmii_0/MDIO_PHY] [get_bd_intf_ports mdio_io_port_3]
endgroup
# RGMII
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/rgmii] [get_bd_intf_ports rgmii_port_0]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/rgmii] [get_bd_intf_ports rgmii_port_1]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/rgmii] [get_bd_intf_ports rgmii_port_2]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_3
connect_bd_intf_net [get_bd_intf_pins gmii_to_rgmii_0/RGMII] [get_bd_intf_ports rgmii_port_3]
endgroup
# RESET
startgroup
create_bd_port -dir O -type rst reset_port_0
connect_bd_net [get_bd_pins /axi_ethernet_0/phy_rst_n] [get_bd_ports reset_port_0]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_1
connect_bd_net [get_bd_pins /axi_ethernet_1/phy_rst_n] [get_bd_ports reset_port_1]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_2
connect_bd_net [get_bd_pins /axi_ethernet_2/phy_rst_n] [get_bd_ports reset_port_2]
endgroup

# PHY RESET for GMII-to-RGMII port 3

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic util_reduced_logic_0
endgroup
startgroup
set_property -dict [list CONFIG.C_SIZE {1}] [get_bd_cells util_reduced_logic_0]
endgroup
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins util_reduced_logic_0/Op1] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
startgroup
create_bd_port -dir O reset_port_3
connect_bd_net [get_bd_pins /util_reduced_logic_0/Res] [get_bd_ports reset_port_3]
endgroup

# Connect interrupts

connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins xlconcat_0/In0]
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In1]
connect_bd_net [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins xlconcat_0/In2]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins xlconcat_0/In3]
connect_bd_net [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins xlconcat_0/In4]
connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins xlconcat_0/In5]
connect_bd_net [get_bd_pins axi_ethernet_0_fifo/interrupt] [get_bd_pins xlconcat_0/In6]
connect_bd_net [get_bd_pins axi_ethernet_1_fifo/interrupt] [get_bd_pins xlconcat_0/In7]
connect_bd_net [get_bd_pins axi_ethernet_2_fifo/interrupt] [get_bd_pins xlconcat_0/In8]

# Connect AXI Ethernet clocks

connect_bd_net [get_bd_pins axi_ethernet_1/gtx_clk_out] [get_bd_pins axi_ethernet_0/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_1/gtx_clk90_out] [get_bd_pins axi_ethernet_0/gtx_clk90]
connect_bd_net [get_bd_pins axi_ethernet_1/gtx_clk_out] [get_bd_pins axi_ethernet_2/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_1/gtx_clk90_out] [get_bd_pins axi_ethernet_2/gtx_clk90]

# Connect 200MHz AXI Ethernet ref_clk and GMII-to-RGMII clkin

connect_bd_net [get_bd_pins axi_ethernet_1/ref_clk] [get_bd_pins processing_system7_0/FCLK_CLK2]
connect_bd_net [get_bd_pins gmii_to_rgmii_0/clkin] [get_bd_pins processing_system7_0/FCLK_CLK2]

# Connect GMII-to-RGMII resets

connect_bd_net [get_bd_pins rst_ps7_0_100M/peripheral_reset] [get_bd_pins gmii_to_rgmii_0/tx_reset]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_reset] [get_bd_pins gmii_to_rgmii_0/rx_reset] [get_bd_pins rst_ps7_0_100M/peripheral_reset]

# Create differential IO buffer for the Ethernet FMC 125MHz clock

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0
endgroup
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_1/gtx_clk]
startgroup
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_p
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_P] [get_bd_ports ref_clk_p]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_p]
endgroup
startgroup
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_n
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_N] [get_bd_ports ref_clk_n]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_n]
endgroup

# Create Ethernet FMC reference clock output enable and frequency select

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_oe
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_oe
connect_bd_net [get_bd_pins /ref_clk_oe/dout] [get_bd_ports ref_clk_oe]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_fsel
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_fsel
connect_bd_net [get_bd_pins /ref_clk_fsel/dout] [get_bd_ports ref_clk_fsel]
endgroup

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
