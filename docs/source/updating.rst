=====================
Updating the projects
=====================

This section contains instructions for updating the reference designs. It is intended as a guide
for anyone wanting to attempt updating the designs for a tools release that we do not yet support.
Note that the update process is not always straight-forward and sometimes requires dealing with
new issues or significant changes to the functionality of the tools and/or specific IP. Unfortunately, 
we cannot always provide support if you have trouble updating the designs.

Vivado projects
===============

1. Download and install the Vivado release that you intend to use.
2. If you are using one of the following boards, you will have to download and install the latest 
   board files for that target platform. Other boards are already built into Vivado and require no
   extra installation.

   * MicroZed board files can be downloaded `here <https://github.com/Avnet/bdf>`_
   * PicoZed board files can be downloaded `here <https://github.com/Avnet/bdf>`_
   * UltraZed EV board files can be downloaded `here <https://github.com/Avnet/bdf>`_
   
3. In a text editor, open the ``Vivado/build-<target>.bat`` file for
   the design that you wish to update, and perform the following changes:
   
   * Update the tools version number to the one you are using (eg. 2020.2)
   
4. In a text editor, open the ``Vivado/build-<target>.tcl`` file for
   the design that you wish to update, and perform the following changes:
   
   * Update the ``version_required`` variable value to the tools version number 
     that you are using.
   * Update the year in all references to ``Vivado Synthesis <year>`` to the 
     tools version number that you are using. For example, if you are using tools
     version 2020.2, then the ``<year>`` should be 2020.
   * Update the year in all references to ``Vivado Implementation <year>`` to the 
     tools version number that you are using. For example, if you are using tools
     version 2020.2, then the ``<year>`` should be 2020.
   * If the version of the board files for your target platform has changed, update 
     the ``board_part`` parameter value to the new version.

After following the above steps, you can now run the build script. If there were no significant changes
to the tools and/or IP, the build script should succeed and you will be able to open and generate a 
bitstream for the Vivado project.

PetaLinux
=========

The main procedure for updating the PetaLinux project is to update the BSP for the target platform.
The BSP files for each supported target platform are contained in the ``PetaLinux/src`` directory.
For example, the BSP files for the ZedBoard are located in ``PetaLinux/src/zedboard``.

1. Download and install the PetaLinux release that you intend to use.
2. Download and install the BSP for the target platform for the release that you intend to use.

   * For AC701, KC705, KCU105, VCU118, ZC702, ZC706, ZCU102 and ZedBoard, download the BSP from the 
     `PetaLinux download page <https://www.xilinx.com/petalinux>`_
   * For MicroZed and PicoZed, download the BSP for the **ZedBoard** from the 
     `PetaLinux download page <https://www.xilinx.com/petalinux>`_
   * For the UltraZed EV, download the BSP for the **ZCU102** from the 
     `PetaLinux download page <https://www.xilinx.com/petalinux>`_
   * For the VC707 and VC709, download the BSP for the **KC705** from the 
     `PetaLinux download page <https://www.xilinx.com/petalinux>`_
   * For the VCU108, download the BSP for the **VCU118** from the 
     `PetaLinux download page <https://www.xilinx.com/petalinux>`_

