################################################################
# Block diagram build script for Microblaze 7-Series FPGA designs
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

# Highest port number - work out if this is a dual FMC design or not
set highest_port [tcl::mathfunc::max {*}$ports]
if {$highest_port > 3} {
  set dual_design 1
} else {
  set dual_design 0
}

# Virtex designs have slightly different AXI Ethernet clock connections
if {[string match "vc70*" $design_name]} {
  set virtex_design 1
} else {
  set virtex_design 0
}

# Total number of DMA interfaces required (3 per port)
set dma_interfaces [expr {3 * [llength $ports]}]

# Create the list of interrupts
set ints {}

# Add the Memory controller (MIG) for the DDR3
create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series mig_0

# Connect MIG external interfaces
if {[string match "vc709*" $design_name]} {
  apply_bd_automation -rule xilinx.com:bd_rule:mig_7series -config {Board_Interface "ddr3_sdram_socket_j1" }  [get_bd_cells mig_0]
} else {
  apply_bd_automation -rule xilinx.com:bd_rule:mig_7series -config {Board_Interface "ddr3_sdram" }  [get_bd_cells mig_0]
}

# Board FPGA reset
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins mig_0/sys_rst]

# Create ports
create_bd_port -dir O mmcm_lock
connect_bd_net [get_bd_ports mmcm_lock] [get_bd_pins mig_0/mmcm_locked]
create_bd_port -dir O init_calib_complete
connect_bd_net [get_bd_ports init_calib_complete] [get_bd_pins mig_0/init_calib_complete]

# Add the Microblaze
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze microblaze_0
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {1} axi_periph {Enabled} cache {64KB} clk {/mig_0/ui_addn_clk_0 (100 MHz)} cores {1} debug_module {Debug Only} ecc {None} local_mem {64KB} preset {None}}  [get_bd_cells microblaze_0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_slave {/mig_0/ui_clk (200 MHz)} Clk_xbar {Auto} Master {/microblaze_0 (Cached)} Slave {/mig_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI SmartConnect} master_apm {0}}  [get_bd_intf_pins mig_0/S_AXI]

# Configure MicroBlaze for Linux
set_property -dict [list CONFIG.G_TEMPLATE_LIST {4} \
CONFIG.G_USE_EXCEPTIONS {1} \
CONFIG.C_USE_MSR_INSTR {1} \
CONFIG.C_USE_PCMP_INSTR {1} \
CONFIG.C_USE_BARREL {1} \
CONFIG.C_USE_DIV {1} \
CONFIG.C_USE_HW_MUL {2} \
CONFIG.C_UNALIGNED_EXCEPTIONS {1} \
CONFIG.C_ILL_OPCODE_EXCEPTION {1} \
CONFIG.C_M_AXI_I_BUS_EXCEPTION {1} \
CONFIG.C_M_AXI_D_BUS_EXCEPTION {1} \
CONFIG.C_DIV_ZERO_EXCEPTION {1} \
CONFIG.C_PVR {2} \
CONFIG.C_OPCODE_0x0_ILLEGAL {1} \
CONFIG.C_ICACHE_LINE_LEN {8} \
CONFIG.C_ICACHE_VICTIMS {8} \
CONFIG.C_ICACHE_STREAMS {1} \
CONFIG.C_DCACHE_VICTIMS {8} \
CONFIG.C_USE_MMU {3} \
CONFIG.C_MMU_ZONES {2}] [get_bd_cells microblaze_0]

# Connect 100MHz processor system reset external reset to the reset port
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {Auto}}  [get_bd_pins rst_mig_0_100M/ext_reset_in]

# Number of MIG slaves, starts at 2: MicroBlaze cached interfaces
# This design assumes we only have a MAXIMUM of 4 mig_slaves, otherwise the AXI SMC management needs changing
set mig_slaves 2

