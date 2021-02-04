PetaLinux Project source files
==============================

### How to build the PetaLinux projects

#### Requirements

* Windows or Linux PC with Vivado installed
* Linux PC or virtual machine with PetaLinux installed

#### Instructions

In order to make use of these source files, you must:

1. First generate the Vivado project hardware design(s) (the bitstream) and export the design(s) to SDK.
2. Launch PetaLinux by sourcing the `settings.sh` bash script, eg: `source <path-to-installed-petalinux>/settings.sh`
3. Build the PetaLinux project(s) by executing the `build-petalinux` script in Linux.

The script will generate a separate PetaLinux project for all of the generated and exported Vivado projects that
it finds in the Vivado directory of this repo.

### UNIX line endings

The scripts and files in the PetaLinux directory of this repository must have UNIX line endings when they are
executed or used under Linux. The best way to ensure UNIX line endings, is to clone the repo directly onto your
Linux machine. If instead you have copied the repo from a Windows machine, the files will have DOS line endings and
you must use the `dos2unix` tool to convert the line endings for UNIX.

1. Copy the cloned repository from your Windows machine to your Linux machine.
2. Use the `cd` command to navigate to the copied repository on your Linux machine.
3. Type `find . -type f -exec dos2unix --keepdate {} +` to convert all of the files
to the Unix format.

### How the script works

The PetaLinux directory contains a `build-petalinux` shell script which can be run in Linux to automatically
generate a PetaLinux project for each of the generated/exported Vivado projects in the Vivado directory.

When executed, the build script searches the Vivado directory for all projects containing a `.xsa` exported
hardware design file. Then for every exported project, the script does the following:

1. Verifies that the `.bit` file exists.
2. Determines the CPU type: Zynq, ZynqMP or Microblaze. It does this
by reading the Vivado project file.
3. Creates a PetaLinux project, referencing the exported hardware design (.xsa).
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

All designs will try to automatically configure the eth0 device on boot, so it can be
useful to connect the eth0 device to a DHCP router before the hardware is powered-up.
Note that on Zynq and ZynqMP designs, the eth0 device is connected to the development board's
Ethernet port and not the Ethernet FMC.

#### AC701, KC705

* eth0: Ethernet port of the dev board
* eth1: Ethernet FMC Port 0
* eth2: Ethernet FMC Port 1
* eth3: Ethernet FMC Port 2
* eth4: Ethernet FMC Port 3

#### KCU105 HPC, VC707, VC709

* eth0: Ethernet FMC Port 0
* eth1: Ethernet FMC Port 1
* eth2: Ethernet FMC Port 2
* eth3: Ethernet FMC Port 3

#### KCU105 LPC

* eth0: Ethernet FMC Port 0
* eth1: Ethernet FMC Port 1
* eth2: Ethernet FMC Port 3

Ethernet FMC Port 2 is unusable in this design.

#### MicroZed, PicoZed, ZC702, ZC706, ZedBoard, ZCU102

* eth0: GEM0 to Ethernet port of the dev board
* eth1: Ethernet FMC Port 0
* eth2: Ethernet FMC Port 1
* eth3: Ethernet FMC Port 2
* eth4: Ethernet FMC Port 3

#### KCU105 Dual design

* eth0: HPC Ethernet FMC Port 0 (AXI Ethernet)
* eth1: HPC Ethernet FMC Port 1 (AXI Ethernet)
* eth2: HPC Ethernet FMC Port 2 (AXI Ethernet)
* eth3: HPC Ethernet FMC Port 3 (AXI Ethernet)
* eth4: LPC Ethernet FMC Port 0 (AXI Ethernet)
* eth5: LPC Ethernet FMC Port 1 (AXI Ethernet)
* eth6: LPC Ethernet FMC Port 3 (AXI Ethernet)

Ethernet FMC Port 2 on the LPC is unusable in this design.

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

Note that the ZC702 dual design will not produce a working PetaLinux project because it's Ethernet
MACs are connected to FIFOs and not AXI DMAs. We are working on a solution to this.

### AXI Ethernet issue on Zynq designs 2020.2

There is an issue in the PetaLinux 2020.2 release that affects the **AXI Ethernet** connected ports on
**Zynq** based designs. On these ports, it seems to be necessary to use the following procedure to bring 
up a port. Note that the interface and IP address were chosen as examples, but this procedure applies to 
all AXI Ethernet connected ports (eth0, eth1, eth2 and eth3) on the Zynq based designs (MicroZed, PicoZed, 
ZedBoard, ZC702 and ZC706).
```
ifconfig eth0 up
ifconfig eth0 down
ifconfig eth0 192.168.1.10 up
```
In earlier releases, it was only necessary to run the last command to bring up a port. This issue
does not affect the Zynq Ultrascale+ based designs. We have not yet determined the cause of this issue
but if you have any information, please let us know.

