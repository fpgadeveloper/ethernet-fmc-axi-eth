# Copyright (C) 2025-2026, Opsero Electronic Design Inc.  All rights reserved.
#
# SPDX-License-Identifier: MIT

# Ethernet FMC AXI Ethernet reference-design rootfs packages (ported from the
# PetaLinux bsp rootfs_config: ethtool + iperf3 for link/throughput testing,
# plus the common utilities the PetaLinux rootfs enables).
IMAGE_INSTALL:append = " \
    ethtool \
    phytool \
    iperf3 \
    mtd-utils \
    can-utils \
    nfs-utils \
    pciutils \
"