# VC707 and VC709 have linear flash needing AXI EMC
if {$virtex_design} {
  # Add AXI EMC (linear flash) for PetaLinux
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_emc axi_emc_0
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/microblaze_0 (Cached)} Slave {/axi_emc_0/S_AXI_MEM} ddr_seg {Auto} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins axi_emc_0/S_AXI_MEM]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {linear_flash ( Linear flash ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_emc_0/EMC_INTF]
  #apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/mig_0/ui_addn_clk_0 (100 MHz)} Freq {100} Ref_Clk0 {None} Ref_Clk1 {None} Ref_Clk2 {None}}  [get_bd_pins axi_emc_0/rdclk]
  apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {Auto} Freq {100} Ref_Clk0 {None} Ref_Clk1 {None} Ref_Clk2 {None}}  [get_bd_pins axi_emc_0/rdclk]
}

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
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_clk_wiz_0_125M_0
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins rst_clk_wiz_0_125M_0/slowest_sync_clk]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins rst_clk_wiz_0_125M_0/dcm_locked]
connect_bd_net [get_bd_ports reset] [get_bd_pins rst_clk_wiz_0_125M_0/ext_reset_in]

# Create a second clock wizard if this is a dual design (2x Ethernet FMCs)
if {$dual_design} {
  # Clock wizard to generate 125MHz and 200MHz from 2nd Ethernet FMC reference clock
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
  CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {5} \
  CONFIG.NUM_OUT_CLKS {2} \
  CONFIG.CLKOUT1_JITTER {119.348} \
  CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
  CONFIG.CLKOUT2_JITTER {109.241} \
  CONFIG.CLKOUT2_PHASE_ERROR {96.948}] [get_bd_cells clk_wiz_1]

  # Create the ports for the external ref clock input (1st Ethernet FMC)
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_0
  set_property -dict [list CONFIG.FREQ_HZ {125000000}] [get_bd_intf_ports ref_clk_0]
  connect_bd_intf_net [get_bd_intf_ports ref_clk_0] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]

  # Create the ports for the external ref clock input (2nd Ethernet FMC)
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_1
  set_property -dict [list CONFIG.FREQ_HZ {125000000}] [get_bd_intf_ports ref_clk_1]
  connect_bd_intf_net [get_bd_intf_ports ref_clk_1] [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]

  # Processor system reset for 125MHz clock
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_clk_wiz_0_125M_1
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins rst_clk_wiz_0_125M_1/slowest_sync_clk]
  connect_bd_net [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_clk_wiz_0_125M_1/dcm_locked]
  connect_bd_net [get_bd_ports reset] [get_bd_pins rst_clk_wiz_0_125M_1/ext_reset_in]

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
  # The first one will hold (16 - $mig_slaves - 1) DMA interfaces
  # (some used by mig_slaves and one will go to the extra AXI SmartConnect)
  create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smc_extra
  
  set dma_on_first_smc [expr {15 - $mig_slaves}]
  
  set num_extra_interfaces [expr {$dma_interfaces - $dma_on_first_smc}]
  
  set_property -dict [list CONFIG.NUM_SI {16} CONFIG.NUM_CLKS {4}] [get_bd_cells axi_smc]
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_smc/aclk2]
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_smc/aclk3]
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI $num_extra_interfaces CONFIG.NUM_CLKS {3}] [get_bd_cells axi_smc_extra]
  connect_bd_net [get_bd_pins mig_0/ui_clk] [get_bd_pins axi_smc_extra/aclk]
  connect_bd_net [get_bd_pins mig_0/ui_addn_clk_0] [get_bd_pins axi_smc_extra/aclk1]
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_smc_extra/aclk2]
  connect_bd_net [get_bd_pins rst_mig_0_100M/peripheral_aresetn] [get_bd_pins axi_smc_extra/aresetn]
  connect_bd_intf_net [get_bd_intf_pins axi_smc_extra/M00_AXI] [get_bd_intf_pins axi_smc/S15_AXI]
  
} else {

  # Create the ports for the external ref clock input (1st Ethernet FMC only)
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
  set num_interfaces [expr {$dma_interfaces + $mig_slaves}]
  set_property -dict [list CONFIG.NUM_SI $num_interfaces CONFIG.NUM_CLKS {3}] [get_bd_cells axi_smc]
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_smc/aclk2]
}

# Ports with shared logic
# Warning: We are assuming that these ports are included in the ports list
set shared_logic_ports {0 4}

# AXI SmartConnect slave interface index
set smc_index $mig_slaves

# Name of the first AXI SmartConnect
set smc_name axi_smc

