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
create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series mig_7series_0
apply_bd_automation -rule xilinx.com:bd_rule:mig_7series -config {Board_Interface "ddr3_sdram" }  [get_bd_cells mig_7series_0]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset ( FPGA Reset ) " }  [get_bd_pins mig_7series_0/sys_rst]

# Add the Microblaze
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze microblaze_0
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config {local_mem "64KB" ecc "None" cache "64KB" debug_module "Debug Only" axi_periph "Enabled" axi_intc "1" clk "/mig_7series_0/ui_clk (100 MHz)" }  [get_bd_cells microblaze_0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Cached)" Clk "Auto" }  [get_bd_intf_pins mig_7series_0/S_AXI]

# Configure the interrupt concat
set_property -dict [list CONFIG.NUM_PORTS {17}] [get_bd_cells microblaze_0_xlconcat]

# Add the AXI Ethernet IPs
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_2
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_3

# Configure all ports for full checksum hardware offload
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_3]

# Configure ports 1,2 and 3 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_3]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_1]

# Apply block automation for all AXI Ethernet: RGMII with DMA
apply_bd_automation -rule xilinx.com:bd_rule:axi_ethernet -config {PHY_TYPE "RGMII" FIFO_DMA "DMA" }  [get_bd_cells axi_ethernet_0]
apply_bd_automation -rule xilinx.com:bd_rule:axi_ethernet -config {PHY_TYPE "RGMII" FIFO_DMA "DMA" }  [get_bd_cells axi_ethernet_1]
apply_bd_automation -rule xilinx.com:bd_rule:axi_ethernet -config {PHY_TYPE "RGMII" FIFO_DMA "DMA" }  [get_bd_cells axi_ethernet_2]
apply_bd_automation -rule xilinx.com:bd_rule:axi_ethernet -config {PHY_TYPE "RGMII" FIFO_DMA "DMA" }  [get_bd_cells axi_ethernet_3]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_SG]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_SG]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_SG]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_SG]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_S2MM]

# Make AXI Ethernet ports external: MDIO, RGMII and RESET
# MDIO
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/mdio] [get_bd_intf_ports mdio_io_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/mdio] [get_bd_intf_ports mdio_io_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/mdio] [get_bd_intf_ports mdio_io_port_2]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/mdio] [get_bd_intf_ports mdio_io_port_3]
# RGMII
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/rgmii] [get_bd_intf_ports rgmii_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/rgmii] [get_bd_intf_ports rgmii_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/rgmii] [get_bd_intf_ports rgmii_port_2]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/rgmii] [get_bd_intf_ports rgmii_port_3]
# RESET
create_bd_port -dir O -type rst reset_port_0
connect_bd_net [get_bd_pins /axi_ethernet_0/phy_rst_n] [get_bd_ports reset_port_0]
create_bd_port -dir O -type rst reset_port_1
connect_bd_net [get_bd_pins /axi_ethernet_1/phy_rst_n] [get_bd_ports reset_port_1]
create_bd_port -dir O -type rst reset_port_2
connect_bd_net [get_bd_pins /axi_ethernet_2/phy_rst_n] [get_bd_ports reset_port_2]
create_bd_port -dir O -type rst reset_port_3
connect_bd_net [get_bd_pins /axi_ethernet_3/phy_rst_n] [get_bd_ports reset_port_3]


# Connect interrupts

connect_bd_net [get_bd_pins axi_ethernet_0_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In0]
connect_bd_net [get_bd_pins axi_ethernet_0_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In1]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In2]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In3]
connect_bd_net [get_bd_pins axi_ethernet_2_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In4]
connect_bd_net [get_bd_pins axi_ethernet_2_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In5]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In6]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In7]

connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins microblaze_0_xlconcat/In8]
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In9]
connect_bd_net [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins microblaze_0_xlconcat/In10]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins microblaze_0_xlconcat/In11]
connect_bd_net [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins microblaze_0_xlconcat/In12]
connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins microblaze_0_xlconcat/In13]
connect_bd_net [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins microblaze_0_xlconcat/In14]
connect_bd_net [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins microblaze_0_xlconcat/In15]

# Connect AXI Ethernet clocks

#connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_1/gtx_clk]
#connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_1/gtx_clk90]
#connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_2/gtx_clk]
#connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_2/gtx_clk90]
#connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_3/gtx_clk]
#connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_3/gtx_clk90]

# Delete the clock wizard that is automatically generated by Vivado 2015.2

delete_bd_objs [get_bd_nets axi_ethernet_0_refclk_clk_out2] [get_bd_nets axi_ethernet_0_refclk_clk_out1] [get_bd_cells axi_ethernet_0_refclk]

# Connect 200MHz AXI Ethernet ref_clk

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0
connect_bd_net -net [get_bd_nets microblaze_0_Clk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins mig_7series_0/ui_clk]
connect_bd_net [get_bd_pins clk_wiz_0/reset] [get_bd_pins rst_mig_7series_0_100M/peripheral_reset]
connect_bd_net [get_bd_pins axi_ethernet_0/ref_clk] [get_bd_pins clk_wiz_0/clk_out1]
set_property -dict [list CONFIG.PRIM_SOURCE {No_buffer} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200} CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000} CONFIG.CLKOUT1_JITTER {114.829}] [get_bd_cells clk_wiz_0]

# Create differential IO buffer for the Ethernet FMC 125MHz clock

create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_0/gtx_clk]
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_p
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_P] [get_bd_ports ref_clk_p]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_p]
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_n
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_N] [get_bd_ports ref_clk_n]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_n]

# Create Ethernet FMC reference clock output enable and frequency select

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_oe
create_bd_port -dir O -from 0 -to 0 ref_clk_oe
connect_bd_net [get_bd_pins /ref_clk_oe/dout] [get_bd_ports ref_clk_oe]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_fsel
create_bd_port -dir O -from 0 -to 0 ref_clk_fsel
connect_bd_net [get_bd_pins /ref_clk_fsel/dout] [get_bd_ports ref_clk_fsel]

# Add UART for the Echo server example application

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550 axi_uart16550_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_uart16550_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "rs232_uart ( UART ) " }  [get_bd_intf_pins axi_uart16550_0/UART]

# Add Timer for the Echo server example application

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_timer_0/S_AXI]

connect_bd_net [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In16]


# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
