Working port arrangements for the PicoZed 7010 design
=====================================================

It's difficult to get 4 soft Ethernet MACs to fit into the 7z010 device, and the only way that I've found to achieve it
is to use 3x AXI Ethernet IPs with FIFOs (rather than DMAs) and 1x GMII-to-RGMII core hooked up to one of the GEMs.
Furthermore, not all configurations of the AXI Ethernet/GMII-to-RGMII will pass timing, hence the reason for these
notes.

There are two ports per bank and there must be one IDELAYCTRL per bank, which is why we have
to split the ports into two IODELAY groups indexed 0 and 1.

The current working arrangement is:

Port 0: AXI Ethernet without shared logic, IODELAY_GROUP 0
Port 1: AXI Ethernet with shared logic included (IDELAYCTRL), IODELAY_GROUP 0
Port 2: AXI Ethernet without shared logic, IODELAY_GROUP 1
Port 3: GMII-to-RGMII with shared logic (IDELAYCTRL), IODELAY_GROUP 1

If you are trying to add more IP to this design and you run into timing problems, you can try rearranging the ports
using one of the following setups which currently pass timing:

Port 0: AXI Ethernet with shared logic included (IDELAYCTRL), IODELAY_GROUP 0
Port 1: AXI Ethernet without shared logic, IODELAY_GROUP 0
Port 2: GMII-to-RGMII with shared logic (IDELAYCTRL), IODELAY_GROUP 1
Port 3: AXI Ethernet without shared logic, IODELAY_GROUP 1

Port 0: AXI Ethernet without shared logic, IODELAY_GROUP 0
Port 1: AXI Ethernet with shared logic included (IDELAYCTRL), IODELAY_GROUP 0
Port 2: GMII-to-RGMII with shared logic (IDELAYCTRL), IODELAY_GROUP 1
Port 3: AXI Ethernet without shared logic, IODELAY_GROUP 1

Port 0: AXI Ethernet without shared logic, IODELAY_GROUP 0
Port 1: GMII-to-RGMII with shared logic (IDELAYCTRL), IODELAY_GROUP 0
Port 2: AXI Ethernet with shared logic included (IDELAYCTRL), IODELAY_GROUP 1
Port 3: AXI Ethernet without shared logic, IODELAY_GROUP 1

Port 0: GMII-to-RGMII with shared logic (IDELAYCTRL), IODELAY_GROUP 1
Port 1: AXI Ethernet without shared logic, IODELAY_GROUP 1
Port 2: AXI Ethernet with shared logic included (IDELAYCTRL), IODELAY_GROUP 0
Port 3: AXI Ethernet without shared logic, IODELAY_GROUP 0

Port 0: AXI Ethernet without shared logic, IODELAY_GROUP 0
Port 1: AXI Ethernet with shared logic included (IDELAYCTRL), IODELAY_GROUP 0
Port 2: GMII-to-RGMII with shared logic (IDELAYCTRL), IODELAY_GROUP 1
Port 3: AXI Ethernet without shared logic, IODELAY_GROUP 1

The following two configurations don't pass timing, so they're not worth considering:

Port 0: AXI Ethernet with shared logic included (IDELAYCTRL), IODELAY_GROUP 0
Port 1: AXI Ethernet without shared logic, IODELAY_GROUP 0
Port 2: AXI Ethernet without shared logic, IODELAY_GROUP 1
Port 3: GMII-to-RGMII with shared logic (IDELAYCTRL), IODELAY_GROUP 1

Port 0: AXI Ethernet without shared logic, IODELAY_GROUP 0
Port 1: GMII-to-RGMII with shared logic (IDELAYCTRL), IODELAY_GROUP 0
Port 2: AXI Ethernet without shared logic, IODELAY_GROUP 1
Port 3: AXI Ethernet with shared logic included (IDELAYCTRL), IODELAY_GROUP 1

Jeff Johnson
http://fpgadeveloper.com
