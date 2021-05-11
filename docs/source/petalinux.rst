=========
PetaLinux
=========

PetaLinux can be built for these reference designs by using the script in the ``PetaLinux`` directory
of the repository.

How to build
============

Requirements
------------

* Windows or Linux PC with Vivado installed
* Linux PC or virtual machine with PetaLinux installed

Instructions
------------

1. First generate the Vivado project hardware design(s) (the bitstream) and export the design(s).
2. Launch PetaLinux by sourcing the ``settings.sh`` bash script, eg: ``source <path-to-installed-petalinux>/settings.sh``
3. Build the PetaLinux project(s) by executing the ``build-petalinux`` script in Linux.

The script will generate a separate PetaLinux project for all of the generated and exported Vivado projects that
it finds in the Vivado directory of this repo.

UNIX line endings
=================

The scripts and files in the PetaLinux directory of this repository must have UNIX line endings when they are
executed or used under Linux. The best way to ensure UNIX line endings, is to clone the repo directly onto your
Linux machine. If instead you have copied the repo from a Windows machine, the files will have DOS line endings and
you must use the ``dos2unix`` tool to convert the line endings for UNIX.

#. Copy the cloned repository from your Windows machine to your Linux machine.
#. Use the ``cd`` command to navigate to the copied repository on your Linux machine.
#. Type ``find . -type f -exec dos2unix --keepdate {} +`` to convert all of the files
   to the Unix format.

How the script works
====================

The PetaLinux directory contains a ``build-petalinux`` shell script which can be run in Linux to automatically
generate a PetaLinux project for each of the generated/exported Vivado projects in the Vivado directory.

When executed, the build script searches the Vivado directory for all projects containing a ``.xsa`` exported
hardware design file. Then for every exported project, the script does the following:

#. Verifies that the ``.bit`` file exists.
#. Determines the CPU type: Zynq, ZynqMP or Microblaze. It does this
   by reading the Vivado project file.
#. Creates a PetaLinux project, referencing the exported hardware design (.xsa).
#. Copies the relevant configuration files from the ``src`` directory into the created
   PetaLinux project.
#. Builds the PetaLinux project.
#. Generates a BOOT.BIN, boot.scr and image.ub file for the Zynq and ZynqMP projects.

Launch PetaLinux on hardware
============================

Via JTAG
--------

To launch the PetaLinux project on hardware via JTAG, connect and power up your hardware and then
use the following commands in a Linux command terminal:

#. Change current directory to the PetaLinux project directory:
   ``cd <petalinux-project-dir>``
#. Download bitstream to the FPGA:
   ``petalinux-boot --jtag --fpga``
   Note that you don't have to specify the bitstream because this command will use the one that it finds
   in the ``./images/linux`` directory.
#. Download the PetaLinux kernel to the FPGA:
   ``petalinux-boot --jtag --kernel``

Via SD card (Zynq/ZynqMP)
-------------------------

To launch the PetaLinux project on hardware via SD card, copy the following files to the root of the
SD card:

* ``/<petalinux-project>/images/linux/BOOT.bin``
* ``/<petalinux-project>/images/linux/image.ub``

Then connect and power your hardware.

Configuration files
===================

The configuration files contained in the `src` directory include:

* Device tree
* Rootfs configuration (to include ethtool)
* Interface initializations (sets eth0-3 interfaces to DHCP)
* Kernel configuration

Port configurations
===================

All designs will try to automatically configure the eth0 device on boot, so it can be
useful to connect the eth0 device to a DHCP router before the hardware is powered-up.
Note that on Zynq and ZynqMP designs, the eth0 device is connected to the development board's
Ethernet port and not the Ethernet FMC.

AC701, KC705
------------

* eth0: Ethernet port of the dev board
* eth1: Ethernet FMC Port 0
* eth2: Ethernet FMC Port 1
* eth3: Ethernet FMC Port 2
* eth4: Ethernet FMC Port 3

KCU105 HPC, VC707, VC709
------------------------

* eth0: Ethernet FMC Port 0
* eth1: Ethernet FMC Port 1
* eth2: Ethernet FMC Port 2
* eth3: Ethernet FMC Port 3

