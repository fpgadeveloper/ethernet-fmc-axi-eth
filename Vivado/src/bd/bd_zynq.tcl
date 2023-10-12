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

create_bd_design $block_name

current_bd_design $block_name

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

# Highest port number - work out if this is a dual FMC design or not
set highest_port [tcl::mathfunc::max {*}$ports]
if {$highest_port > 3} {
  set dual_design 1
} else {
  set dual_design 0
}

# Add the Processor System and apply board preset
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Configure the PS: Enable HP0, Enable interrupts
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]

# The ZedBoard design requires the I2C0 peripheral to be enabled in PS
if {$target == "zedboard"} {
  set_property -dict [list CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1}] [get_bd_cells processing_system7_0]
}

# Connect the FCLK_CLK0 to the PS GP0 and HP0
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK]

# Processor system reset for 50MHz FCLK0 clock
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_ps7_0_50M
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins rst_ps7_0_50M/slowest_sync_clk]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_50M/ext_reset_in]

# Create AXI SmartConnect for the DMA interfaces
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smc
connect_bd_intf_net [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]

# Clock wizard to generate 125MHz and 200MHz from Ethernet FMC reference clock
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0
set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
CONFIG.PRIM_IN_FREQ {125} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200} \
CONFIG.USE_RESET {false} \
CONFIG.CLKIN1_JITTER_PS {80.0} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {5} \
CONFIG.NUM_OUT_CLKS {2} \
CONFIG.CLKOUT1_JITTER {119.348} \
CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
CONFIG.CLKOUT2_JITTER {109.241} \
CONFIG.CLKOUT2_PHASE_ERROR {96.948}] [get_bd_cells clk_wiz_0]

# Processor system reset for 125MHz clock
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_clk_wiz_0_125M
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins rst_clk_wiz_0_125M/slowest_sync_clk]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins rst_clk_wiz_0_125M/dcm_locked]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_clk_wiz_0_125M/ext_reset_in]

# Add the concat for the interrupts
set num_ints [expr {4 * [llength $ports]}]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0
set_property -dict [list CONFIG.NUM_PORTS $num_ints] [get_bd_cells xlconcat_0]

