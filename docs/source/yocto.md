# Yocto

The Yocto / EDF flow (AMD's Embedded Development Framework) is the announced successor to
PetaLinux. It can be built for the AXI Ethernet reference designs with the cross-platform
`build.py` runner at the root of the repository, and produces a Linux image in which the four
Ethernet FMC ports are ordinary network interfaces that you can configure and test with the
standard Linux tools.

```{note}
For 2025.2 both the PetaLinux and Yocto flows are supported. From the next tool version onward, the
PetaLinux flow for this repository will be retired and Yocto will be the only supported flow.
```

The Yocto flow is supported for the Zynq-7000 and Zynq UltraScale+ targets (the same set that
has PetaLinux support, see the target tables in the [build instructions](build_instructions.md#target-designs)).
The MicroBlaze (pure-FPGA) targets are standalone-only and have no Linux flow.

## Requirements

To build the Yocto projects you will need:

* A physical or virtual machine running one of the [supported Linux distributions] (Ubuntu 22.04 or
  24.04, for example), with roughly 60 GB of free disk space per target.
* Vivado 2025.2 (to build the XSA) and Vitis 2025.2 — the flow uses `xsct`/`sdtgen`, which ship
  with Vitis, to generate a System Device Tree from the Vivado XSA.
* [Google's repo tool](https://gerrit.googlesource.com/git-repo/) on your `PATH`, and the usual
  Yocto host packages. On Ubuntu:
  ```
  sudo apt-get install repo gawk wget git diffstat unzip texinfo gcc \
      build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
      xz-utils debianutils iputils-ping python3-git python3-jinja2 \
      python3-subunit zstd liblz4-tool file locales libacl1 bmap-tools
  ```

```{attention}
You cannot build the Yocto projects in the Windows operating system. Windows users
are advised to use a Linux virtual machine to build the Yocto projects. On Windows you can
still build the Vivado XSA and the standalone application, and run the Yocto stage on a Linux
machine afterwards.
```

To test the image on hardware you will also need an SD card (8 GB or larger), the [Ethernet FMC]
or [Robust Ethernet FMC], Ethernet cables and a PC (or a network with a DHCP server) to act as link
partner. To run the throughput tests, install `iperf3` on the PC.

## How to build

The build runner locates and sources the Vivado and Vitis settings itself, so there is no
need to source them by hand.

1. From a command terminal, clone the Git repository and `cd` into it:
   ```
   git clone https://github.com/fpgadeveloper/ethernet-fmc-axi-eth.git
   cd ethernet-fmc-axi-eth
   ```
2. Build the Yocto image for your target by running the following command, replacing
   `<target>` with one of the target design labels listed in the
   [build instructions](build_instructions.md#build-yocto):
   ```
   ./build.sh yocto --target <target>
   ```
   For example `./build.sh yocto --target zcu102_hpc0`. To also build the standalone application
   and PetaLinux and to gather the boot zips, run `./build.sh all --target <target>` instead.

This command launches the corresponding Vivado build if that project has not already been
built and its hardware exported. The first build of a target downloads several GB of sources
(`repo sync`) and runs bitbake from scratch, so it takes a while (a local sstate mirror speeds it
up considerably, see [Yocto offline build](build_instructions.md#yocto-offline-build)); subsequent
builds are incremental. The output products are gathered into `Yocto/<target>/images/linux/`:

| File | Description |
| --- | --- |
| `BOOT.BIN` | Boot image (FSBL + bitstream + U-Boot; ZynqMP also PMU firmware and TF-A) |
| `boot.scr` | U-Boot boot script (builds the kernel command line) |
| `uImage` / `Image` | Linux kernel (`uImage` on Zynq-7000, `Image` on Zynq UltraScale+) |
| `system.dtb` | Linux device tree |
| `rootfs.wic.xz` | Full SD-card disk image — this is what you flash |
| `rootfs.wic.bmap` | Block map for `bmaptool` (fast flashing) |
| `rootfs.tar.gz` | Root filesystem tarball |

`./build.sh all` or `./build.sh package --target <target>` also puts `rootfs.wic.xz`,
`rootfs.wic.bmap`, `BOOT.BIN` and a short `readme.txt` into
`bootimages/ethernet-fmc-axi-eth_<target>_yocto-2025-2.zip`.

## What is in the image

| | |
|---|---|
| Distribution | AMD Embedded Development Framework (EDF) Linux 25.11, kernel 6.12, U-Boot 2025.01, systemd |
| Hostname | `<board>-axieth-2025-2`, e.g. `zcu102-axieth-2025-2`, `uzev-axieth-2025-2`, `zedboard-axieth-2025-2`, `pz-axieth-2025-2`, `zc702-axieth-2025-2`, `zc706-axieth-2025-2` |
| Login | user `amd-edf`, no initial password: you must choose a password at the first login. Use `sudo` for root commands |
| Network | every Ethernet interface is brought up at boot and configured by DHCP (systemd-networkd); SSH server enabled |
| Test tools | `ethtool`, `phytool`, `iperf3`, `ping`, `ip`, `bridge-utils` (`brctl`), `nfs-utils`, `pciutils`, `can-utils`, `mtd-utils` |
| Ethernet FMC MACs | `00:0a:35:00:01:22` (port 0) to `00:0a:35:00:01:25` (port 3) — see [MAC addresses](description.md#mac-addresses-used-by-linux) |
| Board Ethernet port | PS GEM0 (Zynq-7000) or GEM3 (Zynq UltraScale+), enabled with its PHY described in the device tree |

The kernel command line is built by `boot.scr`. The board-specific arguments, such as the size of
the contiguous memory area (CMA) used for the DMA buffers, come from `BSP_EXTRA_BOOTARGS` in
`Yocto/bsp/<board>/conf/local.conf.append`:

| Board BSP | Kernel command line |
|-----------|---------------------|
| `zcu102`, `uzev` | `earlycon console=ttyPS0,115200 clk_ignore_unused init_fatal_sh=1 root=/dev/mmcblk<N>p3 ro rootwait uio_pdrv_genirq.of_id=generic-uio cma=1536M` |
| `zedboard` | `root=/dev/mmcblk0p3 ro rootwait uio_pdrv_genirq.of_id=generic-uio earlycon console=ttyPS0,115200 clk_ignore_unused cma=256M` |
| `pz`, `zc702`, `zc706` | as `zedboard`, with `cma=512M` |

(The root partition is mounted read-only first and remounted read-write by systemd during boot.)

## Boot from SD card

The Yocto flow produces a **full SD-card disk image** (`rootfs.wic.xz`) that already contains all
partitions:

| Partition | Type | Contents |
|-----------|------|----------|
| 1 (`esp`) | FAT | `BOOT.BIN` (after step 4 below) |
| 2 (`boot`) | ext4 | `boot.scr`, the kernel and the device tree |
| 3 (`root`) | ext4 | root file system |

You flash that image to the SD card's raw device, then copy `BOOT.BIN` onto the first (FAT)
partition, from which the BootROM loads it.

### Prepare the SD card

```{warning}
Flashing writes directly to a raw block device and cannot be undone. Be absolutely
certain you have identified the SD card's device node before running the commands below — if you
use the wrong device you risk destroying data on one of your hard drives.
```

1. Identify the SD card device. With the card **un**plugged, run `lsblk -o NAME,SIZE,RM,TYPE`,
   insert the card, and run it again. The new entry — typically `/dev/sdX`, with `RM=1`
   (removable) and a size matching your card — is your target. Replace `sdX` with that device,
   and `<target>` with your board, below.
2. Unmount any partitions the desktop auto-mounted:
   ```
   for p in /dev/sdX?*; do sudo umount "$p" 2>/dev/null; done
   ```
3. Flash the wic image to the raw device. With `bmaptool` (fast — only writes used blocks):
   ```
   sudo bmaptool copy --bmap Yocto/<target>/images/linux/rootfs.wic.bmap \
                            Yocto/<target>/images/linux/rootfs.wic.xz \
                            /dev/sdX
   ```
   Or, as a fallback with `dd`:
   ```
   xzcat Yocto/<target>/images/linux/rootfs.wic.xz \
       | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
   ```
   (If you use the files from the boot zip, the paths are simply `rootfs.wic.bmap` and
   `rootfs.wic.xz`.)
4. **Install `BOOT.BIN` on the `esp` partition.** The EDF wic leaves the first FAT partition
   (`esp`) without a `BOOT.BIN` the BootROM can use, so the card does not boot until you copy it
   there:
   ```
   sudo partprobe /dev/sdX
   sudo mkdir -p /mnt/sd_esp
   sudo mount /dev/sdX1 /mnt/sd_esp
   sudo cp Yocto/<target>/images/linux/BOOT.BIN /mnt/sd_esp/BOOT.BIN
   sync
   sudo umount /mnt/sd_esp && sudo rmdir /mnt/sd_esp
   ```
   (If your desktop auto-mounts the partitions, you can instead copy `BOOT.BIN` straight onto the
   `esp` mountpoint.)
5. Eject the card cleanly so pending writes flush: `sudo eject /dev/sdX`.

On Windows, a tool that can write raw disk images (for example [balenaEtcher] after decompressing
the `.wic.xz`, or Win32 Disk Imager) can write the image; then copy `BOOT.BIN` onto the small FAT
partition, which Windows shows as a drive.

### Boot

1. Plug the SD card into the target board and set it to boot from SD. The boot-mode switch
   settings are the same regardless of the Linux flow — see the per-board switch settings under
   [Boot PetaLinux](petalinux.md#boot-petalinux) and your board's user guide.
2. Connect the [Ethernet FMC] to the target board's FMC connector, and connect the ports you want to
   test to your PC or network. Optionally connect the board's own Ethernet port to your network as
   well, so that you can log in over SSH.
3. Connect the USB-UART to your PC and open a terminal emulator at 115200 baud (8N1) — see
   [UART terminal](petalinux.md#uart-terminal).
4. Connect and power your hardware.

### What the boot looks like

On a Zynq UltraScale+ board, the FSBL and PMU firmware banners are followed by U-Boot, which finds
the four AXI Ethernet MACs and the board's GEM, then loads `boot.scr` from the `boot` partition.
This excerpt is from an UltraZed-EV (`uzev`) boot:

```
Zynq MP First Stage Boot Loader
...
U-Boot 2025.01-g5e0d8abc7e09 (Nov 12 2025 - 07:44:59 +0000)
Model: ZynqMP Ultrazed EV
DRAM:  2 GiB (effective 4 GiB)
...
Net:   AXI EMAC: a0100000, phyaddr 0, interface rgmii-rxid
AXI EMAC: a00c0000, phyaddr 0, interface rgmii-rxid
AXI EMAC: a0080000, phyaddr 0, interface rgmii-rxid
AXI EMAC: a0000000, phyaddr 0, interface rgmii-rxid
ZYNQ GEM: ff0e0000, mdio bus ff0e0000, phyaddr 0, interface rgmii-id
...
Found U-Boot script /boot.scr
...
[    0.000000] Machine model: ZynqMP Ultrazed EV
[    0.000000] Kernel command line: earlycon console=ttyPS0,115200 clk_ignore_unused init_fatal_sh=1 root=/dev/mmcblk1p3 ro rootwait uio_pdrv_genirq.of_id=generic-uio cma=1536M
...
[    9.529096] macb ff0e0000.ethernet end4: renamed from eth4
[    9.563259] xilinx_axienet a0100000.ethernet end2: renamed from eth3
[    9.594467] xilinx_axienet a0080000.ethernet end0: renamed from eth1
[    9.616010] xilinx_axienet a0000000.ethernet end3: renamed from eth0
[    9.633623] xilinx_axienet a00c0000.ethernet end1: renamed from eth2
...
uzev-axieth-2025-2 login:
```

On a Zynq-7000 board the console output starts with U-Boot, which finds the board's GEM0 and boots
the kernel. This excerpt is from a ZedBoard (`zedboard`) boot:

```
U-Boot 2025.01-g5e0d8abc7e09 (Nov 12 2025 - 07:44:59 +0000)

CPU:   Zynq 7z020
...
Net:
ZYNQ GEM: e000b000, mdio bus e000b000, phyaddr 0, interface rgmii-id
...
Scanning mmc 0:2...
Found U-Boot script /boot.scr
...
Starting kernel ...

Booting Linux on physical CPU 0x0
...
Kernel command line: root=/dev/mmcblk0p3 ro rootwait uio_pdrv_genirq.of_id=generic-uio earlycon console=ttyPS0,115200 clk_ignore_unused cma=256M
...
xilinx_axienet 41040000.ethernet end0: renamed from eth2
xilinx_axienet 410c0000.ethernet end2: renamed from eth4
macb e000b000.ethernet end4: renamed from eth0
xilinx_axienet 41000000.ethernet end3: renamed from eth1
xilinx_axienet 41080000.ethernet end1: renamed from eth3
...
zedboard-axieth-2025-2 login:
```

### Log in

Log in on the UART console as `amd-edf`. There is no initial password; the system asks you to choose
one immediately:

```
zedboard-axieth-2025-2 login: amd-edf
You are required to change your password immediately (administrator enforced).
New password:
Retype new password:

WARNING: AMD Embedded Development Framework is a reference Yocto Project
distribution that should be used for testing and development purposes only.
It is recommended that you create your own distribution for production use.

zedboard-axieth-2025-2:~$
```

Root commands are run with `sudo` (it asks for the password you just chose). Once a password is
set, you can also log in over SSH (`ssh amd-edf@<board-ip>`) through any port that has an IP
address, for example the board's own Ethernet port.

## Using and testing the AXI Ethernet ports

### Identify the interfaces

The EDF image uses the systemd predictable naming scheme, so all Ethernet interfaces are named
`end<N>`. **The interface number does not follow the Ethernet FMC port number**: it depends on the
order in which the drivers probe. Identify each interface by its MAC address or by the base address
of its controller. This command lists both:

```
for n in /sys/class/net/e*; do
  echo "$(basename $n)  $(basename $(readlink -f $n/device))  $(cat $n/address)"
done
```

Output on a `zedboard`:

```
end0  41040000.ethernet  00:0a:35:00:01:23
end1  41080000.ethernet  00:0a:35:00:01:24
end2  410c0000.ethernet  00:0a:35:00:01:25
end3  41000000.ethernet  00:0a:35:00:01:22
end4  e000b000.ethernet  00:0a:35:06:21:20
```

Use this table to map the controller address to the Ethernet FMC port:

| Ethernet FMC port | MAC address | Zynq UltraScale+ controller | Zynq-7000 controller |
|-------------------|-------------|-----------------------------|----------------------|
| Port 0 | `00:0a:35:00:01:22` | `a0000000.ethernet` | `41000000.ethernet` |
| Port 1 | `00:0a:35:00:01:23` | `a0080000.ethernet` | `41040000.ethernet` |
| Port 2 | `00:0a:35:00:01:24` | `a00c0000.ethernet` | `41080000.ethernet` |
| Port 3 | `00:0a:35:00:01:25` | `a0100000.ethernet` | `410c0000.ethernet` |
| Board Ethernet port | set by the BSP or U-Boot | `ff0e0000.ethernet` (GEM3) | `e000b000.ethernet` (GEM0) |

With the images built from this repository, the names came out as follows (they can change if you
modify the design or the device tree, so always check):

| Target | Port 0 | Port 1 | Port 2 | Port 3 | Board port |
|--------|--------|--------|--------|--------|------------|
| `zcu102_hpc0`, `uzev`, `zedboard` | `end3` | `end0` | `end1` | `end2` | `end4` |
| `zcu102_hpc1` | `end1` | `end0` | — | — | `end2` |

`dmesg` also shows which PHY driver bound to each port and the link state:

```
$ dmesg | grep -iE "PHY \[|Link is"
xilinx_axienet a0000000.ethernet end3: PHY [axienet-a0000000:00] driver [Marvell 88E1510] (irq=POLL)
xilinx_axienet a0080000.ethernet end0: PHY [axienet-a0080000:00] driver [Marvell 88E1510] (irq=POLL)
xilinx_axienet a00c0000.ethernet end1: PHY [axienet-a00c0000:00] driver [Marvell 88E1510] (irq=POLL)
xilinx_axienet a0100000.ethernet end2: PHY [axienet-a0100000:00] driver [Marvell 88E1510] (irq=POLL)
xilinx_axienet a0000000.ethernet end3: Link is Up - 1Gbps/Full - flow control off
```

### Bring a port up: DHCP or static IP

All interfaces are up after boot, and each one that has a link requests an address by DHCP. Show
the state of all interfaces with:

```
$ ip -br addr
end3             UP             192.168.1.101/24 metric 10 fe80::20a:35ff:fe00:122/64
end0             DOWN
end1             DOWN
end2             UP             192.168.1.102/24 metric 10 fe80::20a:35ff:fe00:125/64
end4             UP             192.168.1.100/24 metric 10 fe80::20a:35ff:fe06:2120/64
```

`DOWN` means that the port has no link (no cable or link partner). If you connect a port directly to
a PC without a DHCP server, give both ends a static address instead — on the board:

```
sudo ip addr add 192.168.10.10/24 dev end3
sudo ip link set end3 up
```

and on the PC an address in the same subnet (for example 192.168.10.1). To make a static address
permanent, create a systemd-networkd file, for example `/etc/systemd/network/10-end3.network`:

```
[Match]
Name=end3

[Network]
Address=192.168.10.10/24
```

then run `sudo systemctl restart systemd-networkd`.

```{tip}
When several ports are connected to the same subnet, Linux may send the traffic of one port out of
another. Either put each port under test in its own subnet, or force the interface in your tests
(`ping -I <iface>`, `iperf3 --bind-dev <iface>`) as in the examples below.
```

### Check the link and the PHY

`ethtool` shows the negotiated link:

```
$ sudo ethtool end3 | grep -E "Speed|Duplex|Link detected"
	Speed: 1000Mb/s
	Duplex: Full
	Link detected: yes
```

`ethtool -S <iface>` shows the MAC's statistics counters (including receive errors), and
`ip -s link show <iface>` the kernel's packet and error counters.

`phytool` reads the PHY registers over the port's MDIO bus (the PHY of every port is at MDIO
address 0 on its own bus). For example, to print the standard registers of the PHY of `end3`:

```
sudo phytool print end3/0
```

### Ping a link partner

```
$ ping -c 5 -I end3 192.168.1.20
...
5 packets transmitted, 5 received, 0% packet loss, time 4077ms
rtt min/avg/max/mdev = 0.170/0.227/0.383/0.078 ms
```

### Measure the throughput with iperf3

Start an iperf3 server on the PC:

```
iperf3 -s
```

On the board, measure the transmit direction (board to PC) and then the receive direction
(`-R`, PC to board) of one port, with the PC's IP address:

```
iperf3 -c <pc-ip> --bind-dev end3 -t 10
iperf3 -c <pc-ip> --bind-dev end3 -t 10 -R
```

Example on a ZCU102 (`zcu102_hpc0`, Ethernet FMC port 0):

```
[  5]   0.00-10.00  sec  1.10 GBytes   943 Mbits/sec    0            sender
[  5]   0.00-10.00  sec  1.10 GBytes   941 Mbits/sec                  receiver
```

Repeat for each port (start one `iperf3 -s` per port on the PC, on different port numbers with
`-p`, if you want to run several ports at the same time).

### What to expect

These are the single-stream TCP results we measured with iperf3 (10 s per direction, one port at a
time, against a PC):

| Board | Ports | Transmit (board → PC) | Receive (PC → board) |
|-------|-------|-----------------------|----------------------|
| ZCU102, UltraZed-EV (Cortex-A53) | Ethernet FMC ports | 940–943 Mbit/s | 859–934 Mbit/s |
| ZCU102 (Cortex-A53) | board port (GEM3) | 941–942 Mbit/s | 934 Mbit/s |
| ZedBoard (Cortex-A9) | Ethernet FMC ports | 734–778 Mbit/s | 634–676 Mbit/s |
| ZedBoard (Cortex-A9) | board port (GEM0) | 558 Mbit/s | 670 Mbit/s |

On Zynq UltraScale+ every port reaches close to gigabit line rate. On Zynq-7000 the Cortex-A9
processor, not the Ethernet hardware, is the limit, so the figures are lower and depend on the CPU
load; the receive direction may also show some TCP retransmissions and RX FIFO overruns
(`rx_missed_errors`), which are a sign of the CPU not keeping up, not of a link fault. As a rule of
thumb, investigate if a port gives less than about 800 Mbit/s on Zynq UltraScale+, or less than
250 Mbit/s (Ethernet FMC ports) or 400 Mbit/s (GEM0) on Zynq-7000, or if `ethtool -S` / `ip -s link`
report receive errors other than overruns.

## Patches and fixes in the Yocto BSPs

The per-board fixups applied in the Yocto flow live under `Yocto/bsp/` — the board
`system-user.dtsi` device-tree overrides, the per-target `port-config.dtsi` overlays, the kernel
`bsp.cfg` fragments, the image recipe additions and the U-Boot boot-script append. See
[advanced](advanced.md#yocto--edf-side) for the full list. The notable ones:

* **AXI Ethernet PHY wiring (`port-config.dtsi`).** The external Ethernet FMC PHYs are not
  described by the XSA, so each target applies a port-config overlay (`ports-0123` for four-port
  designs, `ports-01--` for the two-port `zcu102_hpc1`) that adds the MAC address, PHY handle,
  MDIO bus and RGMII mode for each active port. The overlay is selected by the `portcfg` attribute
  of the target in `config/data.json`.
* **Board Ethernet port on Zynq-7000.** GEM0 is enabled and its PHY is described in
  `system-user.dtsi` (MDIO address 0 on ZedBoard and PicoZed, 7 on ZC702 and ZC706, `rgmii-id`).
  The generated device tree describes no PHY for GEM0, which makes U-Boot 2025.01 crash while
  probing it; describing the PHY fixes that and gives you a working board port.
* **Board Ethernet port on ZCU102.** The TI DP83867 PHY of GEM3 is described with its RGMII delay
  settings in `system-user.dtsi`; without them the link comes up at 1 Gbit/s but passes no traffic.
  Both PHY addresses used by the different ZCU102 board revisions are described.
* **Zynq-7000 root `compatible`.** `system-user.dtsi` restores `compatible = "xlnx,zynq-7000"`;
  without it the kernel crashes at clock initialization.
* **Kernel command line and hostname.** `BSP_EXTRA_BOOTARGS` (console, CMA size) is appended to the
  kernel command line by `boot.scr`, and the hostname is set to `<board>-axieth-2025-2`.
* **NFS server on Zynq-7000.** The z7 (arm) kernel defconfig omits `CONFIG_NFSD`, so the
  `bsp.cfg` adds it for parity with the Zynq UltraScale+ targets; otherwise the NFS server fails to
  start at boot.

For problems with the ports, see [Troubleshooting](troubleshooting.md#linux-port-issues).

[Ethernet FMC]: https://docs.opsero.com/op031/datasheet/overview/
[Robust Ethernet FMC]: https://docs.opsero.com/op041/datasheet/overview/
[supported Linux distributions]: https://docs.amd.com/r/en-US/ug1144-petalinux-tools-reference-guide/Setting-Up-Your-Environment
[balenaEtcher]: https://etcher.balena.io/