KCU105 LPC
----------

* eth0: Ethernet FMC Port 0
* eth1: Ethernet FMC Port 1
* eth2: Ethernet FMC Port 3

Ethernet FMC Port 2 is unusable in this design.

MicroZed, PicoZed, ZC702, ZC706, ZedBoard, ZCU102, UltraZed-EV
--------------------------------------------------------------

* eth0: GEM0 to Ethernet port of the dev board
* eth1: Ethernet FMC Port 0
* eth2: Ethernet FMC Port 1
* eth3: Ethernet FMC Port 2
* eth4: Ethernet FMC Port 3

KCU105 Dual design
------------------

* eth0: HPC Ethernet FMC Port 0 (AXI Ethernet)
* eth1: HPC Ethernet FMC Port 1 (AXI Ethernet)
* eth2: HPC Ethernet FMC Port 2 (AXI Ethernet)
* eth3: HPC Ethernet FMC Port 3 (AXI Ethernet)
* eth4: LPC Ethernet FMC Port 0 (AXI Ethernet)
* eth5: LPC Ethernet FMC Port 1 (AXI Ethernet)
* eth6: LPC Ethernet FMC Port 3 (AXI Ethernet)

Ethernet FMC Port 2 on the LPC is unusable in this design.

VC707 Dual design
-----------------

* eth0: HPC2 Ethernet FMC Port 0 (AXI Ethernet)
* eth1: HPC2 Ethernet FMC Port 1 (AXI Ethernet)
* eth2: HPC2 Ethernet FMC Port 2 (AXI Ethernet)
* eth3: HPC2 Ethernet FMC Port 3 (AXI Ethernet)
* eth4: HPC1 Ethernet FMC Port 0 (AXI Ethernet)
* eth5: HPC1 Ethernet FMC Port 1 (AXI Ethernet)
* eth6: HPC1 Ethernet FMC Port 2 (AXI Ethernet)
* eth7: HPC1 Ethernet FMC Port 3 (AXI Ethernet)

ZC702 Dual design
-----------------

Note that the ZC702 dual design will not produce a working PetaLinux project because it's Ethernet
MACs are connected to FIFOs and not AXI DMAs. We are working on a solution to this.

Example Usage
=============

Enable port
-----------

This example will bring up a port.

.. code-block::

   root@axieth:~# ifconfig eth1 up
   [  228.274146] xilinx_axienet a0000000.ethernet eth1: Link is Up - 1Gbps/Full - flow control off
   [  228.282753] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready

Enable port with fixed IP address
---------------------------------

This example sets a fixed IP address to a port.

.. code-block::

   root@axieth:~# ifconfig eth1 192.168.2.30 up
   [  390.080498] net eth1: Promiscuous mode disabled.
   [  390.085406] net eth1: Promiscuous mode disabled.
   [  390.091089] xilinx_axienet a0000000.ethernet eth1: Link is Down
   [  394.175238] xilinx_axienet a0000000.ethernet eth1: Link is Up - 1Gbps/Full - flow control off
   [  394.183769] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready

Enable port using DHCP
----------------------

This example enables a port and obtains an IP address for the port via DHCP. Note that the
port must be connected to a DHCP enabled router.

.. code-block::

   root@axieth:~# udhcpc -i eth1
   udhcpc: started, v1.31.0
   [   68.814013] xilinx_axienet a0000000.ethernet eth1: Link is Up - 1Gbps/Full - flow control off
   [   68.822670] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
   udhcpc: sending discover
   udhcpc: sending select for 192.168.2.23
   udhcpc: lease of 192.168.2.23 obtained, lease time 259200
   /etc/udhcpc.d/50default: Adding DNS 192.168.2.1

Check port status
-----------------

In this example, we use the ``ifconfig`` command with no arguments to check the port status.
The first interface (eth0) shown below is connected to the on-board Ethernet port and it has not been
enabled, whereas the second interface (eth1) is connected to the Ethernet FMC port 0 and it has
been enabled and configured with IP address 192.168.2.30.