3. Update the BSP files for the target platform in the ``PetaLinux/src/<platform>`` directory. 
   These are the specific directories to update:
   
   * ``<platform>/project-spec/configs/*``
   * ``<platform>/project-spec/meta-user/*``
   
   The simple way to update the files is to delete those in the repository and copy in those from
   the BSP that you just downloaded.
   
4. Apply the required modifications to the updated BSP files. The modifications are described for each
   target platform in the following sections.
   
Change project name
-------------------   

This BSP modification applies to all target platforms.

1. Append the following lines to ``project-spec/configs/config``:

.. code-block:: 
   
  # Set project name
  CONFIG_SUBSYSTEM_HOSTNAME="axieth"
  CONFIG_SUBSYSTEM_PRODUCT="axieth"
   
Note that this will set the project name to "axieth" but you can use a more descriptive name, for example
one that includes the target platform name and the tools version.

Add tools to root filesystem
----------------------------

This BSP modification applies to all target platforms.

1. Append the following lines to ``project-spec/configs/rootfs_config``:

.. code-block::

  # Useful tools for Ethernet FMC
  CONFIG_ethtool=y
  CONFIG_ethtool-dev=y
  CONFIG_ethtool-dbg=y
  CONFIG_iperf3=y

2. Append the following lines to ``project-spec/meta-user/conf/user-rootfsconfig``:

.. code-block::

  CONFIG_iperf3
  CONFIG_ethtool

Include port config in device tree
----------------------------------

This BSP modification applies to all target platforms.

1. Append the following line after ``/include/ "system-conf.dtsi"`` in ``project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi``:

.. code-block::

  /include/ "port-config.dtsi"

2. Append the following line after ``SRC_URI += "file://system-user.dtsi"`` in ``project-spec/meta-user/recipes-bsp/device-tree/device-tree.bbappend``:

.. code-block::

  SRC_URI += "file://port-config.dtsi"

Add kernel configs
------------------

This BSP modification applies to all target platforms.

1. Add the following lines to the top of file ``project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg``:

.. code-block::

  # Required by all designs
  CONFIG_XILINX_GMII2RGMII=y
  CONFIG_MVMDIO=y
  CONFIG_MARVELL_PHY=y

  # Required by BSP

Kernel configs for ZynqMP designs
---------------------------------

This BSP modification must be applied to all ZynqMP designs (ie. ZCU102 and UltraZed EV) in addition to the previous one.

1. Add the following lines to the top of file ``project-spec/meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg``:

.. code-block::

  # All zynqMP designs need these kernel configs for AXI Ethernet designs
  CONFIG_XILINX_DMA_ENGINES=y
  CONFIG_XILINX_DPDMA=y
  CONFIG_XILINX_ZYNQMP_DMA=y


Mods for AC701
--------------

These modifications are specific to the AC701 BSP.

1. Append the following lines to ``project-spec/configs/config``:

.. code-block:: 
   
  # Use lite template
  CONFIG_SUBSYSTEM_MACHINE_NAME="ac701-lite"

2. Append the following lines to file ``project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h``:

.. code-block:: c

  /* BOOTCOMMAND */
  #define CONFIG_USE_BOOTCOMMAND 1
  #define CONFIG_BOOTCOMMAND	"sf probe 0 && sf read ${netstartaddr} ${kernelstart} ${kernelsize} && bootm ${netstartaddr}"

  /* Extra U-Boot Env settings */
  #define CONFIG_EXTRA_ENV_SETTINGS \
    SERIAL_MULTI \ 
    CONSOLE_ARG \ 
    ESERIAL0 \ 
    "nc=setenv stdout nc;setenv stdin nc;\0" \ 
    "ethaddr=00:0a:35:00:22:01\0" \
    "autoload=no\0" \ 
    "sdbootdev=0\0" \ 
    "clobstart=0x80000000\0" \ 
    "netstart=0x80000000\0" \ 
    "dtbnetstart=0x81e00000\0" \ 
    "netstartaddr=0x81000000\0"  "loadaddr=0x80000000\0" \ 
    "initrd_high=0x0\0" \ 
    "bootsize=0x180000\0" \ 
    "bootstart=0xa00000\0" \ 
    "boot_img=u-boot-s.bin\0" \ 
    "load_boot=tftpboot ${clobstart} ${boot_img}\0" \ 
    "update_boot=setenv img boot; setenv psize ${bootsize}; setenv installcmd \"install_boot\"; run load_boot test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_boot=sf probe 0 && sf erase ${bootstart} ${bootsize} && " \ 
      "sf write ${clobstart} ${bootstart} ${filesize}\0" \ 
    "bootenvsize=0x40000\0" \ 
    "bootenvstart=0xb80000\0" \ 
    "eraseenv=sf probe 0 && sf erase ${bootenvstart} ${bootenvsize}\0" \ 
    "kernelsize=0xc00000\0" \ 
    "kernelstart=0xbc0000\0" \ 
    "kernel_img=image.ub\0" \ 
    "load_kernel=tftpboot ${clobstart} ${kernel_img}\0" \ 
    "update_kernel=setenv img kernel; setenv psize ${kernelsize}; setenv installcmd \"install_kernel\"; run load_kernel test_crc; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_kernel=sf probe 0 && sf erase ${kernelstart} ${kernelsize} && " \ 
      "sf write ${clobstart} ${kernelstart} ${filesize}\0" \ 
    "cp_kernel2ram=sf probe 0 && sf read ${netstart} ${kernelstart} ${kernelsize}\0" \ 
    "fpgasize=0xa00000\0" \ 
    "fpgastart=0x0\0" \ 
    "fpga_img=system.bit.bin\0" \ 
    "load_fpga=tftpboot ${clobstart} ${fpga_img}\0" \ 
    "update_fpga=setenv img fpga; setenv psize ${fpgasize}; setenv installcmd \"install_fpga\"; run load_fpga test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_fpga=sf probe 0 && sf erase ${fpgastart} ${fpgasize} && " \ 
      "sf write ${clobstart} ${fpgastart} ${filesize}\0" \ 
    "fault=echo ${img} image size is greater than allocated place - partition ${img} is NOT UPDATED\0" \ 
    "test_crc=if imi ${clobstart}; then run test_img; else echo ${img} Bad CRC - ${img} is NOT UPDATED; fi\0" \ 
    "test_img=setenv var \"if test ${filesize} -gt ${psize}\\; then run fault\\; else run ${installcmd}\\; fi\"; run var; setenv var\0" \ 
    "netboot=tftpboot ${netstartaddr} ${kernel_img} && bootm\0" \ 
    "default_bootcmd=bootcmd\0" \ 
  ""