# Add and configure AXI Ethernet IPs with AXI DMAs
foreach port $ports {
  # For ports 0-3, use clk_wiz_0, for ports 4-7, use clk_wiz_1
  set clk_wiz_index [expr {$port > 3}]

  # Add the AXI Ethernet IPs for the LPC
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_$port
  
  # Configure all ports for full checksum hardware offload
  set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_$port]

  # If this is a shared logic port, then "Include shared logic"
  if {[lsearch -exact $shared_logic_ports $port] >= 0} {
    set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {1}] [get_bd_cells axi_ethernet_$port]
    connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out2] [get_bd_pins axi_ethernet_$port/ref_clk]
    connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1] [get_bd_pins axi_ethernet_$port/gtx_clk]
  } else {
    set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_$port]
  }

  # Disable the stats counters and frame filters to help pass timing
  set_property -dict [list CONFIG.Statistics_Counters {false} CONFIG.Frame_Filter {false}] [get_bd_cells axi_ethernet_$port]

  # Create DMA
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_${port}_dma
  set_property -dict [list CONFIG.c_sg_length_width {16} CONFIG.c_include_mm2s_dre {1} CONFIG.c_sg_use_stsapp_length {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_${port}_dma]

  # Connect AXI streaming interfaces
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/m_axis_rxd] [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXIS_S2MM]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/m_axis_rxs] [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXIS_STS]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/s_axis_txd] [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXIS_MM2S]
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}/s_axis_txc] [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXIS_CNTRL]

  # Connect clocks for AXI Ethernet Subsystem
  connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1] [get_bd_pins axi_ethernet_${port}/axis_clk]
  connect_bd_net [get_bd_pins mig_0/ui_addn_clk_0] [get_bd_pins axi_ethernet_${port}/s_axi_lite_clk]

  # Connect clocks for AXI DMA
  connect_bd_net [get_bd_pins mig_0/ui_addn_clk_0] [get_bd_pins axi_ethernet_${port}_dma/s_axi_lite_aclk]
  connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1] [get_bd_pins axi_ethernet_${port}_dma/m_axi_sg_aclk]
  connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1] [get_bd_pins axi_ethernet_${port}_dma/m_axi_mm2s_aclk]
  connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1] [get_bd_pins axi_ethernet_${port}_dma/m_axi_s2mm_aclk]

  # Connect resets between AXI DMA and Ethernet
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_txd_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_txc_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_rxd_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_rxs_arstn]

  # AXI LITE reset
  connect_bd_net [get_bd_pins rst_mig_0_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_${port}/s_axi_lite_resetn]
  connect_bd_net [get_bd_pins rst_mig_0_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_${port}_dma/axi_resetn]

  # Use automation to connect AXI LITE interfaces
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}/s_axi]
  set_property range 256K [get_bd_addr_segs "microblaze_0/Data/SEG_axi_ethernet_${port}_Reg0"]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXI_LITE]

  # Manually connect DMA interfaces
  foreach dma_int {MM2S S2MM SG} {
    set interface_name S[format "%02d" $smc_index]_AXI
    connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_${dma_int}] [get_bd_intf_pins $smc_name/$interface_name]
    assign_bd_address -target_address_space /axi_ethernet_${port}_dma/Data_${dma_int} [get_bd_addr_segs mig_0/memmap/memaddr] -force
    if {$virtex_design} {
      exclude_bd_addr_seg [get_bd_addr_segs axi_emc_0/S_AXI_MEM/Mem0] -target_address_space [get_bd_addr_spaces axi_ethernet_${port}_dma/Data_${dma_int}]
    }
    set smc_index [expr {$smc_index + 1}]
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

  # Connect interrupts (Note: we sacrifice "mac_irq" to fit up to 8 ports without using cascaded int controllers)
  append ints "axi_ethernet_${port}_dma/mm2s_introut "
  append ints "axi_ethernet_${port}_dma/s2mm_introut "
  append ints "axi_ethernet_${port}/interrupt "
}

# Connect gtx_clk inputs:
#   Artix, Kintex: Connect the gtx_clk and gtx_clk90 inputs to the AXI Ethernet with shared logic
#   Virtex: Connect the gtx_clk to the clock wizard output (gtx_clk90 does not exist for Virtex)
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
  
  if {$virtex_design} {
    connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1] [get_bd_pins axi_ethernet_$port/gtx_clk]
  } else {
    connect_bd_net [get_bd_pins axi_ethernet_${shared_logic_port}/gtx_clk_out] [get_bd_pins axi_ethernet_${port}/gtx_clk]
    connect_bd_net [get_bd_pins axi_ethernet_${shared_logic_port}/gtx_clk90_out] [get_bd_pins axi_ethernet_${port}/gtx_clk90]
  }
}