.. code-block::

   root@axieth:~# ifconfig
   eth0      Link encap:Ethernet  HWaddr 00:0A:35:00:22:01
             UP BROADCAST MULTICAST  MTU:1500  Metric:1
             RX packets:0 errors:0 dropped:0 overruns:0 frame:0
             TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
             collisions:0 txqueuelen:1000
             RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
             Interrupt:30
   
   eth1      Link encap:Ethernet  HWaddr 00:0A:35:00:01:22
             inet addr:192.168.2.30  Bcast:192.168.2.255  Mask:255.255.255.0
             inet6 addr: fe80::20a:35ff:fe00:122/64 Scope:Link
             UP BROADCAST RUNNING  MTU:1500  Metric:1
             RX packets:38 errors:0 dropped:0 overruns:0 frame:0
             TX packets:26 errors:0 dropped:0 overruns:0 carrier:0
             collisions:0 txqueuelen:1000
             RX bytes:6033 (5.8 KiB)  TX bytes:3302 (3.2 KiB)
   
   lo        Link encap:Local Loopback
             inet addr:127.0.0.1  Mask:255.0.0.0
             inet6 addr: ::1/128 Scope:Host
             UP LOOPBACK RUNNING  MTU:65536  Metric:1
             RX packets:0 errors:0 dropped:0 overruns:0 frame:0
             TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
             collisions:0 txqueuelen:1000
             RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

We can also use ``ethtool`` to check the port status as follows.

.. code-block::

   root@axieth:~# ethtool eth1
   Settings for eth1:
           Supported ports: [ TP MII FIBRE ]
           Supported link modes:   10baseT/Half 10baseT/Full
                                   100baseT/Half 100baseT/Full
                                   1000baseT/Half 1000baseT/Full
           Supported pause frame use: Symmetric Receive-only
           Supports auto-negotiation: Yes
           Supported FEC modes: Not reported
           Advertised link modes:  10baseT/Half 10baseT/Full
                                   100baseT/Half 100baseT/Full
                                   1000baseT/Half 1000baseT/Full
           Advertised pause frame use: No
           Advertised auto-negotiation: Yes
           Advertised FEC modes: Not reported
           Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                                100baseT/Half 100baseT/Full
                                                1000baseT/Full
           Link partner advertised pause frame use: No
           Link partner advertised auto-negotiation: Yes
           Link partner advertised FEC modes: Not reported
           Speed: 1000Mb/s
           Duplex: Full
           Port: MII
           PHYAD: 0
           Transceiver: internal
           Auto-negotiation: on
           Link detected: yes

Ping link partner using specific port
-------------------------------------

In this example we ping the link partner at IP address 192.168.2.10 from interface eth1.

.. code-block::

   root@axieth:~# ping -I eth1 192.168.2.10
   PING 192.168.2.10 (192.168.2.10): 56 data bytes
   64 bytes from 192.168.2.10: seq=0 ttl=128 time=0.545 ms
   64 bytes from 192.168.2.10: seq=1 ttl=128 time=0.455 ms
   64 bytes from 192.168.2.10: seq=2 ttl=128 time=0.380 ms
   64 bytes from 192.168.2.10: seq=3 ttl=128 time=0.356 ms

Known Issues
============

AXI Ethernet issue on Zynq designs 2020.2
-----------------------------------------

There is an issue in the PetaLinux 2020.2 release that affects the **AXI Ethernet** connected ports on
**Zynq** based designs. On these ports, it seems to be necessary to use the following procedure to bring 
up a port. Note that the interface and IP address were chosen as examples, but this procedure applies to 
all AXI Ethernet connected ports (eth0, eth1, eth2 and eth3) on the Zynq based designs (MicroZed, PicoZed, 
ZedBoard, ZC702 and ZC706).

.. code-block::

  ifconfig eth0 up
  ifconfig eth0 down
  ifconfig eth0 192.168.1.10 up

In earlier releases, it was only necessary to run the last command to bring up a port. This issue
does not affect the Zynq Ultrascale+ based designs. This issue does not seem to affect the stand-alone
echo server operation. We have not yet determined the cause of this issue
but if you have any information, please let us know.