# Create a second clock wizard if this is a dual design (2x Ethernet FMCs)
if {$dual_design} {
  # Clock wizard to generate 125MHz and 200MHz from Ethernet FMC reference clock
  create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_1
  set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_1]
  set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.PRIM_IN_FREQ {125} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200} \
  CONFIG.USE_RESET {false} \
  CONFIG.CLKIN1_JITTER_PS {80.0} \
  CONFIG.MMCM_DIVCLK_DIVIDE {1} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {5} \
  CONFIG.NUM_OUT_CLKS {2} \
  CONFIG.CLKOUT1_JITTER {119.348} \
  CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
  CONFIG.CLKOUT2_JITTER {109.241} \
  CONFIG.CLKOUT2_PHASE_ERROR {96.948}] [get_bd_cells clk_wiz_1]

  # Processor system reset for 125MHz clock
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_clk_wiz_1_125M
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins rst_clk_wiz_1_125M/slowest_sync_clk]
  connect_bd_net [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_clk_wiz_1_125M/dcm_locked]
  connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_clk_wiz_1_125M/ext_reset_in]

  # Create port for Ethernet FMC reference clock and connect to clock wizard (1st Eth FMC)
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_0
  set_property -dict [list CONFIG.FREQ_HZ {125000000}] [get_bd_intf_ports ref_clk_0]
  connect_bd_intf_net [get_bd_intf_ports ref_clk_0] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]

  # Create port for Ethernet FMC reference clock and connect to clock wizard (2nd Eth FMC)
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_1
  set_property -dict [list CONFIG.FREQ_HZ {125000000}] [get_bd_intf_ports ref_clk_1]
  connect_bd_intf_net [get_bd_intf_ports ref_clk_1] [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]

  # Create Ethernet FMC reference clock output enable and frequency select

  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_0_oe
  create_bd_port -dir O -from 0 -to 0 ref_clk_0_oe
  connect_bd_net [get_bd_pins /ref_clk_0_oe/dout] [get_bd_ports ref_clk_0_oe]

  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_1_oe
  create_bd_port -dir O -from 0 -to 0 ref_clk_1_oe
  connect_bd_net [get_bd_pins /ref_clk_1_oe/dout] [get_bd_ports ref_clk_1_oe]

  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_0_fsel
  create_bd_port -dir O -from 0 -to 0 ref_clk_0_fsel
  connect_bd_net [get_bd_pins /ref_clk_0_fsel/dout] [get_bd_ports ref_clk_0_fsel]

  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_1_fsel
  create_bd_port -dir O -from 0 -to 0 ref_clk_1_fsel
  connect_bd_net [get_bd_pins /ref_clk_1_fsel/dout] [get_bd_ports ref_clk_1_fsel]

  # Setup a second AXI SmartConnect for the DMA interfaces
  # because one AXI SmartConnect is limited to only 16 slave ports
  # The first one will hold 16 - 1 = 15 DMA interfaces
  # (one will go to the extra AXI SmartConnect)
  create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smc_extra
  
  set num_extra_interfaces [expr {3 * [llength $ports]}]
  set num_extra_interfaces [expr {$num_extra_interfaces - 15}]
  
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {16} CONFIG.NUM_CLKS {3}] [get_bd_cells axi_smc]
  connect_bd_net [get_bd_pins processing_system7_0/fclk_clk0] [get_bd_pins axi_smc/aclk]
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_smc/aclk1]
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_smc/aclk2]
  connect_bd_net [get_bd_pins rst_ps7_0_50M/peripheral_aresetn] [get_bd_pins axi_smc/aresetn]
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI $num_extra_interfaces CONFIG.NUM_CLKS {2}] [get_bd_cells axi_smc_extra]
  connect_bd_net [get_bd_pins processing_system7_0/fclk_clk0] [get_bd_pins axi_smc_extra/aclk]
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_smc_extra/aclk1]
  connect_bd_net [get_bd_pins rst_ps7_0_50M/peripheral_aresetn] [get_bd_pins axi_smc_extra/aresetn]
  connect_bd_intf_net [get_bd_intf_pins axi_smc_extra/M00_AXI] [get_bd_intf_pins axi_smc/S15_AXI]
  
  # Dual designs need AXI INTC because Zynq PL-PS interrupts can only take 16 interrupts
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_0
  connect_bd_net [get_bd_pins axi_intc_0/irq] [get_bd_pins processing_system7_0/IRQ_F2P]
  connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins axi_intc_0/intr]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_intc_0/s_axi} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_intc_0/s_axi]
  
} else {

  # Create port for Ethernet FMC reference clock and connect to clock wizard
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

  # Only a single AXI SmartConnect is required in the single Ethernet FMC design
  set num_interfaces [expr {3 * [llength $ports]}]
  set_property -dict [list CONFIG.NUM_SI $num_interfaces CONFIG.NUM_CLKS {2}] [get_bd_cells axi_smc]
  connect_bd_net [get_bd_pins processing_system7_0/fclk_clk0] [get_bd_pins axi_smc/aclk]
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_smc/aclk1]
  connect_bd_net [get_bd_pins rst_ps7_0_50M/peripheral_aresetn] [get_bd_pins axi_smc/aresetn]
  
  # Single Eth FMC designs use the Zynq PS interrupt handler
  connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins processing_system7_0/IRQ_F2P]
}

# I2C port for ZedBoard design
if {$target == "zedboard"} {
  # Add the port for IIC
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_fmc
  connect_bd_intf_net [get_bd_intf_pins processing_system7_0/IIC_0] [get_bd_intf_ports iic_fmc]
}

# Interrupt index starts from 0, increments each time through loop
set int_index 0

# AXI SmartConnect slave interface index
set smc_index 0
set smc_name axi_smc