# Add UART for the Echo server example application
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550 axi_uart16550_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_uart16550_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "rs232_uart ( UART ) " }  [get_bd_intf_pins axi_uart16550_0/UART]
append ints "axi_uart16550_0/ip2intc_irpt "

# Add Timer for the Echo server example application
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_timer_0/S_AXI]
append ints "axi_timer_0/interrupt "

# Add IIC
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic iic_main
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {iic_main ( IIC ) } Manual_Source {Auto}}  [get_bd_intf_pins iic_main/IIC]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_slave {Auto} Clk_xbar {/mig_0/ui_addn_clk_0 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/iic_main/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins iic_main/S_AXI]
append ints "iic_main/iic2intc_irpt "

# Reset GPIO
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio reset_gpio
set_property -dict [list CONFIG.C_GPIO_WIDTH {1} CONFIG.C_ALL_OUTPUTS {1}] [get_bd_cells reset_gpio]
set_property -dict [list CONFIG.C_AUX_RST_WIDTH {1} CONFIG.C_AUX_RESET_HIGH {1}] [get_bd_cells rst_mig_0_100M]
connect_bd_net [get_bd_pins reset_gpio/gpio_io_o] [get_bd_pins rst_mig_0_100M/aux_reset_in]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_slave {Auto} Clk_xbar {/mig_0/ui_addn_clk_0 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/reset_gpio/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins reset_gpio/S_AXI]

