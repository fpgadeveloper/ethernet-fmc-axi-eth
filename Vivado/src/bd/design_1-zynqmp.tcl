################################################################
# Block diagram build script
################################################################

# Check if IP exists in design
proc ip_exists {ip_name} {
    set cells [get_bd_cells -quiet $ip_name]
    return [llength $cells]
}

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
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]

# Configure the PS
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP1 {0} \
CONFIG.PSU__USE__S_AXI_GP2 {1} \
CONFIG.PSU__USE__IRQ0 {1} \
CONFIG.PSU__USE__IRQ1 {1} \
CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__TTC0__PERIPHERAL__IO {EMIO}] [get_bd_cells zynq_ultra_ps_e_0]

# Connect the FCLK_CLK0 to the PS GP0 and HP0
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]

# Add the concat for the interrupts
set num_ints [expr {4 * [llength $ports]}]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]
if { $num_ints > 8 } {
  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_1
  connect_bd_net [get_bd_pins xlconcat_1/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq1]
  set_property -dict [list CONFIG.NUM_PORTS {8}] [get_bd_cells xlconcat_0]
  set_property -dict [list CONFIG.NUM_PORTS [expr {$num_ints - 8}]] [get_bd_cells xlconcat_1]
} else {
  set_property -dict [list CONFIG.NUM_PORTS $num_ints] [get_bd_cells xlconcat_0]
}

# Create clock wizard to generate 300MHz ref_clk and 125MHz GTX clock

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0
set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
CONFIG.PRIM_IN_FREQ {125} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {333.333} \
CONFIG.CLKIN1_JITTER_PS {80.0} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {3} \
CONFIG.NUM_OUT_CLKS {2} \
CONFIG.CLKOUT1_JITTER {119.348}\
 CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
CONFIG.CLKOUT2_JITTER {99.263} \
CONFIG.CLKOUT2_PHASE_ERROR {96.948}] [get_bd_cells clk_wiz_0]

set_property -dict [list CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false}] [get_bd_cells clk_wiz_0]

# Create the AXI Smartconnect for the AXI DMA connections
#create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smc
#connect_bd_intf_net [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
#connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_smc/aclk]
#connect_bd_net [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins axi_smc/aresetn]

# Add and configure AXI Ethernet IPs with AXI DMAs
foreach port $ports {
  # Add the AXI Ethernet IPs
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_$port
  
  # Configure for "Don't include shared logic" except the one specified by $shared_logic_port
  if { $shared_logic_port == $port } {
    set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {1}] [get_bd_cells axi_ethernet_$port]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet_$port/gtx_clk]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out2] [get_bd_pins axi_ethernet_$port/ref_clk]
  } else {
    set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_$port]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet_$port/gtx_clk]
  }
  
  # Add the DMA for the AXI Ethernet Subsystem
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_${port}_dma
  
  # Must enable unaligned transfers in the DMAs or we get this error in Echo server: "Error set buf addr 201116 with 4 and 3, 2"
  set_property -dict [list CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_${port}_dma]
  
  # Connect AXI streaming interfaces
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/m_axis_rxd] [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXIS_S2MM]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/m_axis_rxs] [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXIS_STS]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/s_axis_txd] [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXIS_MM2S]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/s_axis_txc] [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXIS_CNTRL]

  # Connect clocks for AXI Ethernet Subsystem
  connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_${port}/axis_clk]
  connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_${port}/s_axi_lite_clk]

  # Connect clocks for AXI DMA
  connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_${port}_dma/s_axi_lite_aclk]
  connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_${port}_dma/m_axi_sg_aclk]
  connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_${port}_dma/m_axi_mm2s_aclk]
  connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_${port}_dma/m_axi_s2mm_aclk]

  # Connect resets between AXI DMA and Ethernet
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_txd_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_txc_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_rxd_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_rxs_arstn]

  # Use connection automation to connect AXI lite interfaces
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}/s_axi]
  set_property range 256K [get_bd_addr_segs "zynq_ultra_ps_e_0/Data/SEG_axi_ethernet_${port}_Reg0"]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXI_LITE]

  # Use connection automation to connect AXI MM interfaces of the DMA
  if { [ip_exists "axi_smc"] == 0 } {
    #apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config [list Master "/axi_ethernet_${port}_dma/M_AXI_SG" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" ]  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smc
    connect_bd_intf_net [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
    connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_smc/aclk]
    connect_bd_net [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins axi_smc/aresetn]
  }
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/zynq_ultra_ps_e_0/S_AXI_HP0_FPD" intc_ip "/axi_smc" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_SG]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/zynq_ultra_ps_e_0/S_AXI_HP0_FPD" intc_ip "/axi_smc" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_MM2S]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/zynq_ultra_ps_e_0/S_AXI_HP0_FPD" intc_ip "/axi_smc" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_S2MM]

  # Make AXI Ethernet ports external: MDIO, RGMII and RESET
  # MDIO
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_${port}
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/mdio] [get_bd_intf_ports mdio_io_port_${port}]
  # RGMII
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_${port}
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/rgmii] [get_bd_intf_ports rgmii_port_${port}]
  # RESET
  create_bd_port -dir O -type rst reset_port_${port}
  connect_bd_net [get_bd_pins /axi_ethernet_${port}/phy_rst_n] [get_bd_ports reset_port_${port}]

  # Include segment HP0_FPS_OCM
  include_bd_addr_seg [get_bd_addr_segs -excluded axi_ethernet_${port}_dma/Data_SG/SEG_zynq_ultra_ps_e_0_HP0_LPS_OCM]
  include_bd_addr_seg [get_bd_addr_segs -excluded axi_ethernet_${port}_dma/Data_MM2S/SEG_zynq_ultra_ps_e_0_HP0_LPS_OCM]
  include_bd_addr_seg [get_bd_addr_segs -excluded axi_ethernet_${port}_dma/Data_S2MM/SEG_zynq_ultra_ps_e_0_HP0_LPS_OCM]
}

# Connect AXI DMA and AXI Ethernet interrupts
set int_index 0
set concat_index 0
foreach port $ports {
  connect_bd_net [get_bd_pins axi_ethernet_${port}/mac_irq] [get_bd_pins xlconcat_${concat_index}/In${int_index}]
  incr int_index
  connect_bd_net [get_bd_pins axi_ethernet_${port}/interrupt] [get_bd_pins xlconcat_${concat_index}/In${int_index}]
  incr int_index
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/mm2s_introut] [get_bd_pins xlconcat_${concat_index}/In${int_index}]
  incr int_index
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s2mm_introut] [get_bd_pins xlconcat_${concat_index}/In${int_index}]
  incr int_index
  if { $int_index == 8 } {
    set int_index 0
    incr concat_index
  }
}

# Connect ports for the Ethernet FMC 125MHz clock
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk
set_property -dict [list CONFIG.FREQ_HZ {125000000}] [get_bd_intf_ports ref_clk]
connect_bd_intf_net [get_bd_intf_ports ref_clk] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]

# Create Ethernet FMC reference clock output enable and frequency select

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_oe
create_bd_port -dir O -from 0 -to 0 ref_clk_oe
connect_bd_net [get_bd_pins /ref_clk_oe/dout] [get_bd_ports ref_clk_oe]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_fsel
create_bd_port -dir O -from 0 -to 0 ref_clk_fsel
connect_bd_net [get_bd_pins /ref_clk_fsel/dout] [get_bd_ports ref_clk_fsel]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
