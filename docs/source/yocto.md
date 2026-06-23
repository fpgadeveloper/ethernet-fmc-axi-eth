# Yocto

The Yocto / EDF flow (AMD's Embedded Development Framework) is the announced successor to
PetaLinux. It can be built for the AXI Ethernet reference designs with the cross-platform
`build.py` runner at the root of the repository, and produces a Linux image that exercises the
AXI Ethernet ports in exactly the same way as the PetaLinux flow.

```{note}
For 2025.2 both the PetaLinux and Yocto flows are supported and produce an equivalent
image. From the next tool version onward, the PetaLinux flow for this repository will be retired
and Yocto will be the only supported flow.
```

The Yocto flow is supported for the Zynq-7000 and Zynq UltraScale+ targets (the same set that
has PetaLinux support). The MicroBlaze (pure-FPGA) targets are standalone-only and have no Linux
flow.

## Requirements

To build the Yocto projects you will need a physical or virtual machine running one of the
[supported Linux distributions], with the Vitis Core Development Kit installed — the flow uses
`xsct`/`sdtgen` (which ship with Vitis) to generate a System Device Tree from the Vivado XSA. You
also need [Google's repo tool](https://gerrit.googlesource.com/git-repo/) on your `PATH`.

```{attention}
You cannot build the Yocto projects in the Windows operating system. Windows users
are advised to use a Linux virtual machine to build the Yocto projects.
```

## How to build

The build runner locates and sources the Vivado and Vitis settings itself, so there is no
need to source them by hand; you only need [Google's repo tool](https://gerrit.googlesource.com/git-repo/)
on your `PATH` (see Requirements above).

1. From a command terminal, clone the Git repository (with its submodules) and `cd` into it:
   ```
   git clone --recurse-submodules https://github.com/fpgadeveloper/ethernet-fmc-axi-eth.git
   cd ethernet-fmc-axi-eth
   ```
2. Build the Yocto image for your target by running the following command, replacing
   `<target>` with one of the target design labels listed in the
   [build instructions](build_instructions.md#build-yocto):
   ```
   ./build.sh yocto --target <target>
   ```

This command launches the corresponding Vivado build if that project has not already been
built and its hardware exported. The first build of a target downloads several GB of sources
(`repo sync`) and runs bitbake from scratch, so it takes a while; subsequent builds are
incremental. The output products are gathered into `Yocto/<target>/images/linux/`:

| File | Description |
| --- | --- |
| `BOOT.BIN` | Boot image (FSBL + bitstream + U-Boot) |
| `boot.scr` | U-Boot boot script |
| `uImage` / `Image` | Linux kernel (`uImage` on Zynq-7000, `Image` on Zynq UltraScale+) |
| `system.dtb` | Linux device tree |
| `rootfs.wic.xz` | Full SD-card disk image — this is what you flash |
| `rootfs.wic.bmap` | Block map for `bmaptool` (fast flashing) |
| `rootfs.tar.gz` | Root filesystem tarball |

## Boot from SD card

Unlike the PetaLinux flow (which produces separate boot files for a hand-partitioned card), the
Yocto flow produces a **full SD-card disk image** (`rootfs.wic.xz`) that already contains all
partitions. You flash that image to the SD card's raw device, then copy `BOOT.BIN` onto the first
FAT partition.

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
4. **Install `BOOT.BIN` on the `esp` partition.** The EDF wic leaves the first FAT partition
   (`esp`) empty and installs `BOOT.BIN` onto the ext4 `boot` partition, which the BootROM cannot
   read. Since the BootROM loads `BOOT.BIN` from the first FAT partition, copy it onto `esp` by
   hand:
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

### Boot

1. Plug the SD card into the target board and set it to boot from SD. The boot-mode DIP-switch
   settings are the same regardless of the Linux flow — see the per-board switch settings under
   [Boot PetaLinux](petalinux.md#boot-petalinux).
2. Connect the [Ethernet FMC] to the target board's FMC connector.
3. Connect the USB-UART to your PC and open a terminal emulator at 115200 baud (8N1) — see
   [UART terminal](petalinux.md#uart-terminal).
4. Connect and power your hardware.

## Using the AXI Ethernet ports

Once Linux has booted and you have logged in at the console, the AXI Ethernet ports are exercised
exactly as in the PetaLinux flow — see [Example Usage](petalinux.md#example-usage) for the
port-enable, fixed-IP, DHCP, status and ping walkthrough.

```{note}
**Interface names differ from the PetaLinux flow.** The EDF rootfs uses the systemd
predictable-naming scheme, so on **all** targets (Zynq-7000 and Zynq UltraScale+) the AXI Ethernet
ports appear as `end0`–`end3` rather than the PetaLinux `enx<mac>` / `end<N>` names. The interface
number does **not** track the FMC port number; identify a port by its MAC address (Ethernet FMC
Port 0 = `00:0a:35:00:01:22`, Port 1 = `…:23`, Port 2 = `…:24`, Port 3 = `…:25`) or by the
controller base address printed at boot (`xilinx_axienet a0000000.ethernet …`). Substitute the
appropriate `end<N>` name into the commands in [Example Usage](petalinux.md#example-usage).
```

## Patches and known issues

The per-board fixups applied in the Yocto flow live under `Yocto/bsp/` — the board
`system-user.dtsi` device-tree overrides, the per-target `port-config.dtsi` overlays, and the
kernel `bsp.cfg` fragments. See [advanced](advanced.md#yocto--edf-side) for the full list. The
notable ones:

* **AXI Ethernet PHY wiring (`port-config.dtsi`).** The external Ethernet-FMC PHYs are not
  described by the XSA, so each target applies a port-config overlay (`ports-0123` for four-port
  designs, `ports-01--` for the two-port `zcu102_hpc1`) that adds the MAC address, PHY handle,
  MDIO bus and RGMII mode for each active port.
* **PS Ethernet disabled (Zynq-7000).** `gem0` is disabled in `system-user.dtsi`; this design uses
  the PL AXI Ethernet cores, not the PS GEM, and the 2025.x U-Boot data-aborts probing a `gem0`
  left without a PHY handle.
* **Zynq-7000 device-tree fixups.** `system-user.dtsi` restores the SoC-family
  `compatible = "xlnx,zynq-7000"` (the parse-sdt board merge drops it, which would otherwise crash
  the kernel at clock init) and sets `/chosen/bootargs` (the z7 boot.scr reads bootargs from the
  device tree).
* **NFS server on Zynq-7000.** The z7 (arm) kernel defconfig omits `CONFIG_NFSD`, so the
  `bsp.cfg` adds it for parity with the Zynq UltraScale+ targets; otherwise the NFS server fails to
  start at boot.

[Ethernet FMC]: https://docs.opsero.com/op031/datasheet/overview/
[supported Linux distributions]: https://docs.amd.com/r/en-US/ug1144-petalinux-tools-reference-guide/Setting-Up-Your-Environment
