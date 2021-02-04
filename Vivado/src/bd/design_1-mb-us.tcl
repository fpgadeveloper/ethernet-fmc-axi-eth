################################################################
# Block diagram build script for Microblaze Ultrascale FPGA designs
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

# Create the list of interrupts
set ints {}

# Add the Memory controller (MIG) for the DDR4
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4 ddr4_0

# Connect MIG external interfaces
if {[string match "kcu105*" $design_name]} {
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {default_sysclk_300 ( 300 MHz System differential clock ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {ddr4_sdram_062 ( DDR4 SDRAM ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_DDR4]
  # Add the 50MHz additional clock output for Quad SPI clock
  set_property -dict [list CONFIG.ADDN_UI_CLKOUT2_FREQ_HZ {50}] [get_bd_cells ddr4_0]
}
if {[string match "vcu108*" $design_name]} {
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {ddr4_sdram_c1_062 ( DDR4 SDRAM C1 ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_DDR4]

  # DDR4 clock buffer (see https://www.xilinx.com/support/answers/65263.html)
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0
  apply_board_connection -board_interface "default_sysclk1_300" -ip_intf "/util_ds_buf_0/CLK_IN_D" -diagram "$design_name"
  connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins ddr4_0/c0_sys_clk_i]
}
if {[string match "vcu118*" $design_name]} {
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {default_250mhz_clk1 ( 250 MHz System differential clock1 ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {ddr4_sdram_c1_062 ( DDR4 SDRAM C1 ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_DDR4]
}

# Board FPGA reset
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins ddr4_0/sys_rst]

# Add the Microblaze
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze microblaze_0
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {1} axi_periph {Enabled} cache {64KB} clk {/ddr4_0/addn_ui_clkout1 (100 MHz)} cores {1} debug_module {Debug Only} ecc {None} local_mem {64KB} preset {None}}  [get_bd_cells microblaze_0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/ddr4_0/addn_ui_clkout1 (100 MHz)} Clk_slave {/ddr4_0/c0_ddr4_ui_clk (300 MHz)} Clk_xbar {Auto} Master {/microblaze_0 (Cached)} Slave {/ddr4_0/C0_DDR4_S_AXI} ddr_seg {Auto} intc_ip {New AXI SmartConnect} master_apm {0}}  [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]

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
connect_bd_net [get_bd_ports reset] [get_bd_pins rst_ddr4_0_100M/ext_reset_in]

# Create the clock wizard to generate 300MHz, 125MHz and 250MHz from Ethernet FMC 125MHz ref clock (LPC)
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0
set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
CONFIG.PRIM_IN_FREQ {125} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.CLKOUT3_USED {true} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {333.333} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {250} \
CONFIG.USE_RESET {false} \
CONFIG.CLKIN1_JITTER_PS {80.0} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {8} \
CONFIG.MMCM_CLKOUT2_DIVIDE {4} \
CONFIG.NUM_OUT_CLKS {3} \
CONFIG.CLKOUT1_JITTER {99.263} \
CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
CONFIG.CLKOUT2_JITTER {119.348} \
CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
CONFIG.CLKOUT3_JITTER {104.759} \
CONFIG.CLKOUT3_PHASE_ERROR {96.948}] [get_bd_cells clk_wiz_0]

# Add proc system reset for the 250MHz clock generated by the clock wizard (LPC)
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_refclk_250M_0
connect_bd_net [get_bd_pins clk_wiz_0/clk_out3] [get_bd_pins rst_refclk_250M_0/slowest_sync_clk]
connect_bd_net [get_bd_ports reset] [get_bd_pins rst_refclk_250M_0/ext_reset_in]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins rst_refclk_250M_0/dcm_locked]

# Create a second clock wizard if this is a dual design (2x Ethernet FMCs)
if {$dual_design} {
  create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_1
  set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_1]
  set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.PRIM_IN_FREQ {125} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLKOUT3_USED {true} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {333.333} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {250} \
  CONFIG.USE_RESET {false} \
  CONFIG.CLKIN1_JITTER_PS {80.0} \
  CONFIG.MMCM_DIVCLK_DIVIDE {1} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {8} \
  CONFIG.MMCM_CLKOUT2_DIVIDE {4} \
  CONFIG.NUM_OUT_CLKS {3} \
  CONFIG.CLKOUT1_JITTER {99.263} \
  CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
  CONFIG.CLKOUT2_JITTER {119.348} \
  CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
  CONFIG.CLKOUT3_JITTER {104.759} \
  CONFIG.CLKOUT3_PHASE_ERROR {96.948}] [get_bd_cells clk_wiz_1]

  # Create the ports for the external ref clock input (1st Ethernet FMC)
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_0
  set_property -dict [list CONFIG.FREQ_HZ {125000000}] [get_bd_intf_ports ref_clk_0]
  connect_bd_intf_net [get_bd_intf_ports ref_clk_0] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]

  # Create the ports for the external ref clock input (2nd Ethernet FMC)
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_1
  set_property -dict [list CONFIG.FREQ_HZ {125000000}] [get_bd_intf_ports ref_clk_1]
  connect_bd_intf_net [get_bd_intf_ports ref_clk_1] [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]

  # Add proc system reset for the 250MHz clock generated by the clock wizard (HPC)
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_refclk_250M_1
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins rst_refclk_250M_1/slowest_sync_clk]
  connect_bd_net [get_bd_ports reset] [get_bd_pins rst_refclk_250M_1/ext_reset_in]
  connect_bd_net [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_refclk_250M_1/dcm_locked]

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
  # The first one will hold 16 - 2 - 1 = 13 DMA interfaces (first 2 slave ports 
  # go to MicroBlaze, and one will go to the extra AXI SmartConnect)
  create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smc_extra
  
  set num_extra_interfaces [expr {3 * [llength $ports]}]
  set num_extra_interfaces [expr {$num_extra_interfaces - 13}]
  
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {16} CONFIG.NUM_CLKS {4}] [get_bd_cells axi_smc]
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out3] [get_bd_pins axi_smc/aclk2]
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins axi_smc/aclk3]
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI $num_extra_interfaces CONFIG.NUM_CLKS {3}] [get_bd_cells axi_smc_extra]
  connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins axi_smc_extra/aclk]
  connect_bd_net [get_bd_pins ddr4_0/addn_ui_clkout1] [get_bd_pins axi_smc_extra/aclk1]
  connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins axi_smc_extra/aclk2]
  connect_bd_net [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn] [get_bd_pins axi_smc_extra/aresetn]
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
  set num_interfaces [expr {3 * [llength $ports]}]
  set num_interfaces [expr {$num_interfaces + 2}]
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI $num_interfaces CONFIG.NUM_CLKS {3}] [get_bd_cells axi_smc]
  connect_bd_net [get_bd_pins clk_wiz_0/clk_out3] [get_bd_pins axi_smc/aclk2]
}

