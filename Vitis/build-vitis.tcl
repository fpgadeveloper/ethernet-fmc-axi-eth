#!/usr/bin/tclsh

# Description
# -----------
# This Tcl script will create Vitis workspace with software applications for each of the
# exported hardware designs in the ../Vivado directory.

# lwIP modifications
# ------------------
# These applications use a modified version of the lwIP library contained in the
# ../EmbeddedSw directory. The original lwIP library can be found here:
# C:\Xilinx\Vitis\<version>\data\embeddedsw\ThirdParty\sw_services
# This script will copy the original lwIP library sources into the ../EmbeddedSw directory,
# except for the modified files already contained in that directory. The ../EmbeddedSw
# directory then serves as a remote SDK repository for the software applications.

# Echo server applications
# ------------------------
# After copying the original lwIP library files, this script will then look into the ../Vivado
# directory and search for exported hardware designs (.hdf files within Vivado projects).
# For each exported hardware design, the script will generate the echo server software application.

# Set the Vivado directory containing the Vivado projects
set vivado_dir [file join [pwd] "../Vivado"]
set vivado_dir [file normalize $vivado_dir]
# Set the application postfix
set app_postfix "_echo_server"

# Returns true if str contains substr
proc str_contains {str substr} {
  if {[string first $substr $str] == -1} {
    return 0
  } else {
    return 1
  }
}

# Recursive copy function
# Note: Does not overwrite existing files, thus our modified files are untouched.
proc copy-r {{dir .} target_dir} {
  foreach i [lsort [glob -nocomplain -dir $dir *]] {
    # Get the name of the file or directory
    set name [lindex [split $i /] end]
    if {[file type $i] eq {directory}} {
      # If doesn't exist in target, then create it
      set target_subdir ${target_dir}/$name
      if {[file exists $target_subdir] == 0} {
        file mkdir $target_subdir
      }
      # Copy all files contained in this subdirectory
      eval [copy-r $i $target_subdir]
    } else {
      # Copy the file if it doesn't already exist
      if {[file exists ${target_dir}/$name] == 0} {
        file copy $i $target_dir
      }
    }
  }
} ;# RS

# Fill in the local libraries with original sources without overwriting existing code
proc fill_local_libraries {} {
  # Xilinx Vitis install directory
  set vitis_dir $::env(XILINX_VITIS)
  # For each of the custom lwIP versions in our local repo
  foreach lwip_dir [glob -type d "../EmbeddedSw/ThirdParty/sw_services/*"] {
    # Work out the original version library directory name by removing the appended "9"
    set lib_name [string range [lindex [split $lwip_dir /] end] 0 end-1]
    set orig_dir "$vitis_dir/data/embeddedsw/ThirdParty/sw_services/$lib_name"
    puts "Copying files from $orig_dir to $lwip_dir"
    # Copy the original files to local repo, without overwriting existing code
    copy-r $orig_dir $lwip_dir
  }
  # For each of the custom axi_ethernet driver versions in our local repo
  foreach driver_dir [glob -type d "../EmbeddedSw/XilinxProcessorIPLib/drivers/*"] {
    # Work out the original version library directory name by removing the appended "9"
    set lib_name [string range [lindex [split $driver_dir /] end] 0 end-1]
    set orig_dir "$vitis_dir/data/embeddedsw/XilinxProcessorIPLib/drivers/$lib_name"
    puts "Copying files from $orig_dir to $driver_dir"
    # Copy the original files to local repo, without overwriting existing code
    copy-r $orig_dir $driver_dir
  }
}

