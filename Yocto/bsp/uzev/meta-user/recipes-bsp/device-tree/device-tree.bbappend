# Copyright (C) 2025-2026, Opsero Electronic Design Inc.  All rights reserved.
#
# SPDX-License-Identifier: MIT

# Board-level (SoC-side) device-tree fixups for the Ethernet FMC AXI Ethernet
# reference design, layered on top of the gen-machineconf / lopper-generated
# CONFIG_DTFILE (cortexa9-linux.dts / cortexa53-linux.dts). The design-specific
# PL hardware (the AXI Ethernet cores) already comes from the SDT's pl.dtsi;
# this file carries only what the XSA doesn't encode (see system-user.dtsi).
# The per-target Ethernet PHY wiring (port-config.dtsi) is supplied separately
# by the bsp/port-configs/<ports-*> overlay layer.
#
# meta-xilinx's device-tree.bb consumes EXTRA_DT_INCLUDE_FILES by copying each
# file into the DT build dir and appending a `#include "<file>"` to the base
# DTS. Scope it to the Linux (APU) domain only: the FSBL / PMU domain DTS files
# don't define the SoC peripheral labels these overrides reference, so dtc would
# fail with "Label or path ... not found". The Linux domain CONFIG_DTFILE is the
# only one whose name contains "linux".
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

EXTRA_DT_INCLUDE_FILES:append = "${@' system-user.dtsi' if 'linux' in (d.getVar('CONFIG_DTFILE') or '') else ''}"
