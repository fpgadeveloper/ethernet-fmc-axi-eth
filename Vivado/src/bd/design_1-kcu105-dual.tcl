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

# Add the Memory controller (MIG) for the DDR3
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4 ddr4_0
endgroup

# Connect MIG external interfaces
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "default_sysclk_300 ( 300 MHz System differential clock ) " }  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "ddr4_sdram ( DDR4 SDRAM ) " }  [get_bd_intf_pins ddr4_0/C0_DDR4]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset ( FPGA Reset ) " }  [get_bd_pins ddr4_0/sys_rst]
endgroup

# Add the Microblaze
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze microblaze_0
endgroup
# Use 100MHz additional MIG clock (note: using the 300MHz MIG clock would make it hard to close timing and is not necessary)
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config {local_mem "64KB" ecc "None" cache "64KB" debug_module "Debug Only" axi_periph "Enabled" axi_intc "1" clk "/ddr4_0/addn_ui_clkout1 (100 MHz)" }  [get_bd_cells microblaze_0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Cached)" Clk "Auto" }  [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]

# Connect 100MHz processor system reset external reset to the reset port
connect_bd_net [get_bd_ports reset] [get_bd_pins rst_ddr4_0_100M/ext_reset_in]

# Configure the interrupt concat
startgroup
set_property -dict [list CONFIG.NUM_PORTS {22}] [get_bd_cells microblaze_0_xlconcat]
endgroup

# Add the AXI Ethernet IPs for the LPC
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1
endgroup
#startgroup
#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_2
#endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_3
endgroup

# Add the AXI Ethernet IPs for the HPC
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_4
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_5
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_6
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_7
endgroup

# Create differential IO buffer for the first Ethernet FMC 125MHz clock
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0
endgroup
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_0/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_1/gtx_clk]
#connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_2/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_3/gtx_clk]
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_0_p
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_P] [get_bd_ports ref_clk_0_p]
endgroup
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_0_n
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_N] [get_bd_ports ref_clk_0_n]
endgroup

# Create differential IO buffer for the second Ethernet FMC 125MHz clock
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_1
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

# Configure all ports for full checksum hardware offload
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_1]
#set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_3]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_4]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_5]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_6]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_7]

# Configure ports 1,2 and 3 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_3]
#set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_1]

# Configure ports 5,6 and 7 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_7]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_6]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_5]

# Configure all AXI Ethernet: RGMII with DMA
startgroup
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_1]
#set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_3]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_4]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_5]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_6]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_7]
endgroup

# Create DMAs
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_0_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_1_dma
#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_2_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_3_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_4_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_5_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_6_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_7_dma
endgroup

startgroup
set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_0_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_1_dma]
#set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_2_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_3_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_4_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_5_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_6_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_7_dma]
endgroup

# Connect DMAs to AXI Ethernets
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_0_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins axi_ethernet_1_dma/S_AXIS_S2MM]
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins axi_ethernet_2_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxd] [get_bd_intf_pins axi_ethernet_3_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4/m_axis_rxd] [get_bd_intf_pins axi_ethernet_4_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5/m_axis_rxd] [get_bd_intf_pins axi_ethernet_5_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6/m_axis_rxd] [get_bd_intf_pins axi_ethernet_6_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7/m_axis_rxd] [get_bd_intf_pins axi_ethernet_7_dma/S_AXIS_S2MM]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins axi_ethernet_0_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins axi_ethernet_1_dma/S_AXIS_STS]
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins axi_ethernet_2_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxs] [get_bd_intf_pins axi_ethernet_3_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4/m_axis_rxs] [get_bd_intf_pins axi_ethernet_4_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5/m_axis_rxs] [get_bd_intf_pins axi_ethernet_5_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6/m_axis_rxs] [get_bd_intf_pins axi_ethernet_6_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7/m_axis_rxs] [get_bd_intf_pins axi_ethernet_7_dma/S_AXIS_STS]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/s_axis_txc] [get_bd_intf_pins axi_ethernet_0_dma/M_AXIS_CNTRL]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/s_axis_txc] [get_bd_intf_pins axi_ethernet_1_dma/M_AXIS_CNTRL]
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/s_axis_txc] [get_bd_intf_pins axi_ethernet_2_dma/M_AXIS_CNTRL]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/s_axis_txc] [get_bd_intf_pins axi_ethernet_3_dma/M_AXIS_CNTRL]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4/s_axis_txc] [get_bd_intf_pins axi_ethernet_4_dma/M_AXIS_CNTRL]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5/s_axis_txc] [get_bd_intf_pins axi_ethernet_5_dma/M_AXIS_CNTRL]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6/s_axis_txc] [get_bd_intf_pins axi_ethernet_6_dma/M_AXIS_CNTRL]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7/s_axis_txc] [get_bd_intf_pins axi_ethernet_7_dma/M_AXIS_CNTRL]

connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/s_axis_txd] [get_bd_intf_pins axi_ethernet_0_dma/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/s_axis_txd] [get_bd_intf_pins axi_ethernet_1_dma/M_AXIS_MM2S]
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/s_axis_txd] [get_bd_intf_pins axi_ethernet_2_dma/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/s_axis_txd] [get_bd_intf_pins axi_ethernet_3_dma/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4/s_axis_txd] [get_bd_intf_pins axi_ethernet_4_dma/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5/s_axis_txd] [get_bd_intf_pins axi_ethernet_5_dma/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6/s_axis_txd] [get_bd_intf_pins axi_ethernet_6_dma/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7/s_axis_txd] [get_bd_intf_pins axi_ethernet_7_dma/M_AXIS_MM2S]

connect_bd_net [get_bd_pins axi_ethernet_0/s_axi_lite_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_1/s_axi_lite_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_ethernet_2/s_axi_lite_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_3/s_axi_lite_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_4/s_axi_lite_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_5/s_axi_lite_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_6/s_axi_lite_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_7/s_axi_lite_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_4/axis_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_5/axis_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_6/axis_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_7/axis_clk] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_ethernet_0_dma/s_axi_lite_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/s_axi_lite_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_ethernet_2_dma/s_axi_lite_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/s_axi_lite_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_4_dma/s_axi_lite_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_5_dma/s_axi_lite_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_6_dma/s_axi_lite_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_7_dma/s_axi_lite_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_ethernet_0_dma/m_axi_sg_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/m_axi_sg_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_ethernet_2_dma/m_axi_sg_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/m_axi_sg_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_4_dma/m_axi_sg_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_5_dma/m_axi_sg_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_6_dma/m_axi_sg_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_7_dma/m_axi_sg_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_ethernet_0_dma/m_axi_mm2s_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/m_axi_mm2s_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_ethernet_2_dma/m_axi_mm2s_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/m_axi_mm2s_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_4_dma/m_axi_mm2s_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_5_dma/m_axi_mm2s_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_6_dma/m_axi_mm2s_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_7_dma/m_axi_mm2s_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_ethernet_0_dma/m_axi_s2mm_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/m_axi_s2mm_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_ethernet_2_dma/m_axi_s2mm_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/m_axi_s2mm_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_4_dma/m_axi_s2mm_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_5_dma/m_axi_s2mm_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_6_dma/m_axi_s2mm_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_ethernet_7_dma/m_axi_s2mm_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1]

# Resets
connect_bd_net [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins axi_ethernet_0_dma/mm2s_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins axi_ethernet_0_dma/mm2s_cntrl_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins axi_ethernet_0_dma/s2mm_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins axi_ethernet_0_dma/s2mm_sts_reset_out_n]

connect_bd_net [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins axi_ethernet_1_dma/mm2s_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins axi_ethernet_1_dma/mm2s_cntrl_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins axi_ethernet_1_dma/s2mm_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins axi_ethernet_1_dma/s2mm_sts_reset_out_n]

#connect_bd_net [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins axi_ethernet_2_dma/mm2s_prmry_reset_out_n]
#connect_bd_net [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins axi_ethernet_2_dma/mm2s_cntrl_reset_out_n]
#connect_bd_net [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins axi_ethernet_2_dma/s2mm_prmry_reset_out_n]
#connect_bd_net [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins axi_ethernet_2_dma/s2mm_sts_reset_out_n]

connect_bd_net [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins axi_ethernet_3_dma/mm2s_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins axi_ethernet_3_dma/mm2s_cntrl_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins axi_ethernet_3_dma/s2mm_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins axi_ethernet_3_dma/s2mm_sts_reset_out_n]