Mods for KC705
--------------

These modifications are specific to the KC705 BSP.

1. Append the following lines to ``project-spec/configs/config``:

.. code-block:: 
   
  # Use lite template
  CONFIG_SUBSYSTEM_MACHINE_NAME="kc705-lite"
   
2. Append the following lines to file ``project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h``:

.. code-block:: c

  /* BOOTCOMMAND */
  #define CONFIG_USE_BOOTCOMMAND 1
  #define CONFIG_BOOTCOMMAND	"cp.b ${kernelstart} ${netstartaddr} ${kernelsize} && bootm ${netstartaddr}"

  /* Extra U-Boot Env settings */
  #define CONFIG_EXTRA_ENV_SETTINGS \
    SERIAL_MULTI \ 
    CONSOLE_ARG \ 
    ESERIAL0 \ 
    "nc=setenv stdout nc;setenv stdin nc;\0" \ 
    "ethaddr=00:0a:35:00:22:01\0" \
    "autoload=no\0" \ 
    "sdbootdev=0\0" \ 
    "clobstart=0x80000000\0" \ 
    "netstart=0x80000000\0" \ 
    "dtbnetstart=0x81e00000\0" \ 
    "netstartaddr=0x81000000\0"  "loadaddr=0x80000000\0" \ 
    "initrd_high=0x0\0" \ 
    "bootsize=0x180000\0" \ 
    "bootstart=0x60b00000\0" \ 
    "boot_img=u-boot-s.bin\0" \ 
    "load_boot=tftpboot ${clobstart} ${boot_img}\0" \ 
    "update_boot=setenv img boot; setenv psize ${bootsize}; setenv installcmd \"install_boot\"; run load_boot test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_boot=protect off ${bootstart} +${bootsize} && erase ${bootstart} +${bootsize} && "  "cp.b ${clobstart} ${bootstart} ${filesize}\0" \ 
    "bootenvsize=0x20000\0" \ 
    "bootenvstart=0x60c80000\0" \ 
    "eraseenv=protect off ${bootenvstart} +${bootenvsize} && erase ${bootenvstart} +${bootenvsize}\0" \ 
    "kernelsize=0xc00000\0" \ 
    "kernelstart=0x60ca0000\0" \ 
    "kernel_img=image.ub\0" \ 
    "load_kernel=tftpboot ${clobstart} ${kernel_img}\0" \ 
    "update_kernel=setenv img kernel; setenv psize ${kernelsize}; setenv installcmd \"install_kernel\"; run load_kernel test_crc; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_kernel=protect off ${kernelstart} +${kernelsize} && erase ${kernelstart} +${kernelsize} && "  "cp.b ${clobstart} ${kernelstart} ${filesize}\0" \ 
    "cp_kernel2ram=cp.b ${kernelstart} ${netstart} ${kernelsize}\0" \ 
    "fpgasize=0xb00000\0" \ 
    "fpgastart=0x60000000\0" \ 
    "fpga_img=system.bit.bin\0" \ 
    "load_fpga=tftpboot ${clobstart} ${fpga_img}\0" \ 
    "update_fpga=setenv img fpga; setenv psize ${fpgasize}; setenv installcmd \"install_fpga\"; run load_fpga test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_fpga=protect off ${fpgastart} +${fpgasize} && erase ${fpgastart} +${fpgasize} && "  "cp.b ${clobstart} ${fpgastart} ${filesize}\0" \ 
    "fault=echo ${img} image size is greater than allocated place - partition ${img} is NOT UPDATED\0" \ 
    "test_crc=if imi ${clobstart}; then run test_img; else echo ${img} Bad CRC - ${img} is NOT UPDATED; fi\0" \ 
    "test_img=setenv var \"if test ${filesize} -gt ${psize}\\; then run fault\\; else run ${installcmd}\\; fi\"; run var; setenv var\0" \ 
    "netboot=tftpboot ${netstartaddr} ${kernel_img} && bootm\0" \ 
    "default_bootcmd=bootcmd\0" \ 
  ""