# Ports with shared logic
set shared_logic_ports {0 4}

# AXI SmartConnect slave interface index, starts from 2 because 1st two ports taken by MicroBlaze
set smc_index 2
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
    connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out1] [get_bd_pins axi_ethernet_$port/ref_clk]
    connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out2] [get_bd_pins axi_ethernet_$port/gtx_clk]
  } else {
    set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_$port]
    connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out2] [get_bd_pins axi_ethernet_$port/gtx_clk]
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
  connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out3] [get_bd_pins axi_ethernet_${port}/axis_clk]
  connect_bd_net [get_bd_pins ddr4_0/addn_ui_clkout1] [get_bd_pins axi_ethernet_${port}/s_axi_lite_clk]

  # Connect clocks for AXI DMA
  connect_bd_net [get_bd_pins ddr4_0/addn_ui_clkout1] [get_bd_pins axi_ethernet_${port}_dma/s_axi_lite_aclk]
  connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out3] [get_bd_pins axi_ethernet_${port}_dma/m_axi_sg_aclk]
  connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out3] [get_bd_pins axi_ethernet_${port}_dma/m_axi_mm2s_aclk]
  connect_bd_net [get_bd_pins clk_wiz_${clk_wiz_index}/clk_out3] [get_bd_pins axi_ethernet_${port}_dma/m_axi_s2mm_aclk]

  # Connect resets between AXI DMA and Ethernet
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_txd_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_txc_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_rxd_arstn]
  connect_bd_net [get_bd_pins axi_ethernet_${port}_dma/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_${port}/axi_rxs_arstn]

  # AXI LITE reset
  connect_bd_net [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_${port}/s_axi_lite_resetn]
  connect_bd_net [get_bd_pins rst_ddr4_0_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_${port}_dma/axi_resetn]

  # Use automation to connect AXI LITE interfaces
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}/s_axi]
  set_property range 256K [get_bd_addr_segs "microblaze_0/Data/SEG_axi_ethernet_${port}_Reg0"]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_${port}_dma/S_AXI_LITE]

  # Manually connect DMA interfaces
  foreach dma_int {MM2S S2MM SG} {
    set interface_name S[format "%02d" $smc_index]_AXI
    connect_bd_intf_net [get_bd_intf_pins axi_ethernet_${port}_dma/M_AXI_${dma_int}] [get_bd_intf_pins $smc_name/$interface_name]
    assign_bd_address -target_address_space /axi_ethernet_${port}_dma/Data_${dma_int} [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
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

# Add UART for the Echo server example application
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550 axi_uart16550_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/ddr4_0/addn_ui_clkout1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/ddr4_0/addn_ui_clkout1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_uart16550_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_uart16550_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {rs232_uart ( UART ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_uart16550_0/UART]
append ints "axi_uart16550_0/ip2intc_irpt "

# Add Timer for the Echo server example application
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/ddr4_0/addn_ui_clkout1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/ddr4_0/addn_ui_clkout1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_timer_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_timer_0/S_AXI]
append ints "axi_timer_0/interrupt "

# Add IIC
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic iic_main
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {iic_main ( IIC ) } Manual_Source {Auto}}  [get_bd_intf_pins iic_main/IIC]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/ddr4_0/addn_ui_clkout1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/ddr4_0/addn_ui_clkout1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/iic_main/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins iic_main/S_AXI]
append ints "iic_main/iic2intc_irpt "

