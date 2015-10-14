series7-qgige-axieth
====================

Example design for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") on ALL the Xilinx Series-7 Evaluation boards using 4 AXI Ethernet blocks

### Supported boards

* Artix-7 [AC701 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-a7-ac701-g.html "AC701 Evaluation board")
  * HPC connector (use ac701.xdc)
* Kintex-7 [KC705 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-k7-kc705-g.html "KC705 Evaluation board")
  * LPC connector (use kc705-lpc.xdc)
  * HPC connector (use kc705-hpc.xdc)
* Virtex-7 [VC707 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html "VC707 Evaluation board")
  * HPC connector 1 (use vc707-hpc1.xdc)
  * HPC connector 2 (use vc707-hpc2.xdc)
* Virtex-7 [VC709 Evaluation board](http://www.xilinx.com/products/boards-and-kits/dk-v7-vc709-g.html "VC709 Evaluation board")
  * HPC connector (use vc709.xdc)
* Zynq-7000 [ZC702 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc702-g.html "ZC702 Evaluation board")
  * LPC connector 1 (use zc702-lpc1.xdc)
  * LPC connector 2 (use zc702-lpc2.xdc)
* Zynq-7000 [ZC706 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html "ZC706 Evaluation board") (LPC only)
  * LPC connector (use zc706-lpc.xdc)

### 8-port Support (2 x Ethernet FMCs)

The only Series-7 Evaluation boards that can support two Ethernet FMCs simultaneously are the 
[KC705](http://www.xilinx.com/products/boards-and-kits/ek-k7-kc705-g.html "KC705 Evaluation board"), [ZC702](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc702-g.html "ZC702 Evaluation board") 
and [VC707](http://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html "VC707 Evaluation board").

This repository contains example designs for using 2 x Ethernet FMCs on the same carrier. They all use 8
Xilinx AXI Ethernet Subsystem IPs that are configured with FIFOs, as opposed to all the single Ethernet FMC example designs
which are configured with DMAs. For the KC705 and VC707, the reason for this is that we would need to route 8 DMAs to the DDR3 memory, each DMA having 3 ports to
map (ie. 8 x 3 = 24), however the AXI Interconnect is limited to only 16 slave ports. For the ZC702, the problem is a lack of FPGA
resources as using 8 MACs configured with DMAs requires more resources than is contained in the Zynq device of that board.

These notes provide more details on 8-port support:

* The KC705 and VC707 each have two FMC connectors that support the Ethernet FMC (use kc705-lpc-hpc.xdc and vc707-hpc2-hpc1.xdc respectively).
* The ZC702 has two FMC connectors that can support the Ethernet FMC, however note that the Zynq device on this board has limited FPGA resources
for supporting 8 x Xilinx AXI Ethernet IPs (ie. the MACs). The device has enough resources when the 8 MACs are configured with FIFOs, however there are insufficient
resources to configure them with DMAs. Alternatively, you could use a MAC that requires less resources. (use zc702-lpc2-lpc1.xdc)
* The ZC706 has two FMC connectors, but only one (the LPC) can support the Ethernet FMC (see detail below).

### Not-supported

* Zynq-7000 [ZC706 Evaluation board](http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html "ZC706 Evaluation board") (HPC)
  * HPC connector: Pins LA18_CC and LA17_CC of the HPC connector are routed to non-clock-capable pins so they cannot
  properly receive the RGMII receive clocks for ports 2 and 3 of the Ethernet FMC. The constraints file zc706-hpc.xdc is
  provided for reference, however it will not pass compilation with the Xilinx tools due to this problem.

### Description

This project demonstrates the use of the Opsero [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC").
The design contains 4 AXI Ethernet blocks configured with DMAs.

![Block diagram](http://ethernetfmc.com/wp-content/uploads/2014/10/qgige_all_axi_ethernet.png "Zynq Quad Gig Ethernet All AXI Ethernet")

> Note: Zynq PS block is replaced by MicroBlaze processor for the Artix, Kintex and Virtex boards.

### Requirements

* Vivado 2015.3 (see Library modifications below)
* [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
* One of the above listed evaluation boards
* [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

### Library modifications for Vivado 2015.3

To use this project, some modifications must be made to the lwIP libraries
provided by the Xilinx SDK. These modifications can be made either to the
BSP code of your SDK workspace, or to the SDK sources. I personally
recommend modifying the SDK sources as every rebuild of the BSP results
in the BSP sources being overwritten with the SDK sources.

#### Modification to xaxiemacif_dma.c 

Open the following file:

`C:\Xilinx\SDK\2015.3\data\embeddedsw\ThirdParty\sw_services\lwip141_v1_2\src\contrib\ports\xilinx\netif\xaxiemacif_dma.c`

Replace this line of code:

`dmaconfig = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);`

With this one:

`dmaconfig = XAxiDma_LookupConfig(xemac->topology_index);`

#### Modification to xaxiemacif_physpeed.c

Open the following file:

`C:\Xilinx\SDK\2015.3\data\embeddedsw\ThirdParty\sw_services\lwip141_v1_2\src\contrib\ports\xilinx\netif\xaxiemacif_physpeed.c`

Add the following define statement to the code:

`#define MARVEL_PHY_88E1510_MODEL 0x1D0`

That defines the PHY model identifier for the Marvell 88E1510 PHYs that are
found on the Ethernet FMC.

Add the following function code just above the function called `get_IEEE_phy_speed`:

```c
unsigned int get_phy_speed_88E1510(XAxiEthernet *xaxiemacp, u32 phy_addr)
{
	u16 temp;
	u16 phy_identifier;
	u16 phy_model;
	u16 control;
	u16 status;
	u16 partner_capabilities;

	/* Get the PHY Identifier and Model number */
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, 2, &phy_identifier);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, 3, &phy_model);
	phy_model = phy_model & PHY_MODEL_NUM_MASK;

	xil_printf("Start PHY autonegotiation \r\n");

	XAxiEthernet_PhyWrite(xaxiemacp,phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 2);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_MAC, &control);
	//control |= IEEE_RGMII_TXRX_CLOCK_DELAYED_MASK;
	control &= ~(0x10);
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_MAC, control);

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 0);

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_AUTONEGO_ADVERTISE_REG, &control);
	control |= IEEE_ASYMMETRIC_PAUSE_MASK;
	control |= IEEE_PAUSE_MASK;
	control |= ADVERTISE_100;
	control |= ADVERTISE_10;
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_AUTONEGO_ADVERTISE_REG, control);

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_1000_ADVERTISE_REG_OFFSET,
																	&control);
	control |= ADVERTISE_1000;
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_1000_ADVERTISE_REG_OFFSET,
																	control);

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 0);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_COPPER_SPECIFIC_CONTROL_REG,
																&control);
	control |= (7 << 12);	/* max number of gigabit attempts */
	control |= (1 << 11);	/* enable downshift */
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_COPPER_SPECIFIC_CONTROL_REG,
																control);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
	control |= IEEE_CTRL_AUTONEGOTIATE_ENABLE;
	control |= IEEE_STAT_AUTONEGOTIATE_RESTART;

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, control);

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
	control |= IEEE_CTRL_RESET_MASK;
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, control);

	while (1) {
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
		if (control & IEEE_CTRL_RESET_MASK)
			continue;
		else
			break;
	}
	xil_printf("Waiting for PHY to complete autonegotiation.\r\n");

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_STATUS_REG_OFFSET, &status);
	while ( !(status & IEEE_STAT_AUTONEGOTIATE_COMPLETE) ) {
		sleep(1);
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_COPPER_SPECIFIC_STATUS_REG_2,
																	&temp);
		if (temp & IEEE_AUTONEG_ERROR_MASK) {
			xil_printf("Auto negotiation error \r\n");
		}
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_STATUS_REG_OFFSET,
																&status);
		}

	xil_printf("autonegotiation complete \r\n");

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_SPECIFIC_STATUS_REG, &partner_capabilities);

	if ( ((partner_capabilities >> 14) & 3) == 2)/* 1000Mbps */
		return 1000;
	else if ( ((partner_capabilities >> 14) & 3) == 1)/* 100Mbps */
		return 100;
	else					/* 10Mbps */
		return 10;
}
```

That is a custom function that communicates with the 88E1510 PHY to determine the autonegotiated link speed.

Now find this block of code:

```c
	if (phy_identifier == MARVEL_PHY_IDENTIFIER) {
		if (phy_model == MARVEL_PHY_88E1116R_MODEL) {
			return get_phy_speed_88E1116R(xaxiemacp, phy_addr);
		} else if (phy_model == MARVEL_PHY_88E1111_MODEL) {
			return get_phy_speed_88E1111(xaxiemacp, phy_addr);
		}
	}
```

and replace it with this block of code:

```c
	if (phy_identifier == MARVEL_PHY_IDENTIFIER) {
		if (phy_model == MARVEL_PHY_88E1116R_MODEL) {
			return get_phy_speed_88E1116R(xaxiemacp, phy_addr);
		} else if (phy_model == MARVEL_PHY_88E1111_MODEL) {
			return get_phy_speed_88E1111(xaxiemacp, phy_addr);
		} else if (phy_model == MARVEL_PHY_88E1510_MODEL) {
			return get_phy_speed_88E1510(xaxiemacp, phy_addr);
		}
	}
```

We have just added an extra else-if statement to call our custom PHY speed function added earlier.

### For more information

If you need more information on whether the Ethernet FMC is compatible with your carrier, please contact me [here](http://ethernetfmc.com/contact/ "Ethernet FMC Contact form").
Just provide me with the pinout of your carrier and I'll be happy to check compatibility and generate a Vivado constraints file for you.

### License

Feel free to modify the code for your specific application.

### Fork and share

If you port this project to another hardware platform, please send me the
code or push it onto GitHub and send me the link so I can post it on my
website. The more people that benefit, the better.

### About the author

I'm an FPGA consultant and I provide FPGA design services to innovative
companies around the world. I believe in sharing knowledge and
I regularly contribute to the open source community.

Jeff Johnson
[FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer")