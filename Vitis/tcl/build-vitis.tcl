#!/usr/bin/tclsh

# Description
# -----------
# This Tcl script will create Vitis workspace and add a software application for the specified
# target design. If a target design is not specified, a software application will be added for 
# each of the exported hardware designs in the ../Vivado directory.

# Set the Vivado directories containing the Vivado projects
set vivado_dirs_rel [list "../Vivado"]
set vivado_dirs {}
foreach d $vivado_dirs_rel {
  set d_abs [file join [pwd] $d]
  append vivado_dirs [file normalize $d_abs] " "
}

# Set the application postfix
# Applications will be named using the app_postfix appended to the board name
set app_postfix "_echo_server"

# Specify the postfix on the Vivado projects (if one is used)
set vivado_postfix ""

# Set the app template used to create the application
set support_app "lwip_echo_server"
set template_app "lwIP Echo Server"

# Microblaze designs: Generate combined .bit and .elf file
set mb_combine_bit_elf 0

# Possible targets (board name in lower case for the board.h file)
dict set target_dict ac701 { ac701 }
dict set target_dict kc705_hpc { kc705 }
dict set target_dict kc705_lpc { kc705 }
dict set target_dict kc705_lpc_hpc { kc705 }
dict set target_dict kcu105_dual { kcu105 }
dict set target_dict kcu105_hpc { kcu105 }
dict set target_dict kcu105_lpc { kcu105 }
dict set target_dict pz_7015 { pz }
dict set target_dict pz_7020 { pz }
dict set target_dict pz_7030 { pz }
dict set target_dict uzev { uzev }
dict set target_dict vc707_hpc1 { vc707 }
dict set target_dict vc707_hpc2 { vc707 }
dict set target_dict vc707_hpc2_hpc1 { vc707 }
dict set target_dict vc709 { vc709 }
dict set target_dict vcu108_hpc0 { vcu108 }
dict set target_dict vcu108_hpc1 { vcu108 }
dict set target_dict vcu118 { vcu118 }
dict set target_dict zc702_lpc1 { zc702 }
dict set target_dict zc702_lpc2 { zc702 }
dict set target_dict zc702_lpc2_lpc1 { zc702 }
dict set target_dict zc706_lpc { zc706 }
dict set target_dict zcu102_hpc0 { zcu102 }
dict set target_dict zcu102_hpc1 { zcu102 }
dict set target_dict zedboard { zedboard }

# Target can be specified by creating the target variable before sourcing, or in the arguments
if { $argc >= 1 } {
  set target [lindex $argv 0]
  puts "Target for the build: $target"
} elseif { [info exists target] && [dict exists $target_dict $target] } {
  puts "Target for the build: $target"
} else {
  puts "No target specified, or invalid target."
  set target ""
}

# ----------------------------------------------------------------------------------------------
# Custom modifications functions
# ----------------------------------------------------------------------------------------------
# Use these functions to make custom changes to the platform or standard application template 
# such as modifying files or copying sources into the platform/application.
# These functions are called after creating the platform/application and before build.

proc custom_platform_mods {platform_name} {
  # No platform mods required
}

proc custom_app_mods {platform_name app_name} {
  # No custom mods needed
}

# Call the workspace builder script
source tcl/workspace.tcl