# Add and configure AXI Ethernet IPs with AXI DMAs
foreach port $ports {
  # For ports 0-3, use clk_wiz_0, for ports 4-7, use clk_wiz_1
  set clk_wiz_index [expr {$port > 3}]

  # Add the AXI Ethernet IPs
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_$port

  # Configure all ports for full checksum hardware offload except ZC702 dual design
  if {$target == "zc702_lpc2_lpc1"} {
    set_property -dict [list CONFIG.TXCSUM {None} CONFIG.RXCSUM {None}] [get_bd_cells axi_ethernet_$port]
  } else {
    set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_$port]
  }

  # ZC702 dual: Reduce TX and RX memory size to the lowest value (2k) to save LUTs
  if {$target == "zc702_lpc2_lpc1"} {
    set_property -dict [list CONFIG.RXMEM {2k} CONFIG.TXMEM {2k}] [get_bd_cells axi_ethernet_$port]
  }

  # PicoZed 7015 and ZC702 dual: Disable frame filter and stats counters to free LUTs
  if {$target == "pz_7015" || $target == "zc702_lpc2_lpc1"} {
    set_property -dict [list CONFIG.Frame_Filter {false} CONFIG.Statistics_Counters {false}] [get_bd_cells axi_ethernet_$port]
  }

  # If this is a shared logic port, then "Include shared logic"
  if {[lsearch -exact $shared_logic_ports $port] >= 0} {
    set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {1}] [get_bd_cells axi_ethernet_$port]
    connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out2] [get_bd_pins axi_ethernet_$port/ref_clk]
    connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1] [get_bd_pins axi_ethernet_$port/gtx_clk]
  } else {
    set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_$port]
  }

  # Create DMAs
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_${port}_dma

  # Configure the DMAs
  set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_${port}_dma]

  # Connect DMAs to AXI Ethernets
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/m_axis_rxd] [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXIS_S2MM]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/m_axis_rxs] [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXIS_STS]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/s_axis_txc] [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXIS_CNTRL]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/s_axis_txd] [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXIS_MM2S]

  # Connect AXI clocks
  connect_bd_net [get_bd_pins axi_ethernet_${port}/s_axi_lite_clk] [get_bd_pins processing_system7_0/fclk_clk0]
  connect_bd_net [get_bd_pins axi_ethernet_${port}/axis_clk] [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s_axi_lite_aclk] [get_bd_pins processing_system7_0/fclk_clk0]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/m_axi_sg_aclk] [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/m_axi_mm2s_aclk] [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/m_axi_s2mm_aclk] [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1]

  # Resets
  connect_bd_net [get_bd_pins axi_ethernet_${port}/axi_txd_arstn] [get_bd_pins axi_ethernet_${port}_dma/mm2s_prmry_reset_out_n]
  connect_bd_net [get_bd_pins axi_ethernet_${port}/axi_txc_arstn] [get_bd_pins axi_ethernet_${port}_dma/mm2s_cntrl_reset_out_n]
  connect_bd_net [get_bd_pins axi_ethernet_${port}/axi_rxd_arstn] [get_bd_pins axi_ethernet_${port}_dma/s2mm_prmry_reset_out_n]
  connect_bd_net [get_bd_pins axi_ethernet_${port}/axi_rxs_arstn] [get_bd_pins axi_ethernet_${port}_dma/s2mm_sts_reset_out_n]

  connect_bd_net [get_bd_pins axi_ethernet_${port}/s_axi_lite_resetn] [get_bd_pins rst_ps7_0_50M/peripheral_aresetn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/axi_resetn] [get_bd_pins rst_ps7_0_50M/peripheral_aresetn]
  
  # Use automation to connect AXI LITE interfaces
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_${port}/s_axi]
  set_property range 256K [get_bd_addr_segs "processing_system7_0/Data/SEG_axi_ethernet_${port}_Reg0"]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXI_LITE]

  # Connect DMA interfaces to AXI SmartConnect
  #apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master "/axi_ethernet_${port}_dma/M_AXI_MM2S" Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_MM2S]
  #apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master "/axi_ethernet_${port}_dma/M_AXI_S2MM" Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_S2MM]
  #apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master "/axi_ethernet_${port}_dma/M_AXI_SG" Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_SG]

  # Manually connect DMA interfaces
  foreach dma_int {MM2S S2MM SG} {
    set interface_name S[format "%02d" $smc_index]_AXI
    connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_${dma_int}] [get_bd_intf_pins $smc_name/$interface_name]
    assign_bd_address -target_address_space /axi_ethernet_${port}_dma/Data_${dma_int} [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force
    incr smc_index
    # When we reach the end of the 1st AXI SMC, then switch to the extra AXI SMC, and reset the interface index
    if {$smc_index >= 15} {
      set smc_name axi_smc_extra
      set smc_index 0
    }
  }
  
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

  # Connect interrupts
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/mm2s_introut] [get_bd_pins xlconcat_0/In${int_index}]
  incr int_index
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s2mm_introut] [get_bd_pins xlconcat_0/In${int_index}]
  incr int_index
  connect_bd_net [get_bd_pins axi_ethernet_${port}/mac_irq] [get_bd_pins xlconcat_0/In${int_index}]
  incr int_index
  connect_bd_net [get_bd_pins axi_ethernet_${port}/interrupt] [get_bd_pins xlconcat_0/In${int_index}]
  incr int_index
}

# Connect gtx_clk inputs: Connect the gtx_clk and gtx_clk90 inputs to the AXI Ethernet with shared logic
# We have to run this after all of the AXI Ethernet IPs are created, otherwise the shared logic port may not yet be instantiated
foreach port $ports {
  # If this is a shared logic port, clocks are already connected
  if {[lsearch -exact $shared_logic_ports $port] >= 0} {
    continue
  }
  
  # If this port is on the 1st Ethernet FMC, then use 1st shared logic port
  if {$port <= 3} {
    set shared_logic_port [lindex $shared_logic_ports 0]
    set clk_wiz_index 0
  } else {
    set shared_logic_port [lindex $shared_logic_ports 1]
    set clk_wiz_index 1
  }
  
  connect_bd_net [get_bd_pins axi_ethernet_${shared_logic_port}/gtx_clk_out] [get_bd_pins axi_ethernet_${port}/gtx_clk]
  connect_bd_net [get_bd_pins axi_ethernet_${shared_logic_port}/gtx_clk90_out] [get_bd_pins axi_ethernet_${port}/gtx_clk90]
}

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design