Mods for KCU105
---------------

These modifications are specific to the KCU105 BSP.

1. Append the following lines to ``project-spec/configs/config``:

.. code-block:: 
   
  # Use general template
  CONFIG_SUBSYSTEM_MACHINE_NAME="template"
   
2. Append the following lines to file ``project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi``:

.. code-block::

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

   
3. Append the following lines to file ``project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h``:

.. code-block:: c

  // Boot from QSPI flash
  #define CONFIG_USE_BOOTCOMMAND 1
  #define CONFIG_BOOTCOMMAND	"sf probe 0 && sf read ${netstartaddr} ${kernelstart} ${kernelsize} && bootm ${netstartaddr}"

  /* Extra U-Boot Env settings */
  #define CONFIG_EXTRA_ENV_SETTINGS \
    SERIAL_MULTI \ 
    CONSOLE_ARG \ 
    ESERIAL0 \ 
    "nc=setenv stdout nc;setenv stdin nc;\0" \ 
    "ethaddr=00:0a:35:00:22:01\0" \
    "autoload=no\0" \ 
    "sdbootdev=0\0" \ 
    "clobstart=0x80000000\0" \ 
    "netstart=0x80000000\0" \ 
    "dtbnetstart=0x81e00000\0" \ 
    "netstartaddr=0x81000000\0"  "loadaddr=0x80000000\0" \ 
    "initrd_high=0x0\0" \ 
    "bootsize=0x180000\0" \ 
    "bootstart=0x1000000\0" \ 
    "boot_img=u-boot-s.bin\0" \ 
    "load_boot=tftpboot ${clobstart} ${boot_img}\0" \ 
    "update_boot=setenv img boot; setenv psize ${bootsize}; setenv installcmd \"install_boot\"; run load_boot test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_boot=sf probe 0 && sf erase ${bootstart} ${bootsize} && " \ 
      "sf write ${clobstart} ${bootstart} ${filesize}\0" \ 
    "bootenvsize=0x40000\0" \ 
    "bootenvstart=0x1180000\0" \ 
    "eraseenv=sf probe 0 && sf erase ${bootenvstart} ${bootenvsize}\0" \ 
    "kernelsize=0xc00000\0" \ 
    "kernelstart=0x11c0000\0" \ 
    "kernel_img=image.ub\0" \ 
    "load_kernel=tftpboot ${clobstart} ${kernel_img}\0" \ 
    "update_kernel=setenv img kernel; setenv psize ${kernelsize}; setenv installcmd \"install_kernel\"; run load_kernel test_crc; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_kernel=sf probe 0 && sf erase ${kernelstart} ${kernelsize} && " \ 
      "sf write ${clobstart} ${kernelstart} ${filesize}\0" \ 
    "cp_kernel2ram=sf probe 0 && sf read ${netstart} ${kernelstart} ${kernelsize}\0" \ 
    "fpgasize=0x1000000\0" \ 
    "fpgastart=0x0\0" \ 
    "fpga_img=system.bit.bin\0" \ 
    "load_fpga=tftpboot ${clobstart} ${fpga_img}\0" \ 
    "update_fpga=setenv img fpga; setenv psize ${fpgasize}; setenv installcmd \"install_fpga\"; run load_fpga test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_fpga=sf probe 0 && sf erase ${fpgastart} ${fpgasize} && " \ 
      "sf write ${clobstart} ${fpgastart} ${filesize}\0" \ 
    "fault=echo ${img} image size is greater than allocated place - partition ${img} is NOT UPDATED\0" \ 
    "test_crc=if imi ${clobstart}; then run test_img; else echo ${img} Bad CRC - ${img} is NOT UPDATED; fi\0" \ 
    "test_img=setenv var \"if test ${filesize} -gt ${psize}\\; then run fault\\; else run ${installcmd}\\; fi\"; run var; setenv var\0" \ 
    "netboot=tftpboot ${netstartaddr} ${kernel_img} && bootm\0" \ 
    "default_bootcmd=bootcmd\0" \ 
  ""
   

