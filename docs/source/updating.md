# Updating the projects

This section contains instructions for updating the reference designs. It is intended as a guide
for anyone wanting to attempt updating the designs for a tools release that we do not yet support.
Note that the update process is not always straight-forward and sometimes requires dealing with
new issues or significant changes to the functionality of the tools and/or specific IP. Unfortunately, 
we cannot always provide support if you have trouble updating the designs.

## Vivado projects

1. Download and install the Vivado release that you intend to use.
2. In a text editor, open the `Vivado/scripts/build.tcl` file and perform the following changes:
   * Update the `version_required` variable value to the tools version number 
     that you are using.
   * Update the year in all references to `Vivado Synthesis <year>` to the 
     tools version number that you are using. For example, if you are using tools
     version 2022.1, then the `<year>` should be 2022.
   * Update the year in all references to `Vivado Implementation <year>` to the 
     tools version number that you are using. For example, if you are using tools
     version 2022.1, then the `<year>` should be 2022.
3. In a text editor, open the `Vivado/scripts/xsa.tcl` file and perform the following changes:
   * Update the `version_required` variable value to the tools version number 
     that you are using.
4. **Windows users only:** In a text editor, open the `Vivado/build-<target>.bat` file for
   the design that you wish to update, and update the tools version number to the one you are using 
   (eg. 2022.1).

After completing the above, you should now be able to use the [build instructions](build_instructions) to
build the Vivado project. If there were no significant changes to the tools and/or IP, the build script 
should succeed and you will be able to open and generate a bitstream.

## PetaLinux

The main procedure for updating the PetaLinux project is to update the BSP for the target platform.
The BSP files for each supported target platform are contained in the `PetaLinux/bsp` directory.

1. Download and install the PetaLinux release that you intend to use.
2. Download and install the BSP for the target platform for the release that you intend to use.

   * For AC701, KC705, KCU105, VCU118, ZC702, ZC706 and ZCU102 download the BSP from the 
     [Xilinx downloads] page
   * For PicoZed, ZedBoard, and UltraZed-EV download the BSP from the [Avnet downloads] page

3. Update the BSP files for the target platform in the `PetaLinux/bsp/<platform>` directory. 
   These are the specific directories to update:
   * `<platform>/project-spec/configs/*`
   * `<platform>/project-spec/meta-user/*`   
   The simple way to update the files is to delete the `configs` and `meta-user` folders from the repository
   and copy in those folders from the more recent BSP.
4. Apply the required modifications to the updated BSP files. The modifications are described for each
   target platform in the following sections.
   
### Change project name

This BSP modification applies to all target platforms.

1. Append the following lines to `project-spec/configs/config`:

```
# Set project name
CONFIG_SUBSYSTEM_HOSTNAME="axieth"
CONFIG_SUBSYSTEM_PRODUCT="axieth"
```
   
Note that this will set the project name to "axieth" but you can use a more descriptive name, for example
one that includes the target platform name and the tools version.

### Add tools to root filesystem

This BSP modification applies to all target platforms.

1. Append the following lines to `project-spec/configs/rootfs_config`:

```
# Useful tools for Ethernet FMC
CONFIG_ethtool=y
CONFIG_ethtool-dev=y
CONFIG_ethtool-dbg=y
CONFIG_iperf3=y
```

2. Append the following lines to `project-spec/meta-user/conf/user-rootfsconfig`:

```
CONFIG_iperf3
CONFIG_ethtool
```

### Include port config in device tree

This BSP modification applies to all target platforms.

1. Append the following line after `/include/ "system-conf.dtsi"` in 
   `project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi`:

```
/include/ "port-config.dtsi"
```

2. Append the following line after `SRC_URI += "file://system-user.dtsi"` in 
   `project-spec/meta-user/recipes-bsp/device-tree/device-tree.bbappend`:

```
SRC_URI += "file://port-config.dtsi"
```

### Add kernel configs

This BSP modification applies to all target platforms.

1. Add the following lines to the top of file `project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg`:

```
# Required by all designs
CONFIG_XILINX_GMII2RGMII=y
CONFIG_MVMDIO=y
CONFIG_MARVELL_PHY=y

# Required by BSP
```

### Kernel configs for ZynqMP designs

This BSP modification must be applied to all ZynqMP designs (ie. ZCU102 and UltraZed EV) in addition to the previous one.

1. Add the following lines to the top of file `project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg`:

```
# All zynqMP designs need these kernel configs for AXI Ethernet designs
CONFIG_XILINX_DMA_ENGINES=y
CONFIG_XILINX_DPDMA=y
CONFIG_XILINX_ZYNQMP_DMA=y
```

### Mods for AC701

These modifications are specific to the AC701 BSP.

1. Append the following lines to `project-spec/configs/config`:

```
# Use lite template
CONFIG_SUBSYSTEM_MACHINE_NAME="ac701-lite"
```

### Mods for KC705

These modifications are specific to the KC705 BSP.

1. Append the following lines to `project-spec/configs/config`:

