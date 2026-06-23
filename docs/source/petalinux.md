# PetaLinux

PetaLinux can be built for these reference designs with the cross-platform `build.py`
runner at the root of the repository.

## Requirements

To build the PetaLinux projects, you will need a physical or virtual machine running one of the 
[supported Linux distributions], with PetaLinux 2025.2 and Vivado 2025.2 installed.

```{attention}
You cannot build the PetaLinux projects in the Windows operating system. Windows
users are advised to use a Linux virtual machine to build the PetaLinux projects.
```

## How to build

The build runner locates and sources the PetaLinux and Vivado settings itself, so there
is no need to source them by hand. See the [build instructions](build_instructions) for
the full description of the runner.

1. From a command terminal, clone the Git repository (with its submodules) and `cd` into it:
   ```
   git clone --recurse-submodules https://github.com/fpgadeveloper/ethernet-fmc-axi-eth.git
   cd ethernet-fmc-axi-eth
   ```
2. Build the PetaLinux image for your target by running the following command and replacing
   `<target>` with one of the target design labels found in the build instructions:
   ```
   ./build.sh petalinux --target <target>
   ```

This will also launch the build process for the corresponding Vivado project if that project
has not already been built and its hardware exported.

## Boot from SD card

### Prepare the SD card

Once the build process is complete, you must prepare the SD card for booting PetaLinux.

1. The SD card must first be prepared with two partitions: one for the boot files and another 
   for the root file system.

   * Plug the SD card into your computer and find it's device name using the `dmesg` command.
     The SD card should be found at the end of the log, and it's device name should be something
     like `/dev/sdX`, where `X` is a letter such as a,b,c,d, etc. Note that you should replace
     the `X` in the following instructions.
     
```{warning}
Do not continue these steps until you are certain that you have found the correct
device name for the SD card. If you use the wrong device name in the following steps, you risk
losing data on one of your hard drives.
```
   * Run `fdisk` by typing the command `sudo fdisk /dev/sdX`
   * Make the `boot` partition: typing `n` to create a new partition, then type `p` to make 
     it primary, then use the default partition number and first sector. For the last sector, type 
     `+1G` to allocate 1GB to this partition.
   * Make the `boot` partition bootable by typing `a`
   * Make the `root` partition: typing `n` to create a new partition, then type `p` to make 
     it primary, then use the default partition number, first sector and last sector.
   * Save the partition table by typing `w`
   * Format the `boot` partition (FAT32) by typing `sudo mkfs.vfat -F 32 -n boot /dev/sdX1`
   * Format the `root` partition (ext4) by typing `sudo mkfs.ext4 -L root /dev/sdX2`

2. Copy the following files to the `boot` partition of the SD card:
   Assuming the `boot` partition was mounted to `/media/user/boot`, follow these instructions:
   ```
   $ cd /media/user/boot/
   $ sudo cp /<petalinux-project>/images/linux/BOOT.BIN .
   $ sudo cp /<petalinux-project>/images/linux/boot.scr .
   $ sudo cp /<petalinux-project>/images/linux/image.ub .
   ```

3. Create the root file system by extracting the `rootfs.tar.gz` file to the `root` partition.
   Assuming the `root` partition was mounted to `/media/user/root`, follow these instructions:
   ```
   $ cd /media/user/root/
   $ sudo cp /<petalinux-project>/images/linux/rootfs.tar.gz .
   $ sudo tar xvf rootfs.tar.gz -C .
   $ sync
   ```
   
   Once the `sync` command returns, you will be able to eject the SD card from the machine.

### Boot PetaLinux

1. Plug the SD card into your target board.
2. Ensure that the target board is configured to boot from SD card:
   * **PicoZed:** DIP switch SW1 (on the SoM) is set to 11 (1=ON,2=ON)
   * **ZC702:** DIP switch SW16 must be set to 00110 (1=OFF,2=OFF,3=ON,4=ON,5=OFF)
   * **ZC706:** DIP switch SW11 must be set to 00110 (1=OFF,2=OFF,3=ON,4=ON,5=OFF)
   * **UltraZed-EV:** DIP switch SW2 (on the SoM) is set to 1000 (1=ON,2=OFF,3=OFF,4=OFF).
     The UZ-EV BSP routes the boot SD interface through PSU SD1, so use the carrier's SD1 slot.
   * **ZCU102:** DIP switch SW6 must be set to 1000 (1=ON,2=OFF,3=OFF,4=OFF)
   * **ZedBoard:** Jumpers MIO6-2 must be set to 01100
3. Connect the [Ethernet FMC] to the FMC connector of the target board.
4. Connect the USB-UART to your PC and then open a UART terminal set to 115200 baud and the 
   comport that corresponds to your target board.
5. Connect and power your hardware.

## Boot via JTAG