connect_bd_net [get_bd_pins axi_ethernet_4/axi_txd_arstn] [get_bd_pins axi_ethernet_4_dma/mm2s_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_4/axi_txc_arstn] [get_bd_pins axi_ethernet_4_dma/mm2s_cntrl_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_4/axi_rxd_arstn] [get_bd_pins axi_ethernet_4_dma/s2mm_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_4/axi_rxs_arstn] [get_bd_pins axi_ethernet_4_dma/s2mm_sts_reset_out_n]

connect_bd_net [get_bd_pins axi_ethernet_5/axi_txd_arstn] [get_bd_pins axi_ethernet_5_dma/mm2s_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_5/axi_txc_arstn] [get_bd_pins axi_ethernet_5_dma/mm2s_cntrl_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_5/axi_rxd_arstn] [get_bd_pins axi_ethernet_5_dma/s2mm_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_5/axi_rxs_arstn] [get_bd_pins axi_ethernet_5_dma/s2mm_sts_reset_out_n]

connect_bd_net [get_bd_pins axi_ethernet_6/axi_txd_arstn] [get_bd_pins axi_ethernet_6_dma/mm2s_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_6/axi_txc_arstn] [get_bd_pins axi_ethernet_6_dma/mm2s_cntrl_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_6/axi_rxd_arstn] [get_bd_pins axi_ethernet_6_dma/s2mm_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_6/axi_rxs_arstn] [get_bd_pins axi_ethernet_6_dma/s2mm_sts_reset_out_n]

connect_bd_net [get_bd_pins axi_ethernet_7/axi_txd_arstn] [get_bd_pins axi_ethernet_7_dma/mm2s_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_7/axi_txc_arstn] [get_bd_pins axi_ethernet_7_dma/mm2s_cntrl_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_7/axi_rxd_arstn] [get_bd_pins axi_ethernet_7_dma/s2mm_prmry_reset_out_n]
connect_bd_net [get_bd_pins axi_ethernet_7/axi_rxs_arstn] [get_bd_pins axi_ethernet_7_dma/s2mm_sts_reset_out_n]

connect_bd_net [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_1/s_axi_lite_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
#connect_bd_net [get_bd_pins axi_ethernet_2/s_axi_lite_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_3/s_axi_lite_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_4/s_axi_lite_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_5/s_axi_lite_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_6/s_axi_lite_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_7/s_axi_lite_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_0_dma/axi_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/axi_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
#connect_bd_net [get_bd_pins axi_ethernet_2_dma/axi_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/axi_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_4_dma/axi_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_5_dma/axi_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_6_dma/axi_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_7_dma/axi_resetn] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]


startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_4/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_5/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_6/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_7/s_axi]
endgroup

# Configure axi_mem_intercon for 9 slave ports (first 2 already used by the Microblaze)
set_property -dict [list CONFIG.NUM_SI {9} CONFIG.NUM_MI {1}] [get_bd_cells axi_mem_intercon]

# Add register slices to help pass timing
startgroup
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.S00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S01_HAS_REGSLICE {4} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S02_HAS_REGSLICE {4} CONFIG.S02_HAS_DATA_FIFO {0} CONFIG.S03_HAS_REGSLICE {4} CONFIG.S03_HAS_DATA_FIFO {0} CONFIG.S04_HAS_REGSLICE {4} CONFIG.S04_HAS_DATA_FIFO {0} CONFIG.S05_HAS_REGSLICE {4} CONFIG.S05_HAS_DATA_FIFO {0} CONFIG.S06_HAS_REGSLICE {4} CONFIG.S06_HAS_DATA_FIFO {0} CONFIG.S07_HAS_REGSLICE {4} CONFIG.S07_HAS_DATA_FIFO {0} CONFIG.S08_HAS_REGSLICE {4} CONFIG.S08_HAS_DATA_FIFO {0}] [get_bd_cells axi_mem_intercon]
set_property -dict [list CONFIG.STRATEGY {0}] [get_bd_cells axi_mem_intercon]
set_property -dict [list CONFIG.SYNCHRONIZATION_STAGES.VALUE_SRC USER] [get_bd_cells axi_mem_intercon]
set_property -dict [list CONFIG.ENABLE_ADVANCED_OPTIONS {1} CONFIG.SYNCHRONIZATION_STAGES {8}] [get_bd_cells axi_mem_intercon]
endgroup

