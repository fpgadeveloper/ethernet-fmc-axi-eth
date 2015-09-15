################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

set design_name design_1

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

# Add the Memory controller (MIG) for the DDR3
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:2.3 mig_7series_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:mig_7series -config {Board_Interface "ddr3_sdram" }  [get_bd_cells mig_7series_0]

# Add the Microblaze
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.5 microblaze_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config {local_mem "8KB" ecc "None" cache "8KB" debug_module "Debug Only" axi_periph "Enabled" axi_intc "1" clk "/mig_7series_0/ui_clk (100 MHz)" }  [get_bd_cells microblaze_0]

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Cached)" Clk "Auto" }  [get_bd_intf_pins mig_7series_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset" }  [get_bd_pins mig_7series_0/sys_rst]
endgroup

# Configure the interrupt concat
startgroup
set_property -dict [list CONFIG.NUM_PORTS {24}] [get_bd_cells microblaze_0_xlconcat]
endgroup

# Add the AXI Ethernet IPs for the LPC
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_1
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_2
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_3
endgroup

# Add the AXI Ethernet IPs for the HPC
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_4
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_5
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_6
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_7
endgroup

# Configure ports 1,2 and 3 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_3]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_1]

# Configure ports 5,6 and 7 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_7]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_6]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_5]

# Configure AXI Ethernet blocks for RGMII interfaces
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_3]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_4]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_5]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_6]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_7]

# Create AXI Stream FIFOs

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_ethernet_0_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_ethernet_1_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_ethernet_2_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_ethernet_3_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_ethernet_4_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_ethernet_5_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_ethernet_6_fifo
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_ethernet_7_fifo

set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_0_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_1_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_2_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_3_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_4_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_5_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_6_fifo]
set_property -dict [list CONFIG.C_TX_FIFO_DEPTH {4096} CONFIG.C_HAS_AXIS_TKEEP {true} CONFIG.C_RX_FIFO_DEPTH {4096} CONFIG.C_TX_FIFO_PF_THRESHOLD {4000} CONFIG.C_TX_FIFO_PE_THRESHOLD {10} CONFIG.C_RX_FIFO_PF_THRESHOLD {4000} CONFIG.C_RX_FIFO_PE_THRESHOLD {10}] [get_bd_cells axi_ethernet_7_fifo]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_0_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins axi_ethernet_1_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins axi_ethernet_2_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxd] [get_bd_intf_pins axi_ethernet_3_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4/m_axis_rxd] [get_bd_intf_pins axi_ethernet_4_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5/m_axis_rxd] [get_bd_intf_pins axi_ethernet_5_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6/m_axis_rxd] [get_bd_intf_pins axi_ethernet_6_fifo/AXI_STR_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7/m_axis_rxd] [get_bd_intf_pins axi_ethernet_7_fifo/AXI_STR_RXD]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_0/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_2/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_3/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_4/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_5/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_6/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7_fifo/AXI_STR_TXD] [get_bd_intf_pins axi_ethernet_7/s_axis_txd]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_0/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_1/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_2/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_3/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_4/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_5/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_6/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7_fifo/AXI_STR_TXC] [get_bd_intf_pins axi_ethernet_7/s_axis_txc]

connect_bd_net [get_bd_pins axi_ethernet_0_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_2/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_3_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_3/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_4_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_4/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_5_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_5/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_6_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_6/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_7_fifo/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_7/axi_txd_arstn]

connect_bd_net [get_bd_pins axi_ethernet_0_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_1/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_2/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_3_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_3/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_4_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_4/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_5_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_5/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_6_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_6/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_7_fifo/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_7/axi_txc_arstn]

connect_bd_net [get_bd_pins axi_ethernet_0_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_2/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_3_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_3/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_4_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_4/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_5_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_5/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_6_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_6/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_7_fifo/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_7/axi_rxd_arstn]

connect_bd_net -net [get_bd_nets axi_ethernet_0_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins axi_ethernet_0_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_1_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins axi_ethernet_1_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_2_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins axi_ethernet_2_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_3_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins axi_ethernet_3_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_4_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_4/axi_rxs_arstn] [get_bd_pins axi_ethernet_4_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_5_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_5/axi_rxs_arstn] [get_bd_pins axi_ethernet_5_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_6_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_6/axi_rxs_arstn] [get_bd_pins axi_ethernet_6_fifo/s2mm_prmry_reset_out_n]
connect_bd_net -net [get_bd_nets axi_ethernet_7_fifo_s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_7/axi_rxs_arstn] [get_bd_pins axi_ethernet_7_fifo/s2mm_prmry_reset_out_n]

connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins axi_ethernet_4/axis_clk] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins axi_ethernet_5/axis_clk] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins axi_ethernet_6/axis_clk] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins axi_ethernet_7/axis_clk] [get_bd_pins mig_7series_0/ui_clk]
endgroup

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_4/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_5/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_6/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_7/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_4_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_5_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_6_fifo/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_7_fifo/S_AXI]
endgroup

# Make AXI Ethernet ports external: MDIO, RGMII and RESET
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
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/mdio] [get_bd_intf_ports mdio_io_port_3]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_4
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4/mdio] [get_bd_intf_ports mdio_io_port_4]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_5
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5/mdio] [get_bd_intf_ports mdio_io_port_5]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_6
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6/mdio] [get_bd_intf_ports mdio_io_port_6]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_7
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7/mdio] [get_bd_intf_ports mdio_io_port_7]
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
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/rgmii] [get_bd_intf_ports rgmii_port_3]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_4
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4/rgmii] [get_bd_intf_ports rgmii_port_4]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_5
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5/rgmii] [get_bd_intf_ports rgmii_port_5]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_6
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6/rgmii] [get_bd_intf_ports rgmii_port_6]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_7
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7/rgmii] [get_bd_intf_ports rgmii_port_7]
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
startgroup
create_bd_port -dir O -type rst reset_port_3
connect_bd_net [get_bd_pins /axi_ethernet_3/phy_rst_n] [get_bd_ports reset_port_3]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_4
connect_bd_net [get_bd_pins /axi_ethernet_4/phy_rst_n] [get_bd_ports reset_port_4]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_5
connect_bd_net [get_bd_pins /axi_ethernet_5/phy_rst_n] [get_bd_ports reset_port_5]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_6
connect_bd_net [get_bd_pins /axi_ethernet_6/phy_rst_n] [get_bd_ports reset_port_6]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_7
connect_bd_net [get_bd_pins /axi_ethernet_7/phy_rst_n] [get_bd_ports reset_port_7]
endgroup


# Connect interrupts

connect_bd_net [get_bd_pins axi_ethernet_0_fifo/interrupt] [get_bd_pins microblaze_0_xlconcat/In0]
connect_bd_net [get_bd_pins axi_ethernet_1_fifo/interrupt] [get_bd_pins microblaze_0_xlconcat/In1]
connect_bd_net [get_bd_pins axi_ethernet_2_fifo/interrupt] [get_bd_pins microblaze_0_xlconcat/In2]
connect_bd_net [get_bd_pins axi_ethernet_3_fifo/interrupt] [get_bd_pins microblaze_0_xlconcat/In3]
connect_bd_net [get_bd_pins axi_ethernet_4_fifo/interrupt] [get_bd_pins microblaze_0_xlconcat/In4]
connect_bd_net [get_bd_pins axi_ethernet_5_fifo/interrupt] [get_bd_pins microblaze_0_xlconcat/In5]
connect_bd_net [get_bd_pins axi_ethernet_6_fifo/interrupt] [get_bd_pins microblaze_0_xlconcat/In6]
connect_bd_net [get_bd_pins axi_ethernet_7_fifo/interrupt] [get_bd_pins microblaze_0_xlconcat/In7]

connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins microblaze_0_xlconcat/In8]
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In9]
connect_bd_net [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins microblaze_0_xlconcat/In10]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins microblaze_0_xlconcat/In11]
connect_bd_net [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins microblaze_0_xlconcat/In12]
connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins microblaze_0_xlconcat/In13]
connect_bd_net [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins microblaze_0_xlconcat/In14]
connect_bd_net [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins microblaze_0_xlconcat/In15]
connect_bd_net [get_bd_pins axi_ethernet_4/mac_irq] [get_bd_pins microblaze_0_xlconcat/In16]
connect_bd_net [get_bd_pins axi_ethernet_4/interrupt] [get_bd_pins microblaze_0_xlconcat/In17]
connect_bd_net [get_bd_pins axi_ethernet_5/mac_irq] [get_bd_pins microblaze_0_xlconcat/In18]
connect_bd_net [get_bd_pins axi_ethernet_5/interrupt] [get_bd_pins microblaze_0_xlconcat/In19]
connect_bd_net [get_bd_pins axi_ethernet_6/mac_irq] [get_bd_pins microblaze_0_xlconcat/In20]
connect_bd_net [get_bd_pins axi_ethernet_6/interrupt] [get_bd_pins microblaze_0_xlconcat/In21]
connect_bd_net [get_bd_pins axi_ethernet_7/mac_irq] [get_bd_pins microblaze_0_xlconcat/In22]
connect_bd_net [get_bd_pins axi_ethernet_7/interrupt] [get_bd_pins microblaze_0_xlconcat/In23]