Mods for MicroZed
-----------------

These modifications are specific to the MicroZed BSP.


Mods for PicoZed
----------------

These modifications are specific to the PicoZed BSP.

Mods for UltraZed EV
--------------------

These modifications are specific to the UltraZed EV BSP.

Mods for VC707
--------------

These modifications are specific to the VC707 BSP. As Xilinx doesn't provide a BSP for the VC707, we instead use
the BSP for the KC705 and modify it to suit the VC707.

1. Replace the line ``CONFIG_XILINX_MICROBLAZE0_FAMILY="kintex7"`` with the following in ``project-spec/configs/linux-xlnx/plnx_kernel.cfg``:

.. code-block:: 
   
  CONFIG_XILINX_MICROBLAZE0_FAMILY="virtex7"
  
2. Append the following lines to ``project-spec/configs/config``:

.. code-block:: 
   
  # Use general template
  CONFIG_SUBSYSTEM_MACHINE_NAME="template"
  
  # Larger partition for bitstream
  CONFIG_SUBSYSTEM_FLASH_AXI_EMC_0_BANK0_PART0_SIZE=0xD00000

3. Append the following lines to file ``project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h``:

.. code-block:: c

  /* BOOTCOMMAND */
  #define CONFIG_USE_BOOTCOMMAND 1
  #define CONFIG_BOOTCOMMAND	"cp.b ${kernelstart} ${netstartaddr} ${kernelsize} && bootm ${netstartaddr}"

  /* Extra U-Boot Env settings */
  #define CONFIG_EXTRA_ENV_SETTINGS \
    SERIAL_MULTI \ 
    CONSOLE_ARG \ 
    ESERIAL0 \ 
    "nc=setenv stdout nc;setenv stdin nc;\0" \ 
    "ethaddr=00:0a:35:00:22:01\0" \
    "autoload=no\0" \ 
    "sdbootdev=0\0" \ 
    "clobstart=0x80000000\0" \ 
    "netstart=0x80000000\0" \ 
    "dtbnetstart=0x81e00000\0" \ 
    "netstartaddr=0x81000000\0"  "loadaddr=0x80000000\0" \ 
    "initrd_high=0x0\0" \ 
    "bootsize=0x180000\0" \ 
    "bootstart=0x60d00000\0" \ 
    "boot_img=u-boot-s.bin\0" \ 
    "load_boot=tftpboot ${clobstart} ${boot_img}\0" \ 
    "update_boot=setenv img boot; setenv psize ${bootsize}; setenv installcmd \"install_boot\"; run load_boot test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_boot=protect off ${bootstart} +${bootsize} && erase ${bootstart} +${bootsize} && "  "cp.b ${clobstart} ${bootstart} ${filesize}\0" \ 
    "bootenvsize=0x20000\0" \ 
    "bootenvstart=0x60e80000\0" \ 
    "eraseenv=protect off ${bootenvstart} +${bootenvsize} && erase ${bootenvstart} +${bootenvsize}\0" \ 
    "kernelsize=0xc00000\0" \ 
    "kernelstart=0x60ea0000\0" \ 
    "kernel_img=image.ub\0" \ 
    "load_kernel=tftpboot ${clobstart} ${kernel_img}\0" \ 
    "update_kernel=setenv img kernel; setenv psize ${kernelsize}; setenv installcmd \"install_kernel\"; run load_kernel test_crc; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_kernel=protect off ${kernelstart} +${kernelsize} && erase ${kernelstart} +${kernelsize} && "  "cp.b ${clobstart} ${kernelstart} ${filesize}\0" \ 
    "cp_kernel2ram=cp.b ${kernelstart} ${netstart} ${kernelsize}\0" \ 
    "fpgasize=0xd00000\0" \ 
    "fpgastart=0x60000000\0" \ 
    "fpga_img=system.bit.bin\0" \ 
    "load_fpga=tftpboot ${clobstart} ${fpga_img}\0" \ 
    "update_fpga=setenv img fpga; setenv psize ${fpgasize}; setenv installcmd \"install_fpga\"; run load_fpga test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_fpga=protect off ${fpgastart} +${fpgasize} && erase ${fpgastart} +${fpgasize} && "  "cp.b ${clobstart} ${fpgastart} ${filesize}\0" \ 
    "fault=echo ${img} image size is greater than allocated place - partition ${img} is NOT UPDATED\0" \ 
    "test_crc=if imi ${clobstart}; then run test_img; else echo ${img} Bad CRC - ${img} is NOT UPDATED; fi\0" \ 
    "test_img=setenv var \"if test ${filesize} -gt ${psize}\\; then run fault\\; else run ${installcmd}\\; fi\"; run var; setenv var\0" \ 
    "netboot=tftpboot ${netstartaddr} ${kernel_img} && bootm\0" \ 
    "default_bootcmd=bootcmd\0" \ 
  ""


