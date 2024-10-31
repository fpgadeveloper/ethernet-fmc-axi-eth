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
     version 2024.1, then the `<year>` should be 2024.
   * Update the year in all references to `Vivado Implementation <year>` to the 
     tools version number that you are using. For example, if you are using tools
     version 2024.1, then the `<year>` should be 2024.
3. In a text editor, open the `Vivado/scripts/xsa.tcl` file and perform the following changes:
   * Update the `version_required` variable value to the tools version number 
     that you are using.
4. **Windows users only:** In a text editor, open the `Vivado/build-vivado.bat` file and update 
   the tools version number to the one you are using (eg. 2024.1).

After completing the above, you should now be able to use the [build instructions](build_instructions) to
build the Vivado project. If there were no significant changes to the tools and/or IP, the build script 
should succeed and you will be able to open and generate a bitstream.

## PetaLinux

The main procedure for updating the PetaLinux project is to update the BSP for the target platform.
The BSP files for each supported target platform are contained in the `PetaLinux/bsp` directory.

1. Download and install the PetaLinux release that you intend to use.
2. Download and install the BSP for the target platform for the release that you intend to use.

   * For all Xilinx evaluation boards, download the BSP from the [Xilinx downloads] page
   * For PicoZed and UltraZed-EV download the BSP from the [Avnet downloads] page
   * For the ZedBoard, we use the ZC702 BSP which can be downloaded from the [Xilinx downloads] page

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

2. Append the following line after `SRC_URI:append = " file://config file://system-user.dtsi` in 
   `project-spec/meta-user/recipes-bsp/device-tree/device-tree.bbappend`:

```
SRC_URI:append = " file://port-config.dtsi"
```

### Add kernel configs

This BSP modification applies to all target platforms.

1. Append the following lines to file `project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg`:

```
# Required by all designs
CONFIG_XILINX_GMII2RGMII=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=y
CONFIG_MARVELL_PHY=y
CONFIG_AMD_PHY=y
CONFIG_XILINX_PHY=y
```

### Mods for all ZynqMP designs

These BSP modifications must be applied to all ZynqMP designs (ie. ZCU102 and UltraZed EV) in addition to 
the previous one.

1. Append the following lines to `project-spec/configs/config`. These options configure the design
   to use the SD card to store the root filesystem.

```
# SD card for root filesystem

CONFIG_SUBSYSTEM_BOOTARGS_AUTO=n
CONFIG_SUBSYSTEM_USER_CMDLINE="earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk0p2 rw rootwait cma=1536M"

CONFIG_SUBSYSTEM_ROOTFS_INITRD=n
CONFIG_SUBSYSTEM_ROOTFS_EXT4=y
CONFIG_SUBSYSTEM_SDROOT_DEV="/dev/mmcblk0p2"
CONFIG_SUBSYSTEM_RFS_FORMATS="tar.gz ext4 ext4.gz "
```

2. Append the following lines to `project-spec/configs/rootfs_config`:

```
# Add extra tools for debugging Ethernet with ethtool

CONFIG_ethtool-dev=y
CONFIG_ethtool-dbg=y
```

3. Add the following lines to the top of file `project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg`:

```
# All zynqMP designs need these kernel configs for AXI Ethernet designs
CONFIG_XILINX_DMA_ENGINES=y
CONFIG_XILINX_DPDMA=y
CONFIG_XILINX_ZYNQMP_DMA=y
```

### Mods for all Zynq-7000 designs

The following modifications apply to all the Zynq-7000 based designs (PicoZed, ZC702, ZC706).

1. Append the following lines to `project-spec/configs/config`. These options configure the design
   to use the SD card to store the root filesystem.

```
# SD card for root filesystem

CONFIG_SUBSYSTEM_BOOTARGS_AUTO=n
CONFIG_SUBSYSTEM_USER_CMDLINE="earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk0p2 rw rootwait cma=1536M"

CONFIG_SUBSYSTEM_ROOTFS_INITRD=n
CONFIG_SUBSYSTEM_ROOTFS_EXT4=y
CONFIG_SUBSYSTEM_SDROOT_DEV="/dev/mmcblk0p2"
CONFIG_SUBSYSTEM_RFS_FORMATS="tar.gz ext4 ext4.gz "
```

