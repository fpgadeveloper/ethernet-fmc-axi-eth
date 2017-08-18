PetaLinux Project source files
==============================

### How to build the PetaLinux projects

In order to make use of these source files, you must:

1. First generate the Vivado project hardware design(s) (the bitstream) and export the design(s) to SDK.
2. Launch PetaLinux by sourcing the `settings.sh` bash script, eg: `source <path-to-installed-petalinux>/settings.sh`
3. Build the PetaLinux project(s) by executing the `build-petalinux` script in Linux.

The script will generate a separate PetaLinux project for all of the generated and exported Vivado projects that
it finds in the Vivado directory of this repo.

### How the script works

The PetaLinux directory contains a `build-petalinux` shell script which can be run in Linux to automatically
generate a PetaLinux project for each of the generated/exported Vivado projects in the Vivado directory.

When executed, the build script searches the Vivado directory for all projects containing `*.sdk` sub-directories.
This locates all projects that have been exported to SDK. Then for every exported project, the script
does the following:

1. Verifies that the `.hdf` and the `.bit` files exist.
2. Determines the CPU type: Zynq or ZynqMP. It currently does this
by looking at the first 3 letters of the project name.
3. Creates a PetaLinux project, referencing the exported hardware design (.hdf).
4. Copies the relevant configuration files from the `src` directory into the created
PetaLinux project.
5. Builds the PetaLinux project.
6. Generates a BOOT.bin and image.ub file for the Zynq and ZynqMP projects.

### Launch PetaLinux on hardware

#### Via JTAG

To launch the PetaLinux project on hardware via JTAG, connect and power up your hardware and then
use the following commands in a Linux command terminal:

1. Change current directory to the PetaLinux project directory:
`cd <petalinux-project-dir>`
2. Download bitstream to the FPGA:
`petalinux-boot --jtag --fpga`
Note that you don't have to specify the bitstream because this command will use the one that it finds
in the `./images/linux` directory.
3. Download the PetaLinux kernel to the FPGA:
`petalinux-boot --jtag --kernel`

#### Via SD card (Zynq)

To launch the PetaLinux project on hardware via SD card, copy the following files to the root of the
SD card:

* `/<petalinux-project>/images/linux/BOOT.bin`
* `/<petalinux-project>/images/linux/image.ub`

Then connect and power your hardware.

### Configuration files

The configuration files contained in the `src` directory include:

* Device tree
* Rootfs configuration (to include ethtool)
* Interface initializations (sets eth0-3 interfaces to DHCP)
* Kernel configuration
* AXI Ethernet driver patch

#### AXI Ethernet driver patch

The AXI Ethernet driver requires a patch for the correct configuration of the RGMII interface's 
RX and TX clock skews.

https://github.com/Xilinx/linux-xlnx/blob/master/drivers/net/ethernet/xilinx/xilinx_axienet_main.c

```		} else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
			phydev = of_phy_connect(lp->ndev, lp->phy_node,
						axienet_adjust_link, 0,
						PHY_INTERFACE_MODE_RGMII_ID);
```

The section of the code shown above specifies `PHY_INTERFACE_MODE_RGMII_ID` as the RGMII interface
mode (aka "rgmii-id"). That interface mode enables both the RX and TX clock delays in the PHY but in 
fact we need to enable only the RX delay 
(see http://ethernetfmc.com/rgmii-interface-timing-considerations/ for more information).

Our device tree specifies the correct RGMII configuration with the phy-mode setting ("rgmii-rxid"),
and we have access to this setting via the `lp->phy_interface` variable. So to correct the issue, we
replace the above code with the following:

```		} else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
			phydev = of_phy_connect(lp->ndev, lp->phy_node,
						axienet_adjust_link, 0,
						lp->phy_interface);
```

The included patch handles this modification - you do not need to manually modify any code.

### Port configurations

#### AC701, KC705, KCU105, VC707, VC709

* eth0: Ethernet FMC Port 0
* eth1: Ethernet FMC Port 1
* eth2: Ethernet FMC Port 2
* eth3: Ethernet FMC Port 3

#### MicroZed, PicoZed, ZC702, ZC706, ZCU102, ZedBoard

* eth0: GEM0 to Ethernet port of the dev board
* eth1: Ethernet FMC Port 0
* eth2: Ethernet FMC Port 1
* eth3: Ethernet FMC Port 2
* eth4: Ethernet FMC Port 3

#### VC707 Dual design

* eth0: HPC2 Ethernet FMC Port 0 (AXI Ethernet)
* eth1: HPC2 Ethernet FMC Port 1 (AXI Ethernet)
* eth2: HPC2 Ethernet FMC Port 2 (AXI Ethernet)
* eth3: HPC2 Ethernet FMC Port 3 (AXI Ethernet)
* eth4: HPC1 Ethernet FMC Port 0 (AXI Ethernet)
* eth5: HPC1 Ethernet FMC Port 1 (AXI Ethernet)
* eth6: HPC1 Ethernet FMC Port 2 (AXI Ethernet)
* eth7: HPC1 Ethernet FMC Port 3 (AXI Ethernet)

#### ZC702 Dual design

* eth0: Ethernet port of the dev board (GEM0)
* eth1: LPC2 Ethernet FMC Port 0 (AXI Ethernet)
* eth2: LPC2 Ethernet FMC Port 1 (AXI Ethernet)
* eth3: LPC2 Ethernet FMC Port 2 (AXI Ethernet)
* eth4: LPC2 Ethernet FMC Port 3 (AXI Ethernet)
* eth5: LPC1 Ethernet FMC Port 0 (AXI Ethernet)
* eth6: LPC1 Ethernet FMC Port 1 (AXI Ethernet)
* eth7: LPC1 Ethernet FMC Port 2 (AXI Ethernet)
* eth8: LPC1 Ethernet FMC Port 3 (AXI Ethernet)