Mods for VC709
--------------

These modifications are specific to the VC709 BSP. As Xilinx doesn't provide a BSP for the VC709, we instead use
the BSP for the KC705 and modify it to suit the VC709.

1. Replace the line ``CONFIG_XILINX_MICROBLAZE0_FAMILY="kintex7"`` with the following in ``project-spec/configs/linux-xlnx/plnx_kernel.cfg``:

.. code-block:: 
   
  CONFIG_XILINX_MICROBLAZE0_FAMILY="virtex7"
  
2. Append the following lines to ``project-spec/configs/config``:

.. code-block:: 
   
  # Use general template
  CONFIG_SUBSYSTEM_MACHINE_NAME="template"
  
3. Append the following lines to file ``project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h``:

.. code-block:: c

  /* BOOTCOMMAND */
  #define CONFIG_USE_BOOTCOMMAND 1
  #define CONFIG_BOOTCOMMAND	"cp.b ${kernelstart} ${netstartaddr} ${kernelsize} && bootm ${netstartaddr}"

  /* Extra U-Boot Env settings */
  #define CONFIG_EXTRA_ENV_SETTINGS \
    SERIAL_MULTI \ 
    CONSOLE_ARG \ 
    ESERIAL0 \ 
    "nc=setenv stdout nc;setenv stdin nc;\0" \ 
    "ethaddr=00:0a:35:00:22:01\0" \
    "autoload=no\0" \ 
    "sdbootdev=0\0" \ 
    "clobstart=0x80000000\0" \ 
    "netstart=0x80000000\0" \ 
    "dtbnetstart=0x81e00000\0" \ 
    "netstartaddr=0x81000000\0"  "loadaddr=0x80000000\0" \ 
    "initrd_high=0x0\0" \ 
    "bootsize=0x180000\0" \ 
    "bootstart=0x60b00000\0" \ 
    "boot_img=u-boot-s.bin\0" \ 
    "load_boot=tftpboot ${clobstart} ${boot_img}\0" \ 
    "update_boot=setenv img boot; setenv psize ${bootsize}; setenv installcmd \"install_boot\"; run load_boot test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_boot=protect off ${bootstart} +${bootsize} && erase ${bootstart} +${bootsize} && "  "cp.b ${clobstart} ${bootstart} ${filesize}\0" \ 
    "bootenvsize=0x20000\0" \ 
    "bootenvstart=0x60c80000\0" \ 
    "eraseenv=protect off ${bootenvstart} +${bootenvsize} && erase ${bootenvstart} +${bootenvsize}\0" \ 
    "kernelsize=0xc00000\0" \ 
    "kernelstart=0x60ca0000\0" \ 
    "kernel_img=image.ub\0" \ 
    "load_kernel=tftpboot ${clobstart} ${kernel_img}\0" \ 
    "update_kernel=setenv img kernel; setenv psize ${kernelsize}; setenv installcmd \"install_kernel\"; run load_kernel test_crc; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_kernel=protect off ${kernelstart} +${kernelsize} && erase ${kernelstart} +${kernelsize} && "  "cp.b ${clobstart} ${kernelstart} ${filesize}\0" \ 
    "cp_kernel2ram=cp.b ${kernelstart} ${netstart} ${kernelsize}\0" \ 
    "fpgasize=0xb00000\0" \ 
    "fpgastart=0x60000000\0" \ 
    "fpga_img=system.bit.bin\0" \ 
    "load_fpga=tftpboot ${clobstart} ${fpga_img}\0" \ 
    "update_fpga=setenv img fpga; setenv psize ${fpgasize}; setenv installcmd \"install_fpga\"; run load_fpga test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_fpga=protect off ${fpgastart} +${fpgasize} && erase ${fpgastart} +${fpgasize} && "  "cp.b ${clobstart} ${fpgastart} ${filesize}\0" \ 
    "fault=echo ${img} image size is greater than allocated place - partition ${img} is NOT UPDATED\0" \ 
    "test_crc=if imi ${clobstart}; then run test_img; else echo ${img} Bad CRC - ${img} is NOT UPDATED; fi\0" \ 
    "test_img=setenv var \"if test ${filesize} -gt ${psize}\\; then run fault\\; else run ${installcmd}\\; fi\"; run var; setenv var\0" \ 
    "netboot=tftpboot ${netstartaddr} ${kernel_img} && bootm\0" \ 
    "default_bootcmd=bootcmd\0" \ 
  ""

