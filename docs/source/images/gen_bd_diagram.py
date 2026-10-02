#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Opsero Electronic Design Inc.
"""
Generate the block-design (Vivado) diagram for the Opsero AXI Ethernet reference
designs ("Description" page, "Block design" section).

Where axi-eth-block-diagram.png (gen_block_diagram.py) is the conceptual view, this
one shows the block design `axieth` as the scripts in Vivado/src/bd/ build it: every
box is a real cell or external port of the block design, with its real name. One port
chain (N = 0..3) is drawn in full; the other ports are identical copies. The tables at
the bottom give the per-family differences: the cell names that differ, the address map
seen by the processor and the clock frequencies, taken from the built designs
(zcu102_hpc0, zedboard, kc705_hpc and vcu118 hardware handoff files).

It reuses the palette and drawing helpers of gen_block_diagram.py so that both
diagrams look the same.

The output PNG is written next to this script (i.e. into docs/source/images/):
    axi-eth-bd-diagram.png

Usage (from anywhere):
    python3 docs/source/images/gen_bd_diagram.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_block_diagram as g                      # noqa: E402  (palette + helpers)
from gen_block_diagram import (box, titled_box, harrow, varrow, route,  # noqa: E402
                               refclk_arrow, plt)
from matplotlib.lines import Line2D                # noqa: E402

TXT = g.TXT
MONO = "DejaVu Sans Mono"


def small(ax, x, y, s, fs=6.8, ha="center", color="#404040", weight="normal",
          z=4, va="center", family=None):
    ax.text(x, y, s, ha=ha, va=va, fontsize=fs, color=color, zorder=z,
            linespacing=1.3, weight=weight, family=family)


def table(ax, x0, y_top, title, rows, col_x, fs=7.0, title_fs=8.6, dy=2.35,
          header=None):
    """Plain text table: title, optional bold header row, then rows of cells."""
    ax.text(x0, y_top, title, ha="left", va="center", fontsize=title_fs,
            weight="bold", color=TXT, zorder=4)
    y = y_top - 3.0
    if header:
        for cx, cell in zip(col_x, header):
            ax.text(x0 + cx, y, cell, ha="left", va="center", fontsize=fs,
                    weight="bold", color=TXT, zorder=4)
        y -= dy
    for r in rows:
        for cx, cell in zip(col_x, r):
            ax.text(x0 + cx, y, cell, ha="left", va="center", fontsize=fs,
                    color=TXT, zorder=4, family=MONO if cell.startswith("0x") else None)
        y -= dy


C_IRQ = "#9A7FB8"                                 # interrupt nets


def main():
    fig, ax = plt.subplots(figsize=(19.5, 14.0), dpi=120)
    ax.set_xlim(0, 195)
    ax.set_ylim(0, 140)
    ax.axis("off")

    # ---- title ---------------------------------------------------------------
    ax.text(97.5, 138.0,
            "Block design  axieth   (Vivado/src/bd/bd_zynqmp.tcl, bd_zynq.tcl, "
            "bd_mb-7s.tcl, bd_mb-us.tcl)",
            ha="center", va="center", fontsize=12.5, weight="bold", color=TXT)

    # ---- processor cell ------------------------------------------------------
    ps_x0, ps_w, ps_y0, ps_y1 = 2.0, 22.0, 62.0, 132.0
    ps_r = ps_x0 + ps_w
    box(ax, ps_x0, ps_y0, ps_w, ps_y1 - ps_y0, g.C_PS_FILL, g.C_PS_EDGE, "", lw=1.3)
    cx = ps_x0 + ps_w / 2
    small(ax, cx, 128.0, "Processor cell", fs=10.5, weight="bold", color=TXT)
    small(ax, cx, 103.0,
          "zynq_ultra_ps_e_0\n(Zynq US+)\n\nprocessing_system7_0\n(Zynq-7000)\n\n"
          "microblaze_0 + mig_0\nor ddr4_0 (MicroBlaze)", fs=7.2, color=TXT)
    small(ax, cx, 86.0, "Zynq / Zynq US+:\nboard preset applied\n(DDR, MIO, UART,\nSD, PS GEM)", fs=6.8)
    small(ax, ps_r - 1.0, 124.0, "M_AXI_HPM0_FPD\nM_AXI_GP0\nM_AXI_DP", fs=6.3,
          ha="right")
    small(ax, ps_r - 1.0, 77.0, "S_AXI_HP0_FPD\nS_AXI_HP0\nMIG / DDR4 S_AXI", fs=6.3,
          ha="right")
    small(ax, ps_r - 1.0, 66.5, "pl_ps_irq0/1\nIRQ_F2P\nAXI INTC", fs=6.3, ha="right")

    # ---- fabric container ----------------------------------------------------
    fab_x0, fab_x1 = 27.0, 153.0
    ax.add_patch(plt.Rectangle((fab_x0, 56.0), fab_x1 - fab_x0, 78.5,
                               fc=g.C_FAB_FILL, ec=g.C_FAB_EDGE, lw=1.3, zorder=1))

    # AXI-Lite interconnect
    titled_box(ax, 30.0, 118.0, 30.0, 12.0, g.C_CTRL_FILL, g.C_CTRL_EDGE,
               "ps8_0_axi_periph",
               "(ps7_0_axi_periph on Zynq-7000,\nmicroblaze_0_axi_periph on MicroBlaze)\n"
               "AXI-Lite → every MAC and DMA",
               title_fs=8.6, body_fs=6.6, title_dy=2.2)
    harrow(ax, ps_r, 30.0, 124.0, "", g.C_CTRL_FILL, g.C_PS_EDGE, double=False,
           bh=1.3, hh=2.4, hl=1.6)

    # AXI SmartConnect
    titled_box(ax, 30.0, 70.0, 16.0, 13.0, g.C_GT_FILL, g.C_GT_EDGE,
               "axi_smc",
               "SmartConnect\n3 slave ports per\nDMA → 1 master\n(+ axi_smc_extra on\n"
               "8-port designs)",
               title_fs=8.6, body_fs=6.4, title_dy=2.2)
    harrow(ax, 30.0, ps_r, 77.0, "", g.C_AXARR_FILL, g.C_AXARR_EDGE, double=False,
           bh=1.3, hh=2.4, hl=1.6)

    # interrupt concat
    titled_box(ax, 30.0, 58.0, 16.0, 9.5, g.C_CTRL_FILL, g.C_CTRL_EDGE,
               "xlconcat_0",
               "(+ xlconcat_1 on Zynq US+)\n4 inputs per port",
               title_fs=8.2, body_fs=6.3, title_dy=2.0)
    harrow(ax, 30.0, ps_r, 62.75, "", g.C_CTRL_FILL, g.C_PS_EDGE, double=False,
           bh=1.0, hh=2.0, hl=1.4)

    # ---- one port chain (N = 0..3), with shadow copies behind ------------------
    for k in (2, 1):                                  # shadows of the other ports
        d = 1.2 * k
        box(ax, 52.0 + d, 88.0 - d, 98.0, 26.0, "#FAFAFD", g.C_MAC_EDGE, "",
            lw=0.9, z=1.2)
    box(ax, 52.0, 88.0, 98.0, 26.0, "#F7F7FB", g.C_MAC_EDGE, "", lw=1.5, z=1.5)
    small(ax, 53.5, 112.0, "Port N   (N = 0..3; zcu102_hpc1: 0..1; kcu105_lpc: 0, 1, 3)",
          fs=8.4, ha="left", weight="bold", color=TXT)

    dma_x, dma_w, dma_y0, dma_h = 55.0, 22.0, 90.0, 19.0
    titled_box(ax, dma_x, dma_y0, dma_w, dma_h, g.C_DMA_FILL, g.C_DMA_EDGE,
               "axi_ethernet_N_dma",
               "AXI DMA, scatter-gather\nunaligned transfers (DRE)\n\n"
               "M_AXI_SG / MM2S / S2MM\n→ axi_smc\nS_AXI_LITE ← interconnect\n"
               "mm2s_introut, s2mm_introut",
               title_fs=8.4, body_fs=6.5, txtcolor="#FFFFFF", title_dy=2.4, z=3)
    mac_x, mac_w = 92.0, 30.0
    titled_box(ax, mac_x, dma_y0, mac_w, dma_h, g.C_MAC_FILL, g.C_MAC_EDGE,
               "axi_ethernet_N",
               "AXI Ethernet Subsystem\nPHY_TYPE RGMII\nTXCSUM / RXCSUM Full\n\n"
               "s_axi ← interconnect (256 KB)\nmac_irq, interrupt\n"
               "SupportLevel 1 (shared logic)\non one port, 0 on the others",
               title_fs=8.4, body_fs=6.5, title_dy=2.4, z=3)
    yc = dma_y0 + dma_h / 2
    harrow(ax, dma_x + dma_w, mac_x, yc + 4.5, "s_axis_txd / txc",
           g.C_AXARR_FILL, g.C_AXARR_EDGE, double=False, bh=1.4, hh=2.5, hl=1.6,
           fs=6.3)
    harrow(ax, mac_x, dma_x + dma_w, yc - 4.5, "m_axis_rxd / rxs",
           g.C_AXARR_FILL, g.C_AXARR_EDGE, double=False, bh=1.4, hh=2.5, hl=1.6,
           fs=6.3)
    small(ax, (dma_x + dma_w + mac_x) / 2, dma_y0 + dma_h / 2,
          "AXIS + DMA resets", fs=6.0)

    # AXI-Lite drops and the DMA data path
    route(ax, [(45.0, 118.0), (45.0, 116.0), (dma_x + 4.0, 116.0),
               (dma_x + 4.0, dma_y0 + dma_h)], g.C_CTRL_LINE, lw=1.3)
    route(ax, [(45.0, 116.0), (mac_x + 20.0, 116.0), (mac_x + 20.0, dma_y0 + dma_h)],
          g.C_CTRL_LINE, lw=1.3)
    route(ax, [(dma_x + 6.0, dma_y0), (dma_x + 6.0, 87.0), (38.0, 87.0),
               (38.0, 83.0)], g.C_AXARR_EDGE, lw=1.6)
    small(ax, 31.0, 88.6, "3 × AXI4 → axi_smc", fs=6.3, ha="left")
    ax.add_line(Line2D([mac_x + 6.0, mac_x + 6.0, 48.5, 48.5],
                       [dma_y0, 85.3, 85.3, 62.75], color=C_IRQ, lw=1.3, zorder=3))
    ax.add_line(Line2D([dma_x + 14.0, dma_x + 14.0], [dma_y0, 85.3], color=C_IRQ,
                       lw=1.3, zorder=3))
    route(ax, [(48.5, 62.75), (46.0, 62.75)], C_IRQ, lw=1.3)
    small(ax, 79.0, 84.4, "interrupts → xlconcat", fs=6.0, color=C_IRQ)

    # external ports of the chain
    ext_x0 = 128.0
    for i, (name, desc) in enumerate((("rgmii_port_N", "RGMII to PHY N"),
                                      ("mdio_io_port_N", "MDIO to PHY N"),
                                      ("reset_port_N", "phy_rst_n"))):
        y = 106.0 - i * 6.5
        box(ax, ext_x0, y - 2.4, 20.5, 4.8, g.C_CAGE_FILL, g.C_FMC_EDGE, "",
            lw=1.0, z=3)
        small(ax, ext_x0 + 10.25, y + 0.6, name, fs=6.9, weight="bold", color=TXT)
        small(ax, ext_x0 + 10.25, y - 1.3, desc, fs=6.0)
        harrow(ax, mac_x + mac_w, ext_x0, y, "", g.C_LINKARR_FILL, g.C_LINKARR_EDGE,
               double=False, bh=0.8, hh=1.6, hl=1.2)

    # clocking
    titled_box(ax, 55.0, 66.5, 40.0, 17.0, g.C_CLK_FILL, g.C_CLK_EDGE,
               "clk_wiz_0",
               "CLK_IN1_D ← ref_clk (125 MHz, from the FMC)\n"
               "clk_out1 125 MHz → gtx_clk of the shared-logic\n"
               "port (Zynq-7000 / MicroBlaze: also axis_clk + DMA)\n"
               "clk_out2 200 / 333.333 MHz → ref_clk (IDELAYCTRL)\n"
               "of the shared-logic port\n"
               "(+ clk_wiz_1 for the second FMC on 8-port designs)",
               title_fs=8.4, body_fs=6.3, title_dy=2.3, z=3)
    titled_box(ax, 100.0, 66.5, 22.0, 17.0, g.C_CLK_FILL, g.C_CLK_EDGE,
               "shared logic",
               "the shared-logic port\nforwards gtx_clk_out\nand gtx_clk90_out\n"
               "to the gtx_clk / gtx_clk90\ninputs of the other ports",
               title_fs=8.2, body_fs=6.3, title_dy=2.3, z=3)
    for i, (name, desc) in enumerate((("ref_clk", "diff. clock in, 125 MHz"),
                                      ("ref_clk_oe", "ilconstant → osc. enable"),
                                      ("ref_clk_fsel", "ilconstant → osc. select"))):
        y = 80.0 - i * 6.0
        box(ax, ext_x0, y - 2.4, 20.5, 4.8, g.C_CAGE_FILL, g.C_CLK_EDGE, "",
            lw=1.0, z=3)
        small(ax, ext_x0 + 10.25, y + 0.6, name, fs=6.9, weight="bold", color=TXT)
        small(ax, ext_x0 + 10.25, y - 1.3, desc, fs=6.0)
    refclk_arrow(ax, (ext_x0, 80.0), (95.0, 80.0), "", None)

    # ---- external: Ethernet FMC ------------------------------------------------
    fmc_x0 = 156.0
    titled_box(ax, fmc_x0, 56.0, 37.0, 78.5, g.C_FMC_FILL, g.C_FMC_EDGE,
               "Ethernet FMC",
               "port N PHY:\nMarvell gigabit PHY\nMDIO address 0,\n"
               "one MDIO bus per port\n\n"
               "Linux device tree\n(port-config.dtsi):\nphy-mode rgmii-rxid,\n"
               "MAC 00:0a:35:00:01:22\n+ port number\n\n"
               "125 MHz oscillator\n→ ref_clk\n\n"
               "pin locations:\nVivado/src/constraints/\n<target>.xdc",
               title_fs=10.0, body_fs=7.2, title_dy=3.2, lw=1.3)

    # ---- per-family tables ------------------------------------------------------
    box(ax, 2.0, 1.5, 191.0, 51.5, "#FFFFFF", g.C_FAB_EDGE, "", lw=1.1, z=1)
    table(ax, 4.0, 49.5,
          "Address map seen by the processor (from the built designs)",
          [("axi_ethernet_0", "0xA000_0000", "0x4100_0000", "0x40C0_0000"),
           ("axi_ethernet_1", "0xA008_0000", "0x4104_0000", "0x40C4_0000"),
           ("axi_ethernet_2", "0xA00C_0000", "0x4108_0000", "0x40C8_0000"),
           ("axi_ethernet_3", "0xA010_0000", "0x410C_0000", "0x40CC_0000"),
           ("axi_ethernet_0_dma", "0xA004_0000", "0x4040_0000", "0x41E0_0000"),
           ("axi_ethernet_1_dma", "0xA005_0000", "0x4041_0000", "0x41E1_0000"),
           ("axi_ethernet_2_dma", "0xA006_0000", "0x4042_0000", "0x41E2_0000"),
           ("axi_ethernet_3_dma", "0xA007_0000", "0x4043_0000", "0x41E3_0000"),
           ("MAC: 256 KB, DMA: 64 KB", "", "", "")],
          col_x=(0.0, 27.0, 45.0, 63.0),
          header=("cell", "Zynq US+", "Zynq-7000", "MicroBlaze"))
    small(ax, 4.0, 5.0,
          "MicroBlaze also maps axi_uart16550_0 0x44A0_0000, axi_timer_0 0x41C0_0000, "
          "microblaze_0_axi_intc 0x4120_0000, iic_main 0x4080_0000.",
          fs=6.4, ha="left")

    table(ax, 88.0, 49.5, "Clocks (MHz)",
          [("AXI-Lite (MACs, DMAs)", "100", "100", "100", "100"),
           ("AXIS + DMA data", "100 (pl_clk0)", "125", "125", "250"),
           ("gtx_clk (RGMII TX)", "125", "125", "125", "125"),
           ("IDELAYCTRL ref_clk", "333.333", "200", "200", "333.333")],
          col_x=(0.0, 30.0, 49.0, 63.0, 79.0),
          header=("", "Zynq US+", "Zynq-7000", "MB 7-series", "MB UltraScale"))

    table(ax, 88.0, 31.0, "Shared-logic port (config/data.json \"sharedlogic\")",
          [("port 2", "uzev, zcu102_hpc0"),
           ("port 1", "zedboard"),
           ("port 0", "all other targets (8-port designs: ports 0 and 4)")],
          col_x=(0.0, 14.0))

    small(ax, 88.0, 20.5,
          "Variants:  zc702_lpc2_lpc1 uses bd_zc702-dual.tcl (8 MACs with AXI FIFOs "
          "instead of DMAs, no checksum offload)\n"
          "pz_7015: frame filter and statistics counters disabled to save LUTs.  "
          "8-port designs add a second clk_wiz\n"
          "and axi_smc_extra.  KC705 also has axi_ethernetlite on the board Ethernet port.",
          fs=6.6, ha="left", va="top")

    out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "axi-eth-bd-diagram.png")
    fig.savefig(out, bbox_inches="tight", pad_inches=0.15, facecolor="white")
    print("wrote", out)


if __name__ == "__main__":
    main()
