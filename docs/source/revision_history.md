# Revision History

## 2025.2 Changes

* Updated for Vivado / Vitis / PetaLinux 2025.2
* Migrated standalone application to the Vitis Unified IDE Python flow
  (`Vitis/py/build-vitis.py` driven by `args.json`) — replaces the old
  XSCT batch flow
* Switched to SDT-based BSP generation; XPAR macros are now
  `*_BASEADDR` rather than `*_DEVICE_ID`
* Linux kernel 6.12, U-Boot 2025.01 from the AMD/Xilinx tree
* AXI Ethernet interfaces are renamed by the kernel: `enx<mac>` on
  Zynq-7000, `end<N>` on Zynq UltraScale+
* Per-board `cma=` reservation in the kernel command line is sized to
  the device's DDR (256M / 512M / 1536M depending on target — see
  [advanced](advanced.md#zynq-7000-and-zynqmp-bsps))
* Added a transient-sstate-fetch troubleshooting entry
* Added the AMD Yocto / EDF build flow (in `Yocto/`) for the Zynq-7000 and
  Zynq UltraScale+ targets, alongside PetaLinux — see [Yocto](yocto.md). The
  MACHINE is generated from the Vivado XSA via `gen-machineconf parse-sdt`, and
  the AXI Ethernet PHY wiring is supplied per target by `port-config.dtsi`
  overlay layers (`ports-0123` / `ports-01--`). The PetaLinux flow for this
  repository will be retired after 2025.2 — Yocto / EDF is its successor
* In the Yocto/EDF images the AXI Ethernet interfaces are `end0`–`end3` on all
  targets (the EDF rootfs uses systemd predictable naming), unlike the PetaLinux
  `enx<mac>` names on Zynq-7000
* Zynq-7000 Yocto kernel: enabled `CONFIG_NFSD` (the arm defconfig omits it),
  so the NFS server starts cleanly at boot as it does on Zynq UltraScale+

## 2024.1 Changes

* Removed PetaLinux support for all pure FPGA designs
* Improved documentation, centralized targed design info to JSON file

## 2022.1 Changes

* Added Makefiles to improve the build experience for Linux users
* Consolidated Vivado batch files (user is prompted to select target design)
* Vitis build script now creates a separate workspace for each target design (improved user experience)
* Converted documentation to markdown (from reStructuredText)
* Removed the unnecessary postfix _axieth from all designs
* Removed MicroZed FMC Carrier design (Avnet has discontinued the product).
* Removed the PetaLinux projects for VC707, VC709 and VCU108 (AMD Xilinx releases no official BSP)