```{tip}
You need to install the cable drivers before being able to boot via JTAG.
Note that the Vitis installer does not automatically install the cable drivers, it must be done separately.
For instructions, read section 
[installing the cable drivers](https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Installing-Cable-Drivers) 
from the Vivado release notes.
```

```{warning}
When booting the Zynq-7000 or Zynq UltraScale+ PetaLinux designs via JTAG, you
must still first prepare the SD card. These designs are configured to mount the root
filesystem from the SD card, so booting via JTAG without an SD card prepared and inserted
will hang at a message similar to: `Waiting for root device /dev/mmcblk0p2...`
```

### Setup hardware

1. Prepare the SD card according to the [instructions above](#prepare-the-sd-card) and plug the SD card 
   into your target board.
2. Ensure that the target board is configured to boot from JTAG. Only the Zynq-7000
   and Zynq UltraScale+ targets in this repository have a PetaLinux build; MicroBlaze
   targets are baremetal-only.
   * **PicoZed:** DIP switch SW1 (on the SoM) is set to 00 (1=OFF,2=OFF)
   * **ZC702:** DIP switch SW16 must be set to 00000 (1=OFF,2=OFF,3=OFF,4=OFF,5=OFF)
   * **ZC706:** DIP switch SW11 must be set to 00000 (1=OFF,2=OFF,3=OFF,4=OFF,5=OFF)
   * **UltraZed-EV:** DIP switch SW2 (on the SoM) is set to 1111 (1=ON,2=ON,3=ON,4=ON)
   * **ZCU102:** DIP switch SW6 must be set to 1111 (1=ON,2=ON,3=ON,4=ON)
   * **ZedBoard:** Jumpers MIO6-2 must be set to 00000
3. Connect the [Ethernet FMC] to the FMC connector of the target board.
4. Connect the USB-UART to your PC and then open a UART terminal set to 115200 baud and the 
   comport that corresponds to your target board.
5. Connect and power your hardware.

### Boot PetaLinux

To boot PetaLinux on hardware via JTAG, use the following commands in a Linux command terminal:

1. Change current directory to the PetaLinux project directory for your target design:
   ```
   cd <project-dir>/PetaLinux/<target>
   ```
2. Download bitstream to the FPGA:
   ```
   petalinux-boot --jtag --kernel --fpga
   ```

An explanation of the above command is provided by the `petalinux-boot` command:
```none
For Zynq, it will download the bitstream and FSBL to target board,
and then boot the u-boot and then the kernel on target
board.
For Zynq UltraScale+, it will download the bitstream, PMUFW and FSBL,
and then boot the kernel with help of linux-boot.elf to set kernel
start and dtb addresses.
```

## UART terminal

You will need to setup a terminal emulator to use the PetaLinux command line over the USB-UART connection.
Connect with a baud rate of 115200.

### In Windows

You will need to find the comport for the USB-UART in Windows Device Manager. As a terminal emulator, you
can use the open source and free [Putty](https://www.putty.org/).

### In Linux

In Linux, you can find the USB-UART device by running `dmesg | grep tty`. Typically, the device will be
`/dev/ttyUSB0` or it could be followed by a different number. To open a terminal emulator, you can use
the following command:

```
sudo screen /dev/ttyUSB0 115200
```

## Port configurations

PetaLinux is supported only on the Zynq-7000 and Zynq UltraScale+ targets in this
repository. All designs will try to automatically configure the dev board's GEM
port on boot via DHCP, so it can be useful to have that port connected to a DHCP
router before the hardware is powered-up.

```{note}
Interface names depend on the kernel's predictable-names policy and on the target's
processor family:

* **Zynq-7000** (`pz_*`, `zc70*`, `zedboard`) — the AXI Ethernet ports come up as
  `enx<mac>` (for example `enx000a35000122`), because the kernel renames the
  `eth<N>` interfaces using the MAC address baked into each AXI Ethernet
  instance by the build flow.
* **Zynq UltraScale+** (`uzev`, `zcu102_*`) — the AXI Ethernet ports come up as
  `end0` … `endN`, plus one `end<N>` for the on-board GEM.

The numbering in the lists below corresponds to the order the kernel discovers
the interfaces; the actual names you see on a given boot depend on which family
the target belongs to.
```

### PicoZed, ZC702, ZC706, ZedBoard (Zynq-7000)

* eth0: GEM0 to Ethernet port of the dev board
* eth1: Ethernet FMC Port 0
* eth2: Ethernet FMC Port 1
* eth3: Ethernet FMC Port 2
* eth4: Ethernet FMC Port 3

The Zynq-7000 kernel renames the AXI Ethernet interfaces to `enx<mac>` —
for example `enx000a35000122` for Ethernet FMC Port 0, `enx000a35000123` for
Ethernet FMC Port 1, and so on.

### ZCU102, UltraZed-EV (Zynq UltraScale+)

* end0: Ethernet FMC Port 1
* end1: Ethernet FMC Port 2
* end2: Ethernet FMC Port 3
* end3: GEM to Ethernet port of the dev board
* end4: Ethernet FMC Port 0 (the port DHCP is attempted on)

```{note}
On the `zcu102_hpc1` target only Ethernet FMC Ports 0 and 1 are
routed (the HPC1 connector has a reduced pin-out), so only the corresponding
`end<N>` interfaces appear.
```

## Example Usage

The examples below were captured on a Zynq-7000 target (`zedboard`), so the
AXI Ethernet ports appear as `enx<mac>`. On Zynq UltraScale+ targets
(`zcu102_*`, `uzev`) the same commands work — substitute the corresponding
`end<N>` interface name from the [port configurations](#port-configurations)
section.

### Enable port

This example brings up an AXI Ethernet port.

```
root@zed-axieth-2025-2:~# ifconfig enx000a35000123 up
[  228.274146] xilinx_axienet 41040000.ethernet enx000a35000123: Link is Up - 1Gbps/Full - flow control off
[  228.282753] IPv6: ADDRCONF(NETDEV_CHANGE): enx000a35000123: link becomes ready
```

### Enable port with fixed IP address

This example sets a fixed IP address on a port.

```
root@zed-axieth-2025-2:~# ifconfig enx000a35000123 192.168.3.30 up
[  394.175238] xilinx_axienet 41040000.ethernet enx000a35000123: Link is Up - 1Gbps/Full - flow control off
[  394.183769] IPv6: ADDRCONF(NETDEV_CHANGE): enx000a35000123: link becomes ready
```

### Enable port using DHCP

This example enables a port and obtains an IP address for the port via DHCP.
The port must be connected to a DHCP enabled router.

```
root@zed-axieth-2025-2:~# udhcpc -i enx000a35000123
udhcpc: started, v1.36.1
xilinx_axienet 41040000.ethernet enx000a35000123: PHY [axienet-41040000:00] driver [Marvell 88E1510] (irq=POLL)
xilinx_axienet 41040000.ethernet enx000a35000123: configuring for phy/rgmii-rxid link mode
udhcpc: broadcasting discover
udhcpc: broadcasting select for 192.168.2.62, server 192.168.2.1
udhcpc: lease of 192.168.2.62 obtained from 192.168.2.1, lease time 259200
/etc/udhcpc.d/50default: Adding DNS 192.168.2.1
```

### Check port status

In this example, ``ifconfig`` with no arguments shows the port status. The
first AXI Ethernet port (`enx000a35000122`, Ethernet FMC Port 0) has already
obtained an IP address via DHCP; the remaining AXI Ethernet ports are up but
have no link partner. Captured from a `zedboard` PetaLinux boot:

```
zed-axieth-2025-2:~$ ifconfig
enx000a35000122 Link encap:Ethernet  HWaddr 00:0A:35:00:01:22  
          inet addr:192.168.2.62  Bcast:192.168.2.255  Mask:255.255.255.0
          inet6 addr: fe80::20a:35ff:fe00:122/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:33 errors:0 dropped:12 overruns:0 frame:0
          TX packets:15 errors:0 dropped:2 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:4230 (4.1 KiB)  TX bytes:1933 (1.8 KiB)

enx000a35000123 Link encap:Ethernet  HWaddr 00:0A:35:00:01:23  
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:3 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:140 (140.0 B)  TX bytes:140 (140.0 B)
```

``ethtool`` can also be used to check port status, for example:

```
root@zed-axieth-2025-2:~# ethtool enx000a35000122
Settings for enx000a35000122:
        Supported ports: [ TP MII FIBRE ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Link detected: yes
```

### Ping link partner using specific port

In this example we ping the link partner at IP address 192.168.2.98 from the
Ethernet FMC Port 0 interface:

```
zed-axieth-2025-2:~$ ping 192.168.2.98
PING 192.168.2.98 (192.168.2.98): 56 data bytes
64 bytes from 192.168.2.98: seq=0 ttl=64 time=0.463 ms
64 bytes from 192.168.2.98: seq=1 ttl=64 time=0.280 ms
64 bytes from 192.168.2.98: seq=2 ttl=64 time=0.279 ms
64 bytes from 192.168.2.98: seq=3 ttl=64 time=0.260 ms
^C
--- 192.168.2.98 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.260/0.320/0.463 ms
```

Use `ping -I <interface>` to force ping through a specific port if the default
route does not select it.

[Ethernet FMC]: https://docs.opsero.com/op031/datasheet/overview/
[supported Linux distributions]: https://docs.amd.com/r/en-US/ug1144-petalinux-tools-reference-guide/Setting-Up-Your-Environment

