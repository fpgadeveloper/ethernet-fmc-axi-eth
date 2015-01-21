
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7vx690tffg1761-2
#    set_property BOARD_PART xilinx.com:vc709:part0:1.5 [current_project]


# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"
     return
  }

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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst LMB_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list CONFIG.C_ECC {0}  ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list CONFIG.C_ECC {0}  ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 lmb_bram ]
  set_property -dict [ list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.use_bram_block {BRAM_Controller}  ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]
  connect_bd_net -net microblaze_0_LMB_Rst [get_bd_pins LMB_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

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


  # Create interface ports
  set ddr3_sdram_socket_j1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3_sdram_socket_j1 ]
  set mdio_io_port_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_0 ]
  set mdio_io_port_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_1 ]
  set mdio_io_port_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_2 ]
  set mdio_io_port_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_3 ]
  set rgmii_port_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_0 ]
  set rgmii_port_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_1 ]
  set rgmii_port_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2 ]
  set rgmii_port_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_3 ]
  set sys_diff_clock [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock ]

  # Create ports
  set ref_clk_fsel [ create_bd_port -dir O -from 0 -to 0 ref_clk_fsel ]
  set ref_clk_n [ create_bd_port -dir I -from 0 -to 0 ref_clk_n ]
  set ref_clk_oe [ create_bd_port -dir O -from 0 -to 0 ref_clk_oe ]
  set ref_clk_p [ create_bd_port -dir I -from 0 -to 0 ref_clk_p ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list CONFIG.POLARITY {ACTIVE_HIGH}  ] $reset
  set reset_port_0 [ create_bd_port -dir O -type rst reset_port_0 ]
  set reset_port_1 [ create_bd_port -dir O -type rst reset_port_1 ]
  set reset_port_2 [ create_bd_port -dir O -type rst reset_port_2 ]
  set reset_port_3 [ create_bd_port -dir O -type rst reset_port_3 ]

  # Create instance: axi_ethernet_0, and set properties
  set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.2 axi_ethernet_0 ]
  set_property -dict [ list CONFIG.PHYRST_BOARD_INTERFACE {Custom} CONFIG.PHY_TYPE {RGMII} CONFIG.USE_BOARD_FLOW {true}  ] $axi_ethernet_0

  # Create instance: axi_ethernet_0_dma, and set properties
  set axi_ethernet_0_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_ethernet_0_dma ]
  set_property -dict [ list CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm_dre {1} CONFIG.c_sg_length_width {16} CONFIG.c_sg_use_stsapp_length {1}  ] $axi_ethernet_0_dma

  # Create instance: axi_ethernet_1, and set properties
  set axi_ethernet_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.2 axi_ethernet_1 ]
  set_property -dict [ list CONFIG.PHYRST_BOARD_INTERFACE {Custom} CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0} CONFIG.USE_BOARD_FLOW {true}  ] $axi_ethernet_1

  # Create instance: axi_ethernet_1_dma, and set properties
  set axi_ethernet_1_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_ethernet_1_dma ]
  set_property -dict [ list CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm_dre {1} CONFIG.c_sg_length_width {16} CONFIG.c_sg_use_stsapp_length {1}  ] $axi_ethernet_1_dma

  # Create instance: axi_ethernet_2, and set properties
  set axi_ethernet_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.2 axi_ethernet_2 ]
  set_property -dict [ list CONFIG.PHYRST_BOARD_INTERFACE {Custom} CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0} CONFIG.USE_BOARD_FLOW {true}  ] $axi_ethernet_2

  # Create instance: axi_ethernet_2_dma, and set properties
  set axi_ethernet_2_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_ethernet_2_dma ]
  set_property -dict [ list CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm_dre {1} CONFIG.c_sg_length_width {16} CONFIG.c_sg_use_stsapp_length {1}  ] $axi_ethernet_2_dma

  # Create instance: axi_ethernet_3, and set properties
  set axi_ethernet_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.2 axi_ethernet_3 ]
  set_property -dict [ list CONFIG.PHYRST_BOARD_INTERFACE {Custom} CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0} CONFIG.USE_BOARD_FLOW {true}  ] $axi_ethernet_3

  # Create instance: axi_ethernet_3_dma, and set properties
  set axi_ethernet_3_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_ethernet_3_dma ]
  set_property -dict [ list CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm_dre {1} CONFIG.c_sg_length_width {16} CONFIG.c_sg_use_stsapp_length {1}  ] $axi_ethernet_3_dma

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {14}  ] $axi_mem_intercon

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.4 microblaze_0 ]
  set_property -dict [ list CONFIG.C_CACHE_BYTE_SIZE {8192} CONFIG.C_DCACHE_BYTE_SIZE {8192} CONFIG.C_DEBUG_ENABLED {1} CONFIG.C_D_AXI {1} CONFIG.C_D_LMB {1} CONFIG.C_I_LMB {1} CONFIG.C_USE_DCACHE {1} CONFIG.C_USE_ICACHE {1}  ] $microblaze_0

  # Create instance: microblaze_0_axi_intc, and set properties
  set microblaze_0_axi_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 microblaze_0_axi_intc ]
  set_property -dict [ list CONFIG.C_HAS_FAST {1}  ] $microblaze_0_axi_intc

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {9}  ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: microblaze_0_xlconcat, and set properties
  set microblaze_0_xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 microblaze_0_xlconcat ]
  set_property -dict [ list CONFIG.NUM_PORTS {16}  ] $microblaze_0_xlconcat

  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:2.3 mig_7series_0 ]
  set_property -dict [ list CONFIG.BOARD_MIG_PARAM {ddr3_sdram_socket_j1} CONFIG.RESET_BOARD_INTERFACE {reset}  ] $mig_7series_0

  # Create instance: ref_clk_fsel, and set properties
  set ref_clk_fsel [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_fsel ]

  # Create instance: ref_clk_oe, and set properties
  set ref_clk_oe [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_oe ]

  # Create instance: rst_mig_7series_0_100M, and set properties
  set rst_mig_7series_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_mig_7series_0_100M ]
  set_property -dict [ list CONFIG.RESET_BOARD_INTERFACE {reset} CONFIG.USE_BOARD_FLOW {true}  ] $rst_mig_7series_0_100M

  # Create instance: rst_mig_7series_0_200M, and set properties
  set rst_mig_7series_0_200M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_mig_7series_0_200M ]

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.0 util_ds_buf_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXIS_CNTRL [get_bd_intf_pins axi_ethernet_0/s_axis_txc] [get_bd_intf_pins axi_ethernet_0_dma/M_AXIS_CNTRL]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXIS_MM2S [get_bd_intf_pins axi_ethernet_0/s_axis_txd] [get_bd_intf_pins axi_ethernet_0_dma/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXI_MM2S [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_MM2S] [get_bd_intf_pins axi_mem_intercon/S03_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXI_S2MM [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_S2MM] [get_bd_intf_pins axi_mem_intercon/S04_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXI_SG [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_SG] [get_bd_intf_pins axi_mem_intercon/S02_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxd [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_0_dma/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxs [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins axi_ethernet_0_dma/S_AXIS_STS]
  connect_bd_intf_net -intf_net axi_ethernet_0_mdio_io [get_bd_intf_ports mdio_io_port_0] [get_bd_intf_pins axi_ethernet_0/mdio_io]
  connect_bd_intf_net -intf_net axi_ethernet_0_rgmii [get_bd_intf_ports rgmii_port_0] [get_bd_intf_pins axi_ethernet_0/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_1_dma_M_AXIS_CNTRL [get_bd_intf_pins axi_ethernet_1/s_axis_txc] [get_bd_intf_pins axi_ethernet_1_dma/M_AXIS_CNTRL]
  connect_bd_intf_net -intf_net axi_ethernet_1_dma_M_AXIS_MM2S [get_bd_intf_pins axi_ethernet_1/s_axis_txd] [get_bd_intf_pins axi_ethernet_1_dma/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_ethernet_1_dma_M_AXI_MM2S [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_MM2S] [get_bd_intf_pins axi_mem_intercon/S06_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_1_dma_M_AXI_S2MM [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_S2MM] [get_bd_intf_pins axi_mem_intercon/S07_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_1_dma_M_AXI_SG [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_SG] [get_bd_intf_pins axi_mem_intercon/S05_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxd [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins axi_ethernet_1_dma/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxs [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins axi_ethernet_1_dma/S_AXIS_STS]
  connect_bd_intf_net -intf_net axi_ethernet_1_mdio_io [get_bd_intf_ports mdio_io_port_1] [get_bd_intf_pins axi_ethernet_1/mdio_io]
  connect_bd_intf_net -intf_net axi_ethernet_1_rgmii [get_bd_intf_ports rgmii_port_1] [get_bd_intf_pins axi_ethernet_1/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_2_dma_M_AXIS_CNTRL [get_bd_intf_pins axi_ethernet_2/s_axis_txc] [get_bd_intf_pins axi_ethernet_2_dma/M_AXIS_CNTRL]
  connect_bd_intf_net -intf_net axi_ethernet_2_dma_M_AXIS_MM2S [get_bd_intf_pins axi_ethernet_2/s_axis_txd] [get_bd_intf_pins axi_ethernet_2_dma/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_ethernet_2_dma_M_AXI_MM2S [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_MM2S] [get_bd_intf_pins axi_mem_intercon/S09_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_2_dma_M_AXI_S2MM [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_S2MM] [get_bd_intf_pins axi_mem_intercon/S10_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_2_dma_M_AXI_SG [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_SG] [get_bd_intf_pins axi_mem_intercon/S08_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_2_m_axis_rxd [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins axi_ethernet_2_dma/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axi_ethernet_2_m_axis_rxs [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins axi_ethernet_2_dma/S_AXIS_STS]
  connect_bd_intf_net -intf_net axi_ethernet_2_mdio_io [get_bd_intf_ports mdio_io_port_2] [get_bd_intf_pins axi_ethernet_2/mdio_io]
  connect_bd_intf_net -intf_net axi_ethernet_2_rgmii [get_bd_intf_ports rgmii_port_2] [get_bd_intf_pins axi_ethernet_2/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_3_dma_M_AXIS_CNTRL [get_bd_intf_pins axi_ethernet_3/s_axis_txc] [get_bd_intf_pins axi_ethernet_3_dma/M_AXIS_CNTRL]
  connect_bd_intf_net -intf_net axi_ethernet_3_dma_M_AXIS_MM2S [get_bd_intf_pins axi_ethernet_3/s_axis_txd] [get_bd_intf_pins axi_ethernet_3_dma/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_ethernet_3_dma_M_AXI_MM2S [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_MM2S] [get_bd_intf_pins axi_mem_intercon/S12_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_3_dma_M_AXI_S2MM [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_S2MM] [get_bd_intf_pins axi_mem_intercon/S13_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_3_dma_M_AXI_SG [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_SG] [get_bd_intf_pins axi_mem_intercon/S11_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_3_m_axis_rxd [get_bd_intf_pins axi_ethernet_3/m_axis_rxd] [get_bd_intf_pins axi_ethernet_3_dma/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axi_ethernet_3_m_axis_rxs [get_bd_intf_pins axi_ethernet_3/m_axis_rxs] [get_bd_intf_pins axi_ethernet_3_dma/S_AXIS_STS]
  connect_bd_intf_net -intf_net axi_ethernet_3_mdio_io [get_bd_intf_ports mdio_io_port_3] [get_bd_intf_pins axi_ethernet_3/mdio_io]
  connect_bd_intf_net -intf_net axi_ethernet_3_rgmii [get_bd_intf_ports rgmii_port_3] [get_bd_intf_pins axi_ethernet_3/rgmii]
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DC [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins microblaze_0/M_AXI_DC]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_IC [get_bd_intf_pins axi_mem_intercon/S01_AXI] [get_bd_intf_pins microblaze_0/M_AXI_IC]
  connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins axi_ethernet_0/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins axi_ethernet_1/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins axi_ethernet_2/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins axi_ethernet_3/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins axi_ethernet_0_dma/S_AXI_LITE] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M06_AXI [get_bd_intf_pins axi_ethernet_1_dma/S_AXI_LITE] [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins axi_ethernet_2_dma/S_AXI_LITE] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M08_AXI [get_bd_intf_pins axi_ethernet_3_dma/S_AXI_LITE] [get_bd_intf_pins microblaze_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net microblaze_0_intc_axi [get_bd_intf_pins microblaze_0_axi_intc/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_interrupt [get_bd_intf_pins microblaze_0/INTERRUPT] [get_bd_intf_pins microblaze_0_axi_intc/interrupt]
  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_ports ddr3_sdram_socket_j1] [get_bd_intf_pins mig_7series_0/DDR3]
  connect_bd_intf_net -intf_net sys_diff_clock_1 [get_bd_intf_ports sys_diff_clock] [get_bd_intf_pins mig_7series_0/SYS_CLK]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_1 [get_bd_ports ref_clk_n] [get_bd_pins util_ds_buf_0/IBUF_DS_N]
  connect_bd_net -net IBUF_DS_P_1 [get_bd_ports ref_clk_p] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
  connect_bd_net -net axi_ethernet_0_dma_mm2s_cntrl_reset_out_n [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins axi_ethernet_0_dma/mm2s_cntrl_reset_out_n]
  connect_bd_net -net axi_ethernet_0_dma_mm2s_introut [get_bd_pins axi_ethernet_0_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In0]
  connect_bd_net -net axi_ethernet_0_dma_mm2s_prmry_reset_out_n [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins axi_ethernet_0_dma/mm2s_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_0_dma_s2mm_introut [get_bd_pins axi_ethernet_0_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In1]
  connect_bd_net -net axi_ethernet_0_dma_s2mm_prmry_reset_out_n [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins axi_ethernet_0_dma/s2mm_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_0_dma_s2mm_sts_reset_out_n [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins axi_ethernet_0_dma/s2mm_sts_reset_out_n]
  connect_bd_net -net axi_ethernet_0_interrupt [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In9]
  connect_bd_net -net axi_ethernet_0_mac_irq [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins microblaze_0_xlconcat/In8]
  connect_bd_net -net axi_ethernet_0_phy_rst_n [get_bd_ports reset_port_0] [get_bd_pins axi_ethernet_0/phy_rst_n]
  connect_bd_net -net axi_ethernet_1_dma_mm2s_cntrl_reset_out_n [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins axi_ethernet_1_dma/mm2s_cntrl_reset_out_n]
  connect_bd_net -net axi_ethernet_1_dma_mm2s_introut [get_bd_pins axi_ethernet_1_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In2]
  connect_bd_net -net axi_ethernet_1_dma_mm2s_prmry_reset_out_n [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins axi_ethernet_1_dma/mm2s_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_1_dma_s2mm_introut [get_bd_pins axi_ethernet_1_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In3]
  connect_bd_net -net axi_ethernet_1_dma_s2mm_prmry_reset_out_n [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins axi_ethernet_1_dma/s2mm_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_1_dma_s2mm_sts_reset_out_n [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins axi_ethernet_1_dma/s2mm_sts_reset_out_n]
  connect_bd_net -net axi_ethernet_1_interrupt [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins microblaze_0_xlconcat/In11]
  connect_bd_net -net axi_ethernet_1_mac_irq [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins microblaze_0_xlconcat/In10]
  connect_bd_net -net axi_ethernet_1_phy_rst_n [get_bd_ports reset_port_1] [get_bd_pins axi_ethernet_1/phy_rst_n]
  connect_bd_net -net axi_ethernet_2_dma_mm2s_cntrl_reset_out_n [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins axi_ethernet_2_dma/mm2s_cntrl_reset_out_n]
  connect_bd_net -net axi_ethernet_2_dma_mm2s_introut [get_bd_pins axi_ethernet_2_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In4]
  connect_bd_net -net axi_ethernet_2_dma_mm2s_prmry_reset_out_n [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins axi_ethernet_2_dma/mm2s_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_2_dma_s2mm_introut [get_bd_pins axi_ethernet_2_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In5]
  connect_bd_net -net axi_ethernet_2_dma_s2mm_prmry_reset_out_n [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins axi_ethernet_2_dma/s2mm_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_2_dma_s2mm_sts_reset_out_n [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins axi_ethernet_2_dma/s2mm_sts_reset_out_n]
  connect_bd_net -net axi_ethernet_2_interrupt [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins microblaze_0_xlconcat/In13]
  connect_bd_net -net axi_ethernet_2_mac_irq [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins microblaze_0_xlconcat/In12]
  connect_bd_net -net axi_ethernet_2_phy_rst_n [get_bd_ports reset_port_2] [get_bd_pins axi_ethernet_2/phy_rst_n]
  connect_bd_net -net axi_ethernet_3_dma_mm2s_cntrl_reset_out_n [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins axi_ethernet_3_dma/mm2s_cntrl_reset_out_n]
  connect_bd_net -net axi_ethernet_3_dma_mm2s_introut [get_bd_pins axi_ethernet_3_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In6]
  connect_bd_net -net axi_ethernet_3_dma_mm2s_prmry_reset_out_n [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins axi_ethernet_3_dma/mm2s_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_3_dma_s2mm_introut [get_bd_pins axi_ethernet_3_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In7]
  connect_bd_net -net axi_ethernet_3_dma_s2mm_prmry_reset_out_n [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins axi_ethernet_3_dma/s2mm_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_3_dma_s2mm_sts_reset_out_n [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins axi_ethernet_3_dma/s2mm_sts_reset_out_n]
  connect_bd_net -net axi_ethernet_3_interrupt [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins microblaze_0_xlconcat/In15]
  connect_bd_net -net axi_ethernet_3_mac_irq [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins microblaze_0_xlconcat/In14]
  connect_bd_net -net axi_ethernet_3_phy_rst_n [get_bd_ports reset_port_3] [get_bd_pins axi_ethernet_3/phy_rst_n]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_mig_7series_0_100M/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins axi_ethernet_0/s_axi_lite_clk] [get_bd_pins axi_ethernet_0_dma/m_axi_mm2s_aclk] [get_bd_pins axi_ethernet_0_dma/m_axi_s2mm_aclk] [get_bd_pins axi_ethernet_0_dma/m_axi_sg_aclk] [get_bd_pins axi_ethernet_0_dma/s_axi_lite_aclk] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins axi_ethernet_1/s_axi_lite_clk] [get_bd_pins axi_ethernet_1_dma/m_axi_mm2s_aclk] [get_bd_pins axi_ethernet_1_dma/m_axi_s2mm_aclk] [get_bd_pins axi_ethernet_1_dma/m_axi_sg_aclk] [get_bd_pins axi_ethernet_1_dma/s_axi_lite_aclk] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins axi_ethernet_2/s_axi_lite_clk] [get_bd_pins axi_ethernet_2_dma/m_axi_mm2s_aclk] [get_bd_pins axi_ethernet_2_dma/m_axi_s2mm_aclk] [get_bd_pins axi_ethernet_2_dma/m_axi_sg_aclk] [get_bd_pins axi_ethernet_2_dma/s_axi_lite_aclk] [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins axi_ethernet_3/s_axi_lite_clk] [get_bd_pins axi_ethernet_3_dma/m_axi_mm2s_aclk] [get_bd_pins axi_ethernet_3_dma/m_axi_s2mm_aclk] [get_bd_pins axi_ethernet_3_dma/m_axi_sg_aclk] [get_bd_pins axi_ethernet_3_dma/s_axi_lite_aclk] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins axi_mem_intercon/S02_ACLK] [get_bd_pins axi_mem_intercon/S03_ACLK] [get_bd_pins axi_mem_intercon/S04_ACLK] [get_bd_pins axi_mem_intercon/S05_ACLK] [get_bd_pins axi_mem_intercon/S06_ACLK] [get_bd_pins axi_mem_intercon/S07_ACLK] [get_bd_pins axi_mem_intercon/S08_ACLK] [get_bd_pins axi_mem_intercon/S09_ACLK] [get_bd_pins axi_mem_intercon/S10_ACLK] [get_bd_pins axi_mem_intercon/S11_ACLK] [get_bd_pins axi_mem_intercon/S12_ACLK] [get_bd_pins axi_mem_intercon/S13_ACLK] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_intc/processor_clk] [get_bd_pins microblaze_0_axi_intc/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/M08_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins mig_7series_0/ui_addn_clk_0] [get_bd_pins rst_mig_7series_0_100M/slowest_sync_clk]
  connect_bd_net -net microblaze_0_intr [get_bd_pins microblaze_0_axi_intc/intr] [get_bd_pins microblaze_0_xlconcat/dout]
  connect_bd_net -net mig_7series_0_mmcm_locked [get_bd_pins mig_7series_0/mmcm_locked] [get_bd_pins rst_mig_7series_0_100M/dcm_locked] [get_bd_pins rst_mig_7series_0_200M/dcm_locked]
  connect_bd_net -net mig_7series_0_ui_clk [get_bd_pins axi_ethernet_0/ref_clk] [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins mig_7series_0/ui_clk] [get_bd_pins rst_mig_7series_0_200M/slowest_sync_clk]
  connect_bd_net -net mig_7series_0_ui_clk_sync_rst [get_bd_pins mig_7series_0/ui_clk_sync_rst] [get_bd_pins rst_mig_7series_0_200M/ext_reset_in]
  connect_bd_net -net ref_clk_fsel_dout [get_bd_ports ref_clk_fsel] [get_bd_pins ref_clk_fsel/dout]
  connect_bd_net -net ref_clk_oe_dout [get_bd_ports ref_clk_oe] [get_bd_pins ref_clk_oe/dout]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins mig_7series_0/sys_rst] [get_bd_pins rst_mig_7series_0_100M/ext_reset_in]
  connect_bd_net -net rst_mig_7series_0_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/LMB_Rst] [get_bd_pins rst_mig_7series_0_100M/bus_struct_reset]
  connect_bd_net -net rst_mig_7series_0_100M_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins rst_mig_7series_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_mig_7series_0_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins microblaze_0_axi_intc/processor_rst] [get_bd_pins rst_mig_7series_0_100M/mb_reset]
  connect_bd_net -net rst_mig_7series_0_100M_peripheral_aresetn [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] [get_bd_pins axi_ethernet_0_dma/axi_resetn] [get_bd_pins axi_ethernet_1/s_axi_lite_resetn] [get_bd_pins axi_ethernet_1_dma/axi_resetn] [get_bd_pins axi_ethernet_2/s_axi_lite_resetn] [get_bd_pins axi_ethernet_2_dma/axi_resetn] [get_bd_pins axi_ethernet_3/s_axi_lite_resetn] [get_bd_pins axi_ethernet_3_dma/axi_resetn] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins axi_mem_intercon/S02_ARESETN] [get_bd_pins axi_mem_intercon/S03_ARESETN] [get_bd_pins axi_mem_intercon/S04_ARESETN] [get_bd_pins axi_mem_intercon/S05_ARESETN] [get_bd_pins axi_mem_intercon/S06_ARESETN] [get_bd_pins axi_mem_intercon/S07_ARESETN] [get_bd_pins axi_mem_intercon/S08_ARESETN] [get_bd_pins axi_mem_intercon/S09_ARESETN] [get_bd_pins axi_mem_intercon/S10_ARESETN] [get_bd_pins axi_mem_intercon/S11_ARESETN] [get_bd_pins axi_mem_intercon/S12_ARESETN] [get_bd_pins axi_mem_intercon/S13_ARESETN] [get_bd_pins microblaze_0_axi_intc/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/M08_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins rst_mig_7series_0_100M/peripheral_aresetn]
  connect_bd_net -net rst_mig_7series_0_200M_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins rst_mig_7series_0_200M/interconnect_aresetn]
  connect_bd_net -net rst_mig_7series_0_200M_peripheral_aresetn [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins mig_7series_0/aresetn] [get_bd_pins rst_mig_7series_0_200M/peripheral_aresetn]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT [get_bd_pins axi_ethernet_0/gtx_clk] [get_bd_pins axi_ethernet_1/gtx_clk] [get_bd_pins axi_ethernet_2/gtx_clk] [get_bd_pins axi_ethernet_3/gtx_clk] [get_bd_pins util_ds_buf_0/IBUF_OUT]

  # Create address segments
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_0_dma/Data_SG] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_0_dma/Data_MM2S] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_0_dma/Data_S2MM] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_1_dma/Data_SG] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_1_dma/Data_MM2S] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_1_dma/Data_S2MM] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_2_dma/Data_SG] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_2_dma/Data_MM2S] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_2_dma/Data_S2MM] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_3_dma/Data_SG] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_3_dma/Data_MM2S] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces axi_ethernet_3_dma/Data_S2MM] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x40000 -offset 0x40C00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg] SEG_axi_ethernet_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41E00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernet_0_dma/S_AXI_LITE/Reg] SEG_axi_ethernet_0_dma_Reg
  create_bd_addr_seg -range 0x40000 -offset 0x40C40000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernet_1/s_axi/Reg] SEG_axi_ethernet_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41E10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernet_1_dma/S_AXI_LITE/Reg] SEG_axi_ethernet_1_dma_Reg
  create_bd_addr_seg -range 0x40000 -offset 0x40C80000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernet_2/s_axi/Reg] SEG_axi_ethernet_2_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41E20000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernet_2_dma/S_AXI_LITE/Reg] SEG_axi_ethernet_2_dma_Reg
  create_bd_addr_seg -range 0x40000 -offset 0x40CC0000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernet_3/s_axi/Reg] SEG_axi_ethernet_3_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41E30000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernet_3_dma/S_AXI_LITE/Reg] SEG_axi_ethernet_3_dma_Reg
  create_bd_addr_seg -range 0x2000 -offset 0x0 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x2000 -offset 0x0 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_axi_intc/s_axi/Reg] SEG_microblaze_0_axi_intc_Reg
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