2. Append the following lines to `project-spec/configs/rootfs_config`:

```
# Add extra tools for debugging Ethernet with ethtool

CONFIG_ethtool-dev=y
CONFIG_ethtool-dbg=y
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
   
### Mods for VCU118

These modifications are specific to the VCU118 BSP.

1. Append the following lines to `project-spec/configs/config`:

```
# Modifications to VCU118 BSP

# We use the template because the board dtsi expects axi_ethernet_0 to be 
# the on-board Ethernet, and axi_iic_0 to be the I2C. We define the I2C
# device tree for iic_main in the system-user.dtsi in this BSP.
CONFIG_SUBSYSTEM_MACHINE_NAME="template"

# Flash Settings - QSPI (increase fpga and kernel partition sizes)
CONFIG_SUBSYSTEM_FLASH_AXI_QUAD_SPI_0_BANKLESS_PART0_SIZE=0x2400000
CONFIG_SUBSYSTEM_FLASH_AXI_QUAD_SPI_0_BANKLESS_PART3_SIZE=0xE00000
CONFIG_SUBSYSTEM_UBOOT_QSPI_FIT_IMAGE_OFFSET=0x25A0000
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

### Mods for PicoZed FMC Carrier v2

These modifications are specific to the PicoZed FMC Carrier v2 BSP.

1. Append the following lines to `project-spec/configs/config`:

```
# PZ configs

CONFIG_YOCTO_MACHINE_NAME="zynq-generic"
CONFIG_USER_LAYER_0=""
CONFIG_SUBSYSTEM_PRIMARY_SD_PSU_SD_0_SELECT=n
CONFIG_SUBSYSTEM_PRIMARY_SD_PSU_SD_1_SELECT=y
CONFIG_SUBSYSTEM_SD_PSU_SD_0_SELECT=n
```

2. Append the following lines to file `project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg`:

```
# Required by PZ BSP
CONFIG_USB_ACM=y
CONFIG_USB_F_ACM=m
CONFIG_USB_U_SERIAL=m
CONFIG_USB_CDC_COMPOSITE=m
CONFIG_I2C_XILINX=y
```

### Mods for ZedBoard

These modifications are specific to the ZedBoard BSP.

```{note}
Note that Avnet no longer maintains a BSP for the ZedBoard, so we are instead using the BSP for the ZC702
and making modifications for it to work with the ZedBoard.
```

1. Append the following lines to `project-spec/configs/config`:

```
# ZedBoard configs

CONFIG_YOCTO_MACHINE_NAME="zynq-generic"
```

2. Append the following lines to file `project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg`:

```
# Required by ZedBoard BSP
CONFIG_USB_SUSPEND=y
CONFIG_USB_OTG=y
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_XUSBPS=y
CONFIG_XILINX_ZED_USB_OTG=y
# CONFIG_USB_ETH is not set
# CONFIG_USB_ETH_RNDIS is not set
CONFIG_USB_ZERO=m
```

### Mods for UltraZed-EV Carrier

These modifications are specific to the UltraZed-EV BSP.

1. Append the following lines to `project-spec/configs/config`.

```
# UZ-EV configs

CONFIG_YOCTO_MACHINE_NAME="zynqmp-generic"
CONFIG_USER_LAYER_0=""
CONFIG_SUBSYSTEM_SDROOT_DEV="/dev/mmcblk1p2"
CONFIG_SUBSYSTEM_USER_CMDLINE=" earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk1p2 rw rootwait cma=1000M"
CONFIG_SUBSYSTEM_PRIMARY_SD_PSU_SD_0_SELECT=n
CONFIG_SUBSYSTEM_PRIMARY_SD_PSU_SD_1_SELECT=y
CONFIG_SUBSYSTEM_SD_PSU_SD_0_SELECT=n
```

2. Append the following lines to `project-spec/meta-user/conf/petalinuxbsp.conf`.

```
IMAGE_BOOT_FILES:zynqmp = "BOOT.BIN boot.scr Image system.dtb"
```

3. Overwrite the device tree file 
   `project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi` with the one that is in the
   repository.


[Xilinx downloads]: https://www.xilinx.com/support/download.html
[Avnet downloads]: https://avnet.me/zedsupport