# Get the first processor name from a hardware design
# We use the "getperipherals" command to get the name of the processor that
# in the design. Below is an example of the output of "getperipherals":
# ================================================================================
# 
#               IP INSTANCE   VERSION                   TYPE           IP TYPE
# ================================================================================
# 
#            axi_ethernet_0       7.0           axi_ethernet        PERIPHERAL
#       axi_ethernet_0_fifo       4.1          axi_fifo_mm_s        PERIPHERAL
#           gmii_to_rgmii_0       4.0          gmii_to_rgmii        PERIPHERAL
#      processing_system7_0       5.5     processing_system7
#          ps7_0_axi_periph       2.1       axi_interconnect               BUS
#              ref_clk_fsel       1.1             xlconstant        PERIPHERAL
#                ref_clk_oe       1.1             xlconstant        PERIPHERAL
#                 ps7_pmu_0    1.00.a                ps7_pmu        PERIPHERAL
#                ps7_qspi_0    1.00.a               ps7_qspi        PERIPHERAL
#         ps7_qspi_linear_0    1.00.a        ps7_qspi_linear      MEMORY_CNTLR
#    ps7_axi_interconnect_0    1.00.a   ps7_axi_interconnect               BUS
#            ps7_cortexa9_0       5.2           ps7_cortexa9         PROCESSOR
#            ps7_cortexa9_1       5.2           ps7_cortexa9         PROCESSOR
#                 ps7_ddr_0    1.00.a                ps7_ddr      MEMORY_CNTLR
#            ps7_ethernet_0    1.00.a           ps7_ethernet        PERIPHERAL
#            ps7_ethernet_1    1.00.a           ps7_ethernet        PERIPHERAL
#                 ps7_usb_0    1.00.a                ps7_usb        PERIPHERAL
#                  ps7_sd_0    1.00.a               ps7_sdio        PERIPHERAL
#                  ps7_sd_1    1.00.a               ps7_sdio        PERIPHERAL
proc get_processor_name {hw_project_name} {
  set periphs [getperipherals $hw_project_name]
  # For each line of the peripherals table
  foreach line [split $periphs "\n"] {
    set values [regexp -all -inline {\S+} $line]
    # If the last column is "PROCESSOR", then get the "IP INSTANCE" name (1st col)
    if {[lindex $values end] == "PROCESSOR"} {
      return [lindex $values 0]
    }
  }
  return ""
}

# Returns list of Vivado projects in the given directory
proc get_vivado_projects {vivado_dir} {
  # Create the empty list
  set vivado_proj_list {}
  # Make a list of all subdirectories in Vivado directory
  foreach {vivado_proj_dir} [glob -type d "${vivado_dir}/*"] {
    # Get the vivado project name from the project directory name
    set vivado_proj [lindex [split $vivado_proj_dir /] end]
    # Ignore directories returned by glob that don't contain an underscore
    if { ([string first "_" $vivado_proj] == -1) } {
      continue
    }
    # Add the Vivado project to the list
    lappend vivado_proj_list $vivado_proj
  }
  return $vivado_proj_list
}

