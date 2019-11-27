SDK Project files
=================

### Depreciation note

Starting with version 2019.2 of the Xilinx tools, the SDK was made part of the Vitis
unified software platform. We are currently migrating our standalone applications
to the Vitis software. Until the migration is completed, the sources in this repository
can still be used with the Xilinx SDK version 2019.1 if so desired. In other words,
the Vivado projects can be built with Vivado 2019.2, then exported to SDK 2019.1. The
export process must be done by Tcl script, because the Vivado 2019.2 GUI Hardware 
Export option generates a .XSA file, while the SDK expects a .HDF file.

To export a Vivado 2019.2 project for SDK 2019.1, first open the project in Vivado
and generate the bitstream. Once the bitstream generation is complete, open the Tcl
console tab in Vivado then copy-and-paste the following Tcl commands:

```
set proj_path [get_property DIRECTORY [current_project]]
set proj_name [get_property NAME [current_project]]
set top_module_name [get_property top [current_fileset]]
set bit_filename [lindex [glob -dir "${proj_path}/${proj_name}.runs/impl_1" *.bit] 0]
set export_dir "${proj_path}/${proj_name}.sdk"
set hwdef_filename "${proj_path}/${proj_name}.runs/impl_1/$top_module_name.hwdef"
set bit_filename "${proj_path}/${proj_name}.runs/impl_1/$top_module_name.bit"
set mmi_filename "${proj_path}/${proj_name}.runs/impl_1/$top_module_name.mmi"
file mkdir $export_dir
write_sysdef -force -hwdef $hwdef_filename -bitfile $bit_filename -meminfo $mmi_filename $export_dir/$top_module_name.hdf
```

Note that the .HDF file is generated regardless of the warning message 
`WARNING: [Common 17-210] 'write_sysdef' is deprecated.`.

Those Tcl commands will create a .sdk directory within the project directory, and then
generate a .hdf file in that directory. The `build-sdk.tcl` script can then be run from
the SDK directory to build the SDK workspace (see the following instructions).

### How to build the SDK workspace

In order to make use of these source files, you must first generate
the Vivado project hardware design (the bitstream) and export the design
to SDK. Check the `Vivado` folder for instructions on doing this from Vivado.

Once the bitstream is generated and exported to SDK, then you can build the
SDK workspace using the provided `build-sdk.tcl` script.

### Scripted build

The SDK directory contains a `build-sdk.tcl` script which can be run to automatically
generate the SDK workspace. Windows users can run the `build-sdk.bat` file which
launches the Tcl script. Linux users must use the following commands to run the build
script:
```
cd <path-to-repo>/SDK
/<path-to-xilinx-tools>/SDK/2019.1/bin/xsdk -batch -source build-sdk.tcl
```

The build script does three things:

1. Prepares a local SDK repository containing a modified version of lwIP library,
required by the echo server example application.
2. Adds the ../EmbeddedSw directory as a local SDK repository.
3. Generates a lwIP Echo Server example application for each exported Vivado design
that is found in the ../Vivado directory. Most users will only have one exported
Vivado design.

### Run the application

1. Open Xilinx SDK.
2. Power up your hardware platform and ensure that the JTAG is
connected properly.
3. Select Xilinx Tools->Program FPGA. You only have to do this
once, each time you power up your hardware platform.
4. Select Run->Run to run your application. You can modify the code
and click Run as many times as you like, without going through
the other steps.

### How to change the Ethernet port targetted by the application

The echo server example design currently can only target one Ethernet port at a time.
Selection of the Ethernet port can be changed by modifying the defines contained in the
`platform_config.h` file in the application sources. Set `PLATFORM_EMAC_BASEADDR`
to one of the following values:

* Ethernet FMC Port 0: `XPAR_AXIETHERNET_0_BASEADDR`
* Ethernet FMC Port 1: `XPAR_AXIETHERNET_1_BASEADDR`
* Ethernet FMC Port 2: `XPAR_AXIETHERNET_2_BASEADDR`
* Ethernet FMC Port 3: `XPAR_AXIETHERNET_3_BASEADDR`