Mods for VCU108
---------------

These modifications are specific to the VCU108 BSP.

1. Append the following lines to ``project-spec/configs/config``:

.. code-block:: 
   
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

2. Append the following lines to file ``project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h``:

.. code-block:: c

  /* BOOTCOMMAND */
  #define CONFIG_USE_BOOTCOMMAND 1
  #define CONFIG_BOOTCOMMAND	"cp.b ${kernelstart} ${netstartaddr} ${kernelsize} && bootm ${netstartaddr}"

  /* Extra U-Boot Env settings */
  #define CONFIG_EXTRA_ENV_SETTINGS \
    SERIAL_MULTI \ 
    CONSOLE_ARG \ 
    ESERIAL0 \ 
    "nc=setenv stdout nc;setenv stdin nc;\0" \ 
    "ethaddr=00:0a:35:00:22:01\0" \
    "autoload=no\0" \ 
    "sdbootdev=0\0" \ 
    "clobstart=0x80000000\0" \ 
    "netstart=0x80000000\0" \ 
    "dtbnetstart=0x81e00000\0" \ 
    "netstartaddr=0x81000000\0"  "loadaddr=0x80000000\0" \ 
    "initrd_high=0x0\0" \ 
    "bootsize=0x180000\0" \ 
    "bootstart=0x61B00000\0" \ 
    "boot_img=u-boot-s.bin\0" \ 
    "load_boot=tftpboot ${clobstart} ${boot_img}\0" \ 
    "update_boot=setenv img boot; setenv psize ${bootsize}; setenv installcmd \"install_boot\"; run load_boot test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_boot=protect off ${bootstart} +${bootsize} && erase ${bootstart} +${bootsize} && "  "cp.b ${clobstart} ${bootstart} ${filesize}\0" \ 
    "bootenvsize=0x20000\0" \ 
    "bootenvstart=0x61C80000\0" \ 
    "eraseenv=protect off ${bootenvstart} +${bootenvsize} && erase ${bootenvstart} +${bootenvsize}\0" \ 
    "kernelsize=0xC00000\0" \ 
    "kernelstart=0x61CA0000\0" \ 
    "kernel_img=image.ub\0" \ 
    "load_kernel=tftpboot ${clobstart} ${kernel_img}\0" \ 
    "update_kernel=setenv img kernel; setenv psize ${kernelsize}; setenv installcmd \"install_kernel\"; run load_kernel test_crc; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_kernel=protect off ${kernelstart} +${kernelsize} && erase ${kernelstart} +${kernelsize} && "  "cp.b ${clobstart} ${kernelstart} ${filesize}\0" \ 
    "cp_kernel2ram=cp.b ${kernelstart} ${netstart} ${kernelsize}\0" \ 
    "fpgasize=0x1B00000\0" \ 
    "fpgastart=0x60000000\0" \ 
    "fpga_img=system.bit.bin\0" \ 
    "load_fpga=tftpboot ${clobstart} ${fpga_img}\0" \ 
    "update_fpga=setenv img fpga; setenv psize ${fpgasize}; setenv installcmd \"install_fpga\"; run load_fpga test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_fpga=protect off ${fpgastart} +${fpgasize} && erase ${fpgastart} +${fpgasize} && "  "cp.b ${clobstart} ${fpgastart} ${filesize}\0" \ 
    "fault=echo ${img} image size is greater than allocated place - partition ${img} is NOT UPDATED\0" \ 
    "test_crc=if imi ${clobstart}; then run test_img; else echo ${img} Bad CRC - ${img} is NOT UPDATED; fi\0" \ 
    "test_img=setenv var \"if test ${filesize} -gt ${psize}\\; then run fault\\; else run ${installcmd}\\; fi\"; run var; setenv var\0" \ 
    "netboot=tftpboot ${netstartaddr} ${kernel_img} && bootm\0" \ 
    "default_bootcmd=bootcmd\0" \ 
  ""