# Connect the resets and clocks to the slave interfaces that we just added
connect_bd_net [get_bd_pins axi_mem_intercon/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_mem_intercon/S03_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_mem_intercon/S04_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_mem_intercon/S05_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_mem_intercon/S06_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_mem_intercon/S07_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_mem_intercon/S08_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_mem_intercon/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_mem_intercon/S03_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_mem_intercon/S04_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_mem_intercon/S05_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_mem_intercon/S06_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_mem_intercon/S07_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_mem_intercon/S08_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

# Add AXI Interconnect for each Ethernet port (we cascade the AXI Interconnects to help pass timing)
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_1
#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_2
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_3
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_4
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_5
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_6
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_7

# Set the AXI Interconnects for 1 Master and 3 Slave ports
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_0]
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_1]
#set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_2]
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_3]
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_4]
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_5]
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_6]
set_property -dict [list CONFIG.NUM_SI {3} CONFIG.NUM_MI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_7]

# Set the AXI Interconnects to have register slices on the master ports
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S02_HAS_DATA_FIFO {0}] [get_bd_cells axi_interconnect_0]
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S02_HAS_DATA_FIFO {0}] [get_bd_cells axi_interconnect_1]
#set_property -dict [list CONFIG.M00_HAS_REGSLICE {4}] [get_bd_cells axi_interconnect_2]
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S02_HAS_DATA_FIFO {0}] [get_bd_cells axi_interconnect_3]
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S02_HAS_DATA_FIFO {0}] [get_bd_cells axi_interconnect_4]
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S02_HAS_DATA_FIFO {0}] [get_bd_cells axi_interconnect_5]
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S02_HAS_DATA_FIFO {0}] [get_bd_cells axi_interconnect_6]
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S02_HAS_DATA_FIFO {0}] [get_bd_cells axi_interconnect_7]

# Connect the clocks and resets
connect_bd_net [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins rst_ddr4_0_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_0/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins rst_ddr4_0_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_1/S01_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_1/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_1/S01_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_1/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

#connect_bd_net [get_bd_pins axi_interconnect_2/ARESETN] [get_bd_pins rst_ddr4_0_100M/interconnect_aresetn]
#connect_bd_net [get_bd_pins axi_interconnect_2/ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_interconnect_2/M00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
#connect_bd_net [get_bd_pins axi_interconnect_2/M00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_interconnect_2/S00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
#connect_bd_net [get_bd_pins axi_interconnect_2/S01_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
#connect_bd_net [get_bd_pins axi_interconnect_2/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
#connect_bd_net [get_bd_pins axi_interconnect_2/S00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_interconnect_2/S01_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
#connect_bd_net [get_bd_pins axi_interconnect_2/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_interconnect_3/ARESETN] [get_bd_pins rst_ddr4_0_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_3/ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_3/M00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_3/M00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_3/S00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_3/S01_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_3/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_3/S00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_3/S01_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_3/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_interconnect_4/ARESETN] [get_bd_pins rst_ddr4_0_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_4/ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_4/M00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_4/M00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_4/S00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_4/S01_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_4/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_4/S00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_4/S01_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_4/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_interconnect_5/ARESETN] [get_bd_pins rst_ddr4_0_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_5/ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_5/M00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_5/M00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_5/S00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_5/S01_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_5/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_5/S00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_5/S01_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_5/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_interconnect_6/ARESETN] [get_bd_pins rst_ddr4_0_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_6/ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_6/M00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_6/M00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_6/S00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_6/S01_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_6/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_6/S00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_6/S01_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_6/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

connect_bd_net [get_bd_pins axi_interconnect_7/ARESETN] [get_bd_pins rst_ddr4_0_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_7/ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_7/M00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_7/M00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_7/S00_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_7/S01_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_7/S02_ARESETN] [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_7/S00_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_7/S01_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins axi_interconnect_7/S02_ACLK] [get_bd_pins ddr4_0/addn_ui_clkout1]

# Connect the master ports to the axi_mem_intercon
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_1/M00_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S03_AXI]
#connect_bd_intf_net [get_bd_intf_pins axi_interconnect_2/M00_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S04_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_3/M00_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S04_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_4/M00_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S05_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_5/M00_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S06_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_6/M00_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S07_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_7/M00_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S08_AXI]