# Delete the clock wizard that is automatically generated by Vivado 2015.2

delete_bd_objs [get_bd_nets axi_ethernet_0_refclk_clk_out2] [get_bd_nets axi_ethernet_0_refclk_clk_out1] [get_bd_cells axi_ethernet_0_refclk]

# Connect 200MHz AXI Ethernet ref_clk

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.1 clk_wiz_0
endgroup
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net [get_bd_pins clk_wiz_0/reset] [get_bd_pins rst_mig_7series_0_100M/peripheral_reset]
connect_bd_net [get_bd_pins axi_ethernet_0/ref_clk] [get_bd_pins clk_wiz_0/clk_out1]
connect_bd_net [get_bd_pins axi_ethernet_4/ref_clk] [get_bd_pins clk_wiz_0/clk_out1]
startgroup
set_property -dict [list CONFIG.PRIM_SOURCE {No_buffer} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200} CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000} CONFIG.CLKOUT1_JITTER {114.829}] [get_bd_cells clk_wiz_0]
endgroup

# Create differential IO buffer for the Ethernet FMC 125MHz clock (LPC)

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0
endgroup
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_0/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_1/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_2/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_3/gtx_clk]
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_0_p
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_P] [get_bd_ports ref_clk_0_p]
endgroup
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_0_n
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_N] [get_bd_ports ref_clk_0_n]
endgroup

# Create differential IO buffer for the Ethernet FMC 125MHz clock (HPC)

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_1
endgroup
connect_bd_net [get_bd_pins util_ds_buf_1/IBUF_OUT] [get_bd_pins axi_ethernet_4/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/IBUF_OUT] [get_bd_pins axi_ethernet_5/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/IBUF_OUT] [get_bd_pins axi_ethernet_6/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/IBUF_OUT] [get_bd_pins axi_ethernet_7/gtx_clk]
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_1_p
connect_bd_net [get_bd_pins /util_ds_buf_1/IBUF_DS_P] [get_bd_ports ref_clk_1_p]
endgroup
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_1_n
connect_bd_net [get_bd_pins /util_ds_buf_1/IBUF_DS_N] [get_bd_ports ref_clk_1_n]
endgroup

# Create Ethernet FMC reference clock output enable and frequency select (LPC)

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_0_oe
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_0_oe
connect_bd_net [get_bd_pins /ref_clk_0_oe/dout] [get_bd_ports ref_clk_0_oe]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_0_fsel
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_0_fsel
connect_bd_net [get_bd_pins /ref_clk_0_fsel/dout] [get_bd_ports ref_clk_0_fsel]
endgroup

# Create Ethernet FMC reference clock output enable and frequency select (HPC)

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_1_oe
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_1_oe
connect_bd_net [get_bd_pins /ref_clk_1_oe/dout] [get_bd_ports ref_clk_1_oe]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_1_fsel
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_1_fsel
connect_bd_net [get_bd_pins /ref_clk_1_fsel/dout] [get_bd_ports ref_clk_1_fsel]
endgroup

# Correct the addresses to prevent overlap

set_property offset 0x40C40000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_ethernet_1_Reg0}]
set_property offset 0x40C80000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_ethernet_2_Reg0}]
set_property offset 0x40CC0000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_ethernet_3_Reg0}]
set_property offset 0x40D00000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_ethernet_4_Reg0}]
set_property offset 0x40D40000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_ethernet_5_Reg0}]
set_property offset 0x40D80000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_ethernet_6_Reg0}]
set_property offset 0x40DC0000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_ethernet_7_Reg0}]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