Mods for VCU118
---------------

These modifications are specific to the VCU118 BSP.

1. Append the following lines to ``project-spec/configs/config``:

.. code-block:: 
   
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

2. Append the following lines to file ``project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi``:

.. code-block::

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

3. Append the following lines to file ``project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h``:

.. code-block:: c

  /* BOOTCOMMAND */
  #define CONFIG_USE_BOOTCOMMAND 1
  #define CONFIG_BOOTCOMMAND	"cp.b ${kernelstart} ${netstartaddr} ${kernelsize} && bootm ${netstartaddr}"

  /* Extra U-Boot Env settings */
  #define CONFIG_EXTRA_ENV_SETTINGS \
    SERIAL_MULTI \ 
    CONSOLE_ARG \ 
    ESERIAL0 \ 
    "nc=setenv stdout nc;setenv stdin nc;\0" \ 
    "ethaddr=00:0a:35:00:22:01\0" \
    "autoload=no\0" \ 
    "sdbootdev=0\0" \ 
    "clobstart=0x80000000\0" \ 
    "netstart=0x80000000\0" \ 
    "dtbnetstart=0x81e00000\0" \ 
    "netstartaddr=0x81000000\0"  "loadaddr=0x80000000\0" \ 
    "initrd_high=0x0\0" \ 
    "bootsize=0x180000\0" \ 
    "bootstart=0x61C00000\0" \ 
    "boot_img=u-boot-s.bin\0" \ 
    "load_boot=tftpboot ${clobstart} ${boot_img}\0" \ 
    "update_boot=setenv img boot; setenv psize ${bootsize}; setenv installcmd \"install_boot\"; run load_boot test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_boot=protect off ${bootstart} +${bootsize} && erase ${bootstart} +${bootsize} && "  "cp.b ${clobstart} ${bootstart} ${filesize}\0" \ 
    "bootenvsize=0x20000\0" \ 
    "bootenvstart=0x61D80000\0" \ 
    "eraseenv=protect off ${bootenvstart} +${bootenvsize} && erase ${bootenvstart} +${bootenvsize}\0" \ 
    "kernelsize=0xC00000\0" \ 
    "kernelstart=0x61DA0000\0" \ 
    "kernel_img=image.ub\0" \ 
    "load_kernel=tftpboot ${clobstart} ${kernel_img}\0" \ 
    "update_kernel=setenv img kernel; setenv psize ${kernelsize}; setenv installcmd \"install_kernel\"; run load_kernel test_crc; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_kernel=protect off ${kernelstart} +${kernelsize} && erase ${kernelstart} +${kernelsize} && "  "cp.b ${clobstart} ${kernelstart} ${filesize}\0" \ 
    "cp_kernel2ram=cp.b ${kernelstart} ${netstart} ${kernelsize}\0" \ 
    "fpgasize=0x1C00000\0" \ 
    "fpgastart=0x60000000\0" \ 
    "fpga_img=system.bit.bin\0" \ 
    "load_fpga=tftpboot ${clobstart} ${fpga_img}\0" \ 
    "update_fpga=setenv img fpga; setenv psize ${fpgasize}; setenv installcmd \"install_fpga\"; run load_fpga test_img; setenv img; setenv psize; setenv installcmd\0" \ 
    "install_fpga=protect off ${fpgastart} +${fpgasize} && erase ${fpgastart} +${fpgasize} && "  "cp.b ${clobstart} ${fpgastart} ${filesize}\0" \ 
    "fault=echo ${img} image size is greater than allocated place - partition ${img} is NOT UPDATED\0" \ 
    "test_crc=if imi ${clobstart}; then run test_img; else echo ${img} Bad CRC - ${img} is NOT UPDATED; fi\0" \ 
    "test_img=setenv var \"if test ${filesize} -gt ${psize}\\; then run fault\\; else run ${installcmd}\\; fi\"; run var; setenv var\0" \ 
    "netboot=tftpboot ${netstartaddr} ${kernel_img} && bootm\0" \ 
    "default_bootcmd=bootcmd\0" \ 
  ""