# KC705 only IP
if {[string match "kc705*" $design_name]} {
  # Add BPI Flash for PetaLinux (KC705 only)
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_emc axi_emc_0
  set_property -dict [list CONFIG.USE_BOARD_FLOW {true} \
  CONFIG.EMC_BOARD_INTERFACE {linear_flash} \
  CONFIG.C_MEM0_TYPE {2} \
  CONFIG.C_S_AXI_MEM_ID_WIDTH.VALUE_SRC {USER} \
  CONFIG.C_S_AXI_MEM_ID_WIDTH {0} \
  CONFIG.C_WR_REC_TIME_MEM_0 {0} \
  CONFIG.C_TLZWE_PS_MEM_0 {0} \
  CONFIG.C_TWPH_PS_MEM_0 {20000} \
  CONFIG.C_TWP_PS_MEM_0 {50000} \
  CONFIG.C_TWC_PS_MEM_0 {19000} \
  CONFIG.C_THZOE_PS_MEM_0 {15000} \
  CONFIG.C_THZCE_PS_MEM_0 {20000} \
  CONFIG.C_TPACC_PS_FLASH_0 {25000} \
  CONFIG.C_TAVDV_PS_MEM_0 {100000} \
  CONFIG.C_TCEDV_PS_MEM_0 {100000}] [get_bd_cells axi_emc_0]
  connect_bd_net [get_bd_pins mig_0/ui_addn_clk_0] [get_bd_pins axi_emc_0/s_axi_aclk]
  connect_bd_net [get_bd_pins mig_0/ui_addn_clk_0] [get_bd_pins axi_emc_0/rdclk]
  connect_bd_net [get_bd_pins rst_mig_0_100M/peripheral_aresetn] [get_bd_pins axi_emc_0/s_axi_aresetn]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {linear_flash ( Linear flash ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_emc_0/EMC_INTF]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_slave {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_xbar {/mig_0/ui_addn_clk_0 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_emc_0/S_AXI_MEM} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_emc_0/S_AXI_MEM]
  set_property range 128M [get_bd_addr_segs {microblaze_0/Data/SEG_axi_emc_0_Mem0}]

  # Add EthernetLite (on-board port)
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernetlite axi_ethernetlite
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {mdio_mdc ( Onboard PHY ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_ethernetlite/MDIO]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {mii ( Onboard PHY ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_ethernetlite/MII]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_slave {Auto} Clk_xbar {/mig_0/ui_addn_clk_0 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernetlite/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernetlite/S_AXI]
  append ints "axi_ethernetlite/ip2intc_irpt "
}

# AC701 only IP
if {[string match "ac701*" $design_name]} {
  # Add the AXI Quad SPI for flash memory
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi axi_quad_spi_0
  apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "spi_flash ( SPI flash ) " }  [get_bd_intf_pins axi_quad_spi_0/SPI_0]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
  apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/mig_0/ui_addn_clk_0 (100 MHz)" }  [get_bd_pins axi_quad_spi_0/ext_spi_clk]
  append ints "axi_quad_spi_0/ip2intc_irpt "

  ## AXI Ethernet
  create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smc_eth
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {3} CONFIG.NUM_CLKS {3}] [get_bd_cells axi_smc_eth]
  connect_bd_net [get_bd_pins mig_0/ui_addn_clk_0] [get_bd_pins axi_smc_eth/aclk]
  connect_bd_net [get_bd_pins mig_0/ui_clk] [get_bd_pins axi_smc_eth/aclk1]
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_smc_eth/aclk2]
  connect_bd_net [get_bd_pins rst_mig_0_100M/peripheral_aresetn] [get_bd_pins axi_smc_eth/aresetn]
  # Add extra slave interface on axi_smc then connect
  set_property -dict [list CONFIG.NUM_SI [expr {$num_interfaces + 1}]] [get_bd_cells axi_smc]
  set interface_name S[format "%02d" $num_interfaces]_AXI
  connect_bd_intf_net [get_bd_intf_pins axi_smc_eth/M00_AXI] [get_bd_intf_pins axi_smc/$interface_name]
  # Create AXI Ethernet
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet
  set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet]
  apply_bd_automation -rule xilinx.com:bd_rule:axi_ethernet -config { FIFO_DMA {DMA} PHY_TYPE {RGMII}}  [get_bd_cells axi_ethernet]
  # Connect DMA to axi_smc_eth
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_dma/M_AXI_MM2S] [get_bd_intf_pins axi_smc_eth/S00_AXI]
  assign_bd_address -target_address_space /axi_ethernet_dma/Data_MM2S [get_bd_addr_segs mig_0/memmap/memaddr] -force
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_dma/M_AXI_S2MM] [get_bd_intf_pins axi_smc_eth/S01_AXI]
  assign_bd_address -target_address_space /axi_ethernet_dma/Data_S2MM [get_bd_addr_segs mig_0/memmap/memaddr] -force
  connect_bd_intf_net [get_bd_intf_pins axi_ethernet_dma/M_AXI_SG] [get_bd_intf_pins axi_smc_eth/S02_AXI]
  assign_bd_address -target_address_space /axi_ethernet_dma/Data_SG [get_bd_addr_segs mig_0/memmap/memaddr] -force
  # Connect clocks for AXI Ethernet Subsystem
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet/axis_clk]
  connect_bd_net [get_bd_pins mig_0/ui_addn_clk_0] [get_bd_pins axi_ethernet/s_axi_lite_clk]
  # Connect clocks for AXI DMA
  connect_bd_net [get_bd_pins mig_0/ui_addn_clk_0] [get_bd_pins axi_ethernet_dma/s_axi_lite_aclk]
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet_dma/m_axi_sg_aclk]
  # Automation connect AXI Lite interfaces
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_slave {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_xbar {/mig_0/ui_addn_clk_0 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernet/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet/s_axi]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_slave {/mig_0/ui_addn_clk_0 (100 MHz)} Clk_xbar {/mig_0/ui_addn_clk_0 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernet_dma/S_AXI_LITE} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_dma/S_AXI_LITE]
  ## Connect interrupts
  append ints "axi_ethernet/mac_irq "
  append ints "axi_ethernet/interrupt "
  append ints "axi_ethernet_dma/mm2s_introut "
  append ints "axi_ethernet_dma/s2mm_introut "
}

# Configure Microblaze interrupt concat
set num_ints [llength $ints]
set_property -dict [list CONFIG.NUM_PORTS $num_ints] [get_bd_cells microblaze_0_xlconcat]
set input_index -1
foreach interrupt_pin $ints {
  incr input_index
  connect_bd_net [get_bd_pins ${interrupt_pin}] [get_bd_pins microblaze_0_xlconcat/In${input_index}]
}

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