```
# Use lite template
CONFIG_SUBSYSTEM_MACHINE_NAME="kc705-lite"
```
   
### Mods for KCU105

These modifications are specific to the KCU105 BSP.

1. Append the following lines to `project-spec/configs/config`:

```
# Use general template
CONFIG_SUBSYSTEM_MACHINE_NAME="template"
```
   
2. Append the following lines to file `project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi`:

```
&iic_main {
  #address-cells = <1>;
  #size-cells = <0>;
  i2c-mux@75 {
    compatible = "nxp,pca9544";
    #address-cells = <1>;
    #size-cells = <0>;
    reg = <0x75>;
    i2c@3 {
      #address-cells = <1>;
      #size-cells = <0>;
      reg = <3>;
      eeprom@54 {
        compatible = "atmel,24c08";
        reg = <0x54>;
      };
    };
  };
};
```
   
### Mods for VC707

These modifications are specific to the VC707 BSP. As Xilinx doesn't provide a BSP for the VC707, we instead use
the BSP for the KC705 and modify it to suit the VC707.

1. Replace the line `CONFIG_XILINX_MICROBLAZE0_FAMILY="kintex7"` with the following in 
  `project-spec/configs/linux-xlnx/plnx_kernel.cfg`:

```
CONFIG_XILINX_MICROBLAZE0_FAMILY="virtex7"
```
  
2. Append the following lines to `project-spec/configs/config`:

```
# Use general template
CONFIG_SUBSYSTEM_MACHINE_NAME="template"

# Larger partition for bitstream
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART0_SIZE=0xD00000
```

### Mods for VC709

These modifications are specific to the VC709 BSP. As Xilinx doesn't provide a BSP for the VC709, we instead use
the BSP for the KC705 and modify it to suit the VC709.

1. Replace the line `CONFIG_XILINX_MICROBLAZE0_FAMILY="kintex7"` with the following in 
   `project-spec/configs/linux-xlnx/plnx_kernel.cfg`:

```
CONFIG_XILINX_MICROBLAZE0_FAMILY="virtex7"
```
  
2. Append the following lines to `project-spec/configs/config`:

```
# Use general template
CONFIG_SUBSYSTEM_MACHINE_NAME="template"
```
  
### Mods for VCU108

These modifications are specific to the VCU108 BSP.

1. Append the following lines to `project-spec/configs/config`:

```
# Use general template
CONFIG_SUBSYSTEM_MACHINE_NAME="template"

# Flash Settings - use Linear flash instead of QSPI
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_SELECT=y
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART0_NAME="fpga"
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART0_SIZE=0x1B00000
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART1_NAME="boot"
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART1_SIZE=0x180000
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART2_NAME="bootenv"
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART2_SIZE=0x20000
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART3_NAME="kernel"
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART3_SIZE=0xC00000
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART4_NAME=""
CONFIG_SUBSYSTEM_FLASH_IP_NAME="axi_emc_0"
```

### Mods for VCU118

These modifications are specific to the VCU118 BSP.

1. Append the following lines to `project-spec/configs/config`:

```
# Use general template
# We use the template because the board dtsi expects axi_ethernet_0 to be 
# the on-board Ethernet, and axi_iic_0 to be the I2C. We define the I2C
# device tree for iic_main in the system-user.dtsi in this BSP.
CONFIG_SUBSYSTEM_MACHINE_NAME="template"

# Flash Settings - use Linear flash instead of QSPI
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_SELECT=y
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART0_NAME="fpga"
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART0_SIZE=0x1C00000
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART1_NAME="boot"
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART1_SIZE=0x180000
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART2_NAME="bootenv"
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART2_SIZE=0x20000
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART3_NAME="kernel"
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART3_SIZE=0xC00000
CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART4_NAME=""
CONFIG_SUBSYSTEM_FLASH_IP_NAME="axi_emc_0"
```

2. Append the following lines to file `project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi`:

```
&iic_main {
  #address-cells = <1>;
  #size-cells = <0>;
  i2c-mux@75 {
    compatible = "nxp,pca9548";
    #address-cells = <1>;
    #size-cells = <0>;
    reg = <0x75>;
    i2c@3 {
      #address-cells = <1>;
      #size-cells = <0>;
      reg = <3>;
      eeprom@54 {
        compatible = "atmel,24c08";
        reg = <0x54>;
      };
    };
  };
  i2c-mux@74 {
    compatible = "nxp,pca9548";
    #address-cells = <1>;
    #size-cells = <0>;
    reg = <0x74>;
    i2c@0 {
      #address-cells = <1>;
      #size-cells = <0>;
      reg = <0>;
      si570: clock-generator@5d {
        #clock-cells = <0>;
        compatible = "silabs,si570";
        temperature-stability = <50>;
        reg = <0x5d>;
        factory-fout = <156250000>;
        clock-frequency = <148500000>;
      };
    };
  };
};
```

[Xilinx downloads]: https://www.xilinx.com/support/download.html
[Avnet downloads]: https://avnet.me/zedsupport