# Connect the slave ports to the DMAs
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_SG] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_SG] -boundary_type upper [get_bd_intf_pins axi_interconnect_1/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_1/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_1/S02_AXI]
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_SG] -boundary_type upper [get_bd_intf_pins axi_interconnect_2/S00_AXI]
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_2/S01_AXI]
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_2/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_SG] -boundary_type upper [get_bd_intf_pins axi_interconnect_3/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_3/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_3/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4_dma/M_AXI_SG] -boundary_type upper [get_bd_intf_pins axi_interconnect_4/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4_dma/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_4/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_4_dma/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_4/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5_dma/M_AXI_SG] -boundary_type upper [get_bd_intf_pins axi_interconnect_5/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5_dma/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_5/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_5_dma/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_5/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6_dma/M_AXI_SG] -boundary_type upper [get_bd_intf_pins axi_interconnect_6/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6_dma/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_6/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_6_dma/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_6/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7_dma/M_AXI_SG] -boundary_type upper [get_bd_intf_pins axi_interconnect_7/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7_dma/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_7/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_7_dma/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_7/S02_AXI]

# Auto-connect the AXI-lite interfaces to the Microblaze
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1_dma/S_AXI_LITE]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_4_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_5_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_6_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_7_dma/S_AXI_LITE]
endgroup

assign_bd_address

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
#startgroup
#create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_2
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/mdio] [get_bd_intf_ports mdio_io_port_2]
#endgroup
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
#startgroup
#create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2
#connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/rgmii] [get_bd_intf_ports rgmii_port_2]
#endgroup
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
#startgroup
#create_bd_port -dir O -type rst reset_port_2
#connect_bd_net [get_bd_pins /axi_ethernet_2/phy_rst_n] [get_bd_ports reset_port_2]
#endgroup
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

connect_bd_net [get_bd_pins axi_ethernet_0_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In0]
connect_bd_net [get_bd_pins axi_ethernet_0_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In1]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In2]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In3]
#connect_bd_net [get_bd_pins axi_ethernet_2_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In4]
#connect_bd_net [get_bd_pins axi_ethernet_2_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In5]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In4]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In5]
connect_bd_net [get_bd_pins axi_ethernet_4_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In6]
connect_bd_net [get_bd_pins axi_ethernet_4_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In7]
connect_bd_net [get_bd_pins axi_ethernet_5_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In8]
connect_bd_net [get_bd_pins axi_ethernet_5_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In9]
connect_bd_net [get_bd_pins axi_ethernet_6_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In10]
connect_bd_net [get_bd_pins axi_ethernet_6_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In11]
connect_bd_net [get_bd_pins axi_ethernet_7_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In12]
connect_bd_net [get_bd_pins axi_ethernet_7_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In13]

# We don't connect the AXI Ethernet "mac_irq" interrupt because that would force us to use more
# than 32 interrupts - thus use cascaded interrupt controllers.
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In14]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins microblaze_0_xlconcat/In15]
#connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins microblaze_0_xlconcat/In16]
connect_bd_net [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins microblaze_0_xlconcat/In16]
connect_bd_net [get_bd_pins axi_ethernet_4/interrupt] [get_bd_pins microblaze_0_xlconcat/In17]
connect_bd_net [get_bd_pins axi_ethernet_5/interrupt] [get_bd_pins microblaze_0_xlconcat/In18]
connect_bd_net [get_bd_pins axi_ethernet_6/interrupt] [get_bd_pins microblaze_0_xlconcat/In19]
connect_bd_net [get_bd_pins axi_ethernet_7/interrupt] [get_bd_pins microblaze_0_xlconcat/In20]

# Connect 300MHz AXI Ethernet ref_clk

connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins axi_ethernet_0/ref_clk]
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins axi_ethernet_4/ref_clk]

# Create Ethernet FMC reference clock output enable and frequency select

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_0_oe
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_0_oe
connect_bd_net [get_bd_pins /ref_clk_0_oe/dout] [get_bd_ports ref_clk_0_oe]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_1_oe
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_1_oe
connect_bd_net [get_bd_pins /ref_clk_1_oe/dout] [get_bd_ports ref_clk_1_oe]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_0_fsel
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_0_fsel
connect_bd_net [get_bd_pins /ref_clk_0_fsel/dout] [get_bd_ports ref_clk_0_fsel]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_1_fsel
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_1_fsel
connect_bd_net [get_bd_pins /ref_clk_1_fsel/dout] [get_bd_ports ref_clk_1_fsel]
endgroup

# Add UART for the Echo server example application

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550 axi_uart16550_0
endgroup
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_uart16550_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "rs232_uart ( UART ) " }  [get_bd_intf_pins axi_uart16550_0/UART]
endgroup

# Add Timer for the Echo server example application

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_timer_0/S_AXI]

connect_bd_net [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In21]


# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