# Add the AXI Quad SPI for flash memory (KCU105 only)
if {[string match "kcu105*" $design_name]} {
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi axi_quad_spi_0
  set_property -dict [list CONFIG.C_SPI_MEMORY {2} CONFIG.C_USE_STARTUP {1} CONFIG.C_USE_STARTUP_INT {1} CONFIG.C_SPI_MODE {2} CONFIG.C_DUAL_QUAD_MODE {1} CONFIG.C_NUM_SS_BITS {2} CONFIG.C_SCK_RATIO {2} CONFIG.C_FIFO_DEPTH {256} CONFIG.QSPI_BOARD_INTERFACE {spi_flash}] [get_bd_cells axi_quad_spi_0]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/ddr4_0/addn_ui_clkout1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/ddr4_0/addn_ui_clkout1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_quad_spi_0/AXI_LITE} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {spi_flash ( QSPI flash ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_quad_spi_0/SPI_1]
  connect_bd_net [get_bd_pins axi_quad_spi_0/ext_spi_clk] [get_bd_pins ddr4_0/addn_ui_clkout2]
  append ints "axi_quad_spi_0/ip2intc_irpt "
}

# Configure Microblaze interrupt concat
set num_ints [llength $ints]
set_property -dict [list CONFIG.NUM_PORTS $num_ints] [get_bd_cells microblaze_0_xlconcat]
set input_index -1
foreach interrupt_pin $ints {
  incr input_index
  connect_bd_net [get_bd_pins ${interrupt_pin}] [get_bd_pins microblaze_0_xlconcat/In${input_index}]
}

# Reset GPIO
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio reset_gpio
set_property -dict [list CONFIG.C_GPIO_WIDTH {1} CONFIG.C_ALL_OUTPUTS {1}] [get_bd_cells reset_gpio]
set_property -dict [list CONFIG.C_AUX_RST_WIDTH {1} CONFIG.C_AUX_RESET_HIGH {1}] [get_bd_cells rst_ddr4_0_100M]
connect_bd_net [get_bd_pins reset_gpio/gpio_io_o] [get_bd_pins rst_ddr4_0_100M/aux_reset_in]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/ddr4_0/addn_ui_clkout1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/ddr4_0/addn_ui_clkout1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/reset_gpio/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins reset_gpio/S_AXI]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