# Creates Vitis workspace for a project
proc create_vitis_ws {} {
  global vivado_dir
  global app_postfix
  # First make sure there is at least one exported Vivado project
  set exported_projects 0
  # Get list of Vivado projects
  set vivado_proj_list [get_vivado_projects $vivado_dir]
  # Check each Vivado project for export files
  foreach {vivado_folder} $vivado_proj_list {
    # If the hardware has been exported for Vitis
    if {[file exists "$vivado_dir/$vivado_folder/${vivado_folder}_wrapper.xsa"] == 1} {
      set exported_projects [expr {$exported_projects+1}]
    }
  }
  
  # If no projects then exit
  if {$exported_projects == 0} {
    puts "### There are no exported Vivado projects in the $vivado_dir directory ###"
    puts "You must build and export a Vivado project before building the Vitis workspace."
    exit
  }

  puts "There were $exported_projects exported project(s) found in the $vivado_dir directory."
  puts "Creating Vitis workspace."
  
  # Create "boot" directory if it doesn't already exist
  if {[file exists "./boot"] == 0} {
    file mkdir "./boot"
  }
  
  # Set the workspace directory
  set vitis_dir [pwd]
  setws $vitis_dir
  
  # Add local Vitis repo
  # Now when we create an application, SDK will automatically use the lwIP library from the local repo
  puts "Adding Vitis repo to the workspace."
  set embsw [file normalize "${vitis_dir}/../EmbeddedSw"]
  repo -set [list $embsw]

  # Add each Vivado project to Vitis workspace
  foreach {vivado_folder} $vivado_proj_list {
    # Get the name of the board
    set board_name [string map {"_axieth" ""} $vivado_folder]
    # Path of the XSA file
    set xsa_file "$vivado_dir/$vivado_folder/${vivado_folder}_wrapper.xsa"
    set xsa_filename_only [lindex [split $xsa_file /] end]
    set hw_project_name [lindex [split $xsa_filename_only .] 0]
    # Make sure that the Vivado project has been exported
    if {[file exists $xsa_file] == 0} {
      puts "Vivado project $vivado_folder has not been exported."
      continue
    }
    # Create the application name
    set app_name "${board_name}$app_postfix"
    # If the application has already been created, then skip
    if {[file exists "$app_name"] == 1} {
      puts "Application already exists for Vivado project $vivado_folder."
      continue
    }
    # Create the platform for this Vivado project
    puts "Creating Platform for $vivado_folder."
    platform create -name ${hw_project_name} -hw ${xsa_file}
    platform write
    set proc_instance [get_processor_name ${xsa_file}]
    # Microblaze and Zynq ARM are 32-bit, ZynqMP ARM are 64-bit processors
    if {[str_contains $proc_instance "psu_cortex"]} {
      set arch_bit "64-bit"
    } else {
      set arch_bit "32-bit"
    }
    # Create a standalone domain
    domain create -name {standalone_domain} \
      -display-name "standalone on $proc_instance" \
      -os {standalone} \
      -proc $proc_instance \
      -runtime {cpp} \
      -arch $arch_bit \
      -support-app {lwip_echo_server}
    platform write
    platform active ${hw_project_name}
    # Enable the FSBL for Zynq
    if {[str_contains $proc_instance "ps7_cortex"]} {
      domain active {zynq_fsbl}
    # Enable the FSBL for ZynqMP
    } elseif {[str_contains $proc_instance "psu_cortex"]} {
      domain active {zynqmp_fsbl}
    }
    domain active {standalone_domain}
    platform generate
    # Generate the example application
    puts "Creating application $app_name."
    app create -name $app_name \
      -template {lwIP Echo Server} \
      -platform ${hw_project_name} \
      -domain {standalone_domain}
    # Build the application
    puts "Building application $app_name."
    app build -name $app_name
    puts "Building system ${app_name}_system."
    sysproj build -name ${app_name}_system
    
    # Create or copy the boot file
    # Make sure the application has been compiled
    if {[file exists "./${app_name}/Debug/${app_name}.elf"] == 0} {
      puts "Application ${app_name} FAILED to compile."
      continue
    }
    
    # If all required files exist, then generate boot files
    # Create directory for the boot file if it doesn't already exist
    if {[file exists "./boot/$board_name"] == 0} {
      file mkdir "./boot/$board_name"
    }
	
    # For Microblaze designs
    if {[str_contains $proc_instance "microblaze"]} {
      puts "Copying bitstream and elf for $board_name project."
      # Copy the bitstream and elf file to the boot folder
      file copy "../Vivado/${vivado_folder}/${vivado_folder}.runs/impl_1/${vivado_folder}_wrapper.bit" "./boot/${board_name}"
      file copy "./${app_name}/Debug/${app_name}.elf" "./boot/${board_name}"
    # For Zynq and Zynq MP designs
    } else {
      puts "Copying the BOOT.BIN file to the ./boot/${board_name} directory."
      # Copy the already generated BOOT.bin file
      set bootbin_file "./${app_name}_system/Debug/sd_card/BOOT.BIN"
      if {[file exists $bootbin_file] == 1} {
        file copy -force $bootbin_file "./boot/${board_name}"
      } else {
        puts "No BOOT.bin file for ${app_name}."
      }
    }
  }
}
  
# Checks all applications
proc check_apps {} {
  global app_postfix
  # Set the workspace directory
  setws [pwd]
  puts "Checking build status of all applications:"
  # Get list of applications
  foreach {app_dir} [glob -type d "./*$app_postfix"] {
    # Get the app name
    set app_name [lindex [split $app_dir /] end]
    if {[file exists "$app_dir/Debug/${app_name}.elf"] == 1} {
      puts "  ${app_name} was built successfully"
    } else {
      puts "  ERROR: ${app_name} failed to build"
    }
  }
}
  
# Copy original lwIP library sources into the local Vitis repo
puts "Building the local Vitis repo from original sources"
fill_local_libraries

# Create the Vitis workspace
puts "Creating the Vitis workspace"
create_vitis_ws
check_apps

exit
