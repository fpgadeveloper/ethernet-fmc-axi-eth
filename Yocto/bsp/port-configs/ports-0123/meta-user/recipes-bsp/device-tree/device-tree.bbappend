# Copyright (C) 2025-2026, Opsero Electronic Design Inc.  All rights reserved.
#
# SPDX-License-Identifier: MIT

# Per-target Ethernet port-config overlay. Supplies the external-PHY wiring for
# the AXI Ethernet ports (MAC address, phy-handle, MDIO bus, phy-mode) that the
# XSA / SDT does not describe (the PHYs live off-chip on the Ethernet FMC).
# configure-build.sh adds this layer per target, selected by the target's
# port-config (word 2 of its Yocto Makefile target, e.g. ports-0123 / ports-01--),
# so a board BSP can be shared across targets that differ only in active ports
# (e.g. zcu102_hpc0 = 4 ports vs zcu102_hpc1 = 2 ports).
#
# Injected via EXTRA_DT_INCLUDE_FILES (meta-xilinx device-tree.bb appends a
# `#include "port-config.dtsi"` to the base DTS). Scoped to the Linux (APU)
# domain DTS, same as the board system-user.dtsi.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

EXTRA_DT_INCLUDE_FILES:append = "${@' port-config.dtsi' if 'linux' in os.path.basename(d.getVar('CONFIG_DTFILE') or '') else ''}"
