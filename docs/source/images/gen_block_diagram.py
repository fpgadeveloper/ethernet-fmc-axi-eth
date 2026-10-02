#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Opsero Electronic Design Inc.
"""
Generate the block diagram for the Opsero AXI Ethernet reference designs for the
Ethernet FMC (OP031) and Robust Ethernet FMC (OP041).

Each of the four Ethernet FMC ports is an independent chain: RJ45 -> Marvell
gigabit PHY on the FMC -> RGMII + MDIO over the FMC connector -> one AXI Ethernet
Subsystem (tri-mode MAC, RGMII, full TX/RX checksum offload) -> one AXI DMA
(scatter-gather) -> AXI SmartConnect -> the processor's DDR. The processor reaches
the MAC and DMA registers over an AXI-Lite interconnect. The 125 MHz oscillator on
the FMC feeds a clock wizard that makes the 125 MHz RGMII transmit clock and the
IDELAY reference clock. The processor column covers the three families the
repository supports (Zynq UltraScale+, Zynq-7000, MicroBlaze); on the Zynq-based
boards the carrier's own Ethernet port (PS GEM) is also used under Linux.

The output PNG is written next to this script (i.e. into docs/source/images/):
    axi-eth-block-diagram.png

The palette and drawing helpers are shared with gen_bd_diagram.py (and with the
block diagrams of the other Opsero reference designs).

Usage (from anywhere):
    python3 docs/source/images/gen_block_diagram.py
"""

import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon, FancyBboxPatch, FancyArrowPatch
from matplotlib.lines import Line2D

# ---- palette (shared with the other Opsero reference-design block diagrams) --
C_PS_FILL      = "#D9D9D9"; C_PS_EDGE      = "#7F7F7F"   # processor / DDR column
C_FAB_FILL     = "#F2F2F2"; C_FAB_EDGE     = "#BFBFBF"   # FPGA fabric container
C_DMA_FILL     = "#808080"; C_DMA_EDGE     = "#404040"   # AXI DMA (dark grey)
C_MAC_FILL     = "#E8E8F2"; C_MAC_EDGE     = "#8C8CC0"   # MAC logic (lavender)
C_GT_FILL      = "#F3EFE2"; C_GT_EDGE      = "#BFB585"   # interconnect / hard blocks
C_FMC_FILL     = "#DCE6F2"; C_FMC_EDGE     = "#9DB7D4"   # external FMC (blue-grey)
C_CAGE_FILL    = "#FFFFFF"                                # PHY / RJ45 (white on FMC)
C_CLK_FILL     = "#FDE9D9"; C_CLK_EDGE     = "#E0B090"   # clocking (peach)
C_CTRL_FILL    = "#ECECEC"; C_CTRL_EDGE    = "#BFBFBF"   # control plane
C_AXARR_FILL   = "#EDF3D4"; C_AXARR_EDGE   = "#A6B85A"   # data arrows (pale green)
C_LINKARR_FILL = "#DAE8F5"; C_LINKARR_EDGE = "#6F9FCF"   # link arrows (pale blue)
C_REFCLK_LINE  = "#C8823C"                                # refclk arrows (orange)
C_CTRL_LINE    = "#8C8C8C"                                # AXI-Lite drops
TXT = "#1A1A1A"


def box(ax, x, y, w, h, fc, ec, label, fs=10, rot=0, lw=1.2, weight="normal",
        round_=False, txtcolor=None, ls="-", z=2):
    if round_:
        p = FancyBboxPatch((x + 0.4, y + 0.4), w - 0.8, h - 0.8,
                           boxstyle="round,pad=0.0,rounding_size=1.2",
                           fc=fc, ec=ec, lw=lw, ls=ls, zorder=z)
    else:
        p = plt.Rectangle((x, y), w, h, fc=fc, ec=ec, lw=lw, ls=ls, zorder=z)
    ax.add_patch(p)
    if label:
        ax.text(x + w / 2, y + h / 2, label, ha="center", va="center",
                fontsize=fs, rotation=rot, color=txtcolor or TXT, weight=weight,
                zorder=z + 1, linespacing=1.25)


def titled_box(ax, x, y, w, h, fc, ec, title, body, title_fs=9.5, body_fs=7.6,
               lw=1.2, txtcolor=None, title_dy=2.6, ls="-", z=2):
    """A box() with a bold title line at the top and a smaller body below it."""
    box(ax, x, y, w, h, fc, ec, "", lw=lw, ls=ls, z=z)
    cx = x + w / 2
    ax.text(cx, y + h - title_dy, title, ha="center", va="center",
            fontsize=title_fs, weight="bold", color=txtcolor or TXT, zorder=z + 1)
    ax.text(cx, y + (h - title_dy * 1.9) / 2, body, ha="center", va="center",
            fontsize=body_fs, color=txtcolor or TXT, zorder=z + 1, linespacing=1.3)


def harrow(ax, x0, x1, yc, label, fc, ec, double=True, bh=2.0, hh=3.4, hl=3.2,
           fs=8.5, lw=1.1, lab_dy=0.0, lab_color=None, weight="normal"):
    """Horizontal block arrow from x0 to x1.

    double=True  : double-headed (requires x0 < x1).
    double=False : single-headed with the head at x1; works in either
                   direction (x1 may be < x0 for a leftward arrow).
    """
    if double:
        pts = [(x0, yc), (x0 + hl, yc + hh), (x0 + hl, yc + bh),
               (x1 - hl, yc + bh), (x1 - hl, yc + hh), (x1, yc),
               (x1 - hl, yc - hh), (x1 - hl, yc - bh),
               (x0 + hl, yc - bh), (x0 + hl, yc - hh)]
    else:
        s = 1.0 if x1 >= x0 else -1.0
        neck = x1 - s * hl
        pts = [(x0, yc + bh), (neck, yc + bh), (neck, yc + hh),
               (x1, yc), (neck, yc - hh), (neck, yc - bh), (x0, yc - bh)]
    ax.add_patch(Polygon(pts, closed=True, fc=fc, ec=ec, lw=lw, zorder=2))
    if label:
        ax.text((x0 + x1) / 2, yc + lab_dy, label, ha="center", va="center",
                fontsize=fs, color=lab_color or TXT, zorder=3, linespacing=1.15,
                weight=weight)


def varrow(ax, xc, y0, y1, fc, ec, double=True, bw=1.4, hw=2.6, hl=2.4, lw=1.1):
    """Vertical block arrow from y0 to y1 (head at y1; both ends if double)."""
    if double:
        lo, hi = min(y0, y1), max(y0, y1)
        pts = [(xc, lo), (xc + hw, lo + hl), (xc + bw, lo + hl),
               (xc + bw, hi - hl), (xc + hw, hi - hl), (xc, hi),
               (xc - hw, hi - hl), (xc - bw, hi - hl),
               (xc - bw, lo + hl), (xc - hw, lo + hl)]
    else:
        s = 1.0 if y1 >= y0 else -1.0
        neck = y1 - s * hl
        pts = [(xc - bw, y0), (xc - bw, neck), (xc - hw, neck), (xc, y1),
               (xc + hw, neck), (xc + bw, neck), (xc + bw, y0)]
    ax.add_patch(Polygon(pts, closed=True, fc=fc, ec=ec, lw=lw, zorder=2))


def route(ax, pts, color, lw=1.8):
    """Thin elbow arrow through the points in pts (head at the last point)."""
    xs, ys = zip(*pts[:-1])
    ax.add_line(Line2D(xs, ys, color=color, lw=lw, zorder=3,
                       solid_capstyle="butt", solid_joinstyle="miter"))
    ax.add_patch(FancyArrowPatch(pts[-2], pts[-1], arrowstyle="-|>",
                                 mutation_scale=11, lw=lw, color=color,
                                 zorder=3, shrinkA=0, shrinkB=0))


def refclk_arrow(ax, p0, p1, label, lab_xy, fs=7.8, lw=1.9):
    """Thin single-line arrow (head at p1) for a single clock net."""
    ax.add_patch(FancyArrowPatch(p0, p1, arrowstyle="-|>", mutation_scale=13,
                                 lw=lw, color=C_REFCLK_LINE, zorder=3,
                                 shrinkA=0, shrinkB=0))
    if label:
        ax.text(lab_xy[0], lab_xy[1], label, ha="center", va="center",
                fontsize=fs, color=C_REFCLK_LINE, zorder=4, weight="bold",
                linespacing=1.2)


def main():
    fig, ax = plt.subplots(figsize=(19.5, 13.0), dpi=120)
    ax.set_xlim(0, 195)
    ax.set_ylim(0, 130)
    ax.axis("off")

    # vertical plan: clock strip 4-19, port rows 23..103, AXI-Lite bar 108-114
    row_h, row_gap = 17.0, 3.0
    rows_y0 = [86.0, 66.0, 46.0, 26.0]          # port 0 .. port 3 (top to bottom)
    lite_y0, lite_y1 = 107.5, 114.0

    # ---- processor column ------------------------------------------------------
    ps_x0, ps_w = 2.0, 19.0
    ps_r = ps_x0 + ps_w
    cx = ps_x0 + ps_w / 2
    titled_box(ax, ps_x0, 108.0, ps_w, 16.0, C_PS_FILL, C_PS_EDGE, "DDR memory",
               "on the carrier board\n(PS DDR, or DDR3 / DDR4\nthrough the MIG on\n"
               "MicroBlaze boards)", title_fs=10.5, body_fs=7.2, title_dy=3.0, lw=1.3)
    varrow(ax, cx, 104.0, 108.0, C_AXARR_FILL, C_AXARR_EDGE, double=True,
           bw=1.2, hw=2.3, hl=1.6)
    box(ax, ps_x0, 33.0, ps_w, 71.0, C_PS_FILL, C_PS_EDGE, "", lw=1.3)
    ax.text(cx, 99.0, "Processor", ha="center", va="center", fontsize=12,
            weight="bold", color=TXT)
    ax.text(cx, 73.0,
            "Zynq UltraScale+ PS\nCortex-A53\nZCU102, UltraZed-EV\n\n"
            "Zynq-7000 PS\nCortex-A9\nZC702, ZC706,\nZedBoard, PicoZed\n\n"
            "MicroBlaze soft CPU\n+ MIG, AXI UART16550,\nAXI Timer, AXI INTC\n"
            "AC701, KC705, VC707,\nVC709, KCU105,\nVCU108, VCU118",
            ha="center", va="center", fontsize=7.5, color=TXT, linespacing=1.35)
    ax.text(cx, 41.5,
            "Software:\nlwIP echo server\n(standalone), or\nLinux (Zynq / Zynq US+:\n"
            "PetaLinux, Yocto)",
            ha="center", va="center", fontsize=7.2, color="#404040",
            linespacing=1.35)

    # PS GEM + board RJ45 (Zynq-based boards)
    titled_box(ax, ps_x0, 15.0, ps_w, 14.5, C_PS_FILL, C_PS_EDGE,
               "PS GEM",
               "Zynq-7000: GEM0\nZynq US+: GEM3\nboard Ethernet port\n(Linux: SSH, DHCP)",
               title_fs=9.0, body_fs=6.9, title_dy=2.4, lw=1.3)
    varrow(ax, cx, 29.5, 33.0, C_PS_FILL, C_PS_EDGE, double=True,
           bw=1.0, hw=2.0, hl=1.3)
    titled_box(ax, ps_x0, 1.5, ps_w, 10.5, C_CAGE_FILL, C_LINKARR_EDGE,
               "Board RJ45",
               "PHY on the carrier\n(not on the FMC)",
               title_fs=8.6, body_fs=6.9, title_dy=2.2, lw=1.2)
    varrow(ax, cx, 12.0, 15.0, C_LINKARR_FILL, C_LINKARR_EDGE, double=True,
           bw=1.0, hw=2.0, hl=1.2)

    # ---- FPGA fabric container -------------------------------------------------
    fab_x0, fab_x1 = 24.0, 125.0
    ax.add_patch(plt.Rectangle((fab_x0, 2.0), fab_x1 - fab_x0, 115.5,
                               fc=C_FAB_FILL, ec=C_FAB_EDGE, lw=1.3, zorder=1))
    ax.text((fab_x0 + fab_x1) / 2, 118.3, "FPGA fabric (PL)", ha="center",
            va="bottom", fontsize=13, weight="bold", color=TXT)

    # AXI-Lite control bar across the top
    lite_x0, lite_x1 = 38.0, 108.0
    titled_box(ax, lite_x0, lite_y0, lite_x1 - lite_x0, lite_y1 - lite_y0,
               C_CTRL_FILL, C_CTRL_EDGE,
               "AXI-Lite interconnect  (control: register access to every MAC and DMA)",
               "", title_fs=8.6, title_dy=(lite_y1 - lite_y0) / 2)
    harrow(ax, ps_r, lite_x0, (lite_y0 + lite_y1) / 2, "", C_CTRL_FILL, C_PS_EDGE,
           double=False, bh=1.4, hh=2.6, hl=2.0)
    ax.text((ps_r + lite_x0) / 2 + 0.5, lite_y1 + 2.6,
            "GP0 / HPM0 /\nMicroBlaze DP", ha="center", va="center",
            fontsize=6.8, color="#404040", linespacing=1.2)

    # AXI SmartConnect (DMA data path to DDR)
    smc_x, smc_w = 27.0, 5.0
    box(ax, smc_x, 24.5, smc_w, 80.0, C_GT_FILL, C_GT_EDGE,
        "AXI SmartConnect  (3 AXI masters per DMA: SG, MM2S, S2MM → DDR)", fs=8.2, rot=90,
        weight="bold", lw=1.3)
    harrow(ax, ps_r, smc_x, 64.0, "", C_AXARR_FILL, C_AXARR_EDGE,
           bh=1.6, hh=2.9, hl=1.6)
    ax.text((ps_r + smc_x) / 2, 70.2, "HP0 /\nMIG", ha="center", va="center",
            fontsize=7.0, color="#404040")

    # ---- the four port chains -----------------------------------------------------
    dma_x, dma_w = 36.0, 17.0
    dma_r = dma_x + dma_w
    mac_x, mac_w = 62.0, 46.0
    mac_r = mac_x + mac_w
    for p, y0 in enumerate(rows_y0):
        yc = y0 + row_h / 2
        titled_box(ax, dma_x, y0, dma_w, row_h, C_DMA_FILL, C_DMA_EDGE,
                   f"AXI DMA {p}",
                   "scatter-gather\nMM2S = TX\nS2MM = RX\n2 interrupts",
                   title_fs=8.8, body_fs=7.0, txtcolor="#FFFFFF", title_dy=2.6)
        harrow(ax, smc_x + smc_w, dma_x, yc, "", C_AXARR_FILL, C_AXARR_EDGE,
               bh=1.3, hh=2.4, hl=1.2)
        # AXIS: TX (data + control) to the MAC, RX (data + status) back
        harrow(ax, dma_r, mac_x, yc + 3.6, "TX", C_AXARR_FILL, C_AXARR_EDGE,
               double=False, bh=1.5, hh=2.7, hl=1.8, fs=7.0)
        harrow(ax, mac_x, dma_r, yc - 3.6, "RX", C_AXARR_FILL, C_AXARR_EDGE,
               double=False, bh=1.5, hh=2.7, hl=1.8, fs=7.0)

        box(ax, mac_x, y0, mac_w, row_h, "#F7F7FB", C_MAC_EDGE, "", lw=1.4)
        ax.text(mac_x + mac_w / 2, y0 + row_h - 2.3,
                f"AXI Ethernet Subsystem {p}", ha="center", va="center",
                fontsize=9.2, weight="bold", color=TXT, zorder=3)
        sub_y0, sub_h = y0 + 1.2, row_h - 5.2
        titled_box(ax, mac_x + 1.2, sub_y0, 17.0, sub_h, C_MAC_FILL, C_MAC_EDGE,
                   "Tri-mode MAC", "10/100/1000\nfull TX/RX\nchecksum offload",
                   title_fs=7.6, body_fs=6.5, title_dy=2.0, z=3)
        titled_box(ax, mac_x + 19.4, sub_y0, 13.4, sub_h, C_MAC_FILL, C_MAC_EDGE,
                   "RGMII", "TX clock 90°\nin the FPGA,\nRX delay in PHY",
                   title_fs=7.6, body_fs=6.5, title_dy=2.0, z=3)
        titled_box(ax, mac_x + 34.0, sub_y0, 10.8, sub_h, C_MAC_FILL, C_MAC_EDGE,
                   "MDIO", "PHY\nmanagement",
                   title_fs=7.6, body_fs=6.5, title_dy=2.0, z=3)
        harrow(ax, mac_r, fab_x1 + 9.5, yc, "", C_LINKARR_FILL, C_LINKARR_EDGE,
               bh=1.6, hh=2.9, hl=1.8)
    ax.text((mac_r + fab_x1) / 2 + 0.5, rows_y0[0] + row_h + 1.6,
            "RGMII + MDIO\n+ PHY reset", ha="center", va="center",
            fontsize=7.0, color=TXT, linespacing=1.15)
    # AXI-Lite bus line down the gap between the DMAs and the MACs
    bus_x = 57.5
    ax.add_line(Line2D([bus_x, bus_x], [lite_y0, rows_y0[-1] + row_h - 1.0],
                       color=C_CTRL_LINE, lw=1.4, ls=(0, (4, 2)), zorder=1.5))
    ax.text(bus_x + 0.8, (lite_y0 + rows_y0[0] + row_h) / 2,
            "AXI-Lite (dashed) to each DMA and MAC   ·   TX / RX arrows: AXI-Stream",
            ha="left", va="center", fontsize=6.6, color="#606060", zorder=3)

    # interrupt note
    ax.text(84.0, 22.6,
            "Interrupts: 4 per port (MAC, MAC IRQ, DMA MM2S, DMA S2MM) → concat → "
            "Zynq IRQ_F2P / ZynqMP pl_ps_irq / MicroBlaze AXI INTC",
            ha="center", va="center", fontsize=6.9, color="#404040", zorder=3)

    # ---- clocking strip -------------------------------------------------------------
    titled_box(ax, 36.0, 4.0, 86.0, 15.5, C_CLK_FILL, C_CLK_EDGE,
               "Clocking  (clk_wiz_0, input: 125 MHz from the Ethernet FMC)",
               "125 MHz  → gtx_clk (RGMII TX clock) of the shared-logic port, "
               "which forwards gtx_clk / gtx_clk90 to the other ports\n"
               "200 MHz (7-series) or 333.333 MHz (UltraScale / UltraScale+)  → "
               "IDELAYCTRL reference of the shared-logic port\n"
               "AXI-Lite: 100 MHz.  AXIS / DMA: 100 MHz (Zynq US+), 125 MHz "
               "(Zynq-7000, 7-series MicroBlaze), 250 MHz (UltraScale MicroBlaze)",
               title_fs=8.6, body_fs=7.0, title_dy=2.6)

    # ---- external: Ethernet FMC ---------------------------------------------------------
    fmc_x0, fmc_x1 = 128.0, 160.0
    fcx = (fmc_x0 + fmc_x1) / 2
    ax.add_patch(plt.Rectangle((fmc_x0, 2.0), fmc_x1 - fmc_x0, 115.5,
                               fc=C_FMC_FILL, ec=C_FMC_EDGE, lw=1.3, zorder=1))
    ax.text(177.0, 118.3, "External to FPGA", ha="center", va="bottom",
            fontsize=12, weight="bold", color=TXT)
    ax.text(fcx, 111.0,
            "Ethernet FMC (OP031)\nRobust Ethernet FMC (OP041)\n1.8 V or 2.5 V variant",
            ha="center", va="center", fontsize=8.6, weight="bold", color=TXT,
            linespacing=1.3)
    phy_x, phy_w = 134.5, 23.5
    for p, y0 in enumerate(rows_y0):
        yc = y0 + row_h / 2
        box(ax, phy_x, y0, phy_w, row_h, C_CAGE_FILL, C_FMC_EDGE, "", lw=1.2)
        ax.text(phy_x + phy_w / 2, y0 + row_h - 2.6, f"Port {p}",
                ha="center", va="center", fontsize=9.0, weight="bold", color=TXT,
                zorder=3)
        ax.text(phy_x + phy_w / 2, y0 + (row_h - 5.0) / 2,
                "Marvell gigabit PHY\nMDIO address 0\n(own MDIO bus)\n→ RJ45",
                ha="center", va="center", fontsize=6.9, color=TXT, zorder=3,
                linespacing=1.25)
        # 1000BASE-T to the link partner
        harrow(ax, fmc_x1, 172.5, yc, "", C_LINKARR_FILL, C_LINKARR_EDGE,
               bh=1.6, hh=2.9, hl=1.6)
    titled_box(ax, phy_x, 4.0, phy_w, 15.5, C_CLK_FILL, C_CLK_EDGE,
               "125 MHz oscillator",
               "LVDS ref_clk\nref_clk_oe and\nref_clk_fsel driven\nby the design",
               title_fs=8.0, body_fs=6.6, title_dy=2.4)
    refclk_arrow(ax, (phy_x, 11.75), (122.0, 11.75), "ref_clk", (128.5, 14.2),
                 fs=7.0)
    ax.text(fcx, 23.0, "FMC connector\n(LPC or HPC pins)", ha="center",
            va="center", fontsize=7.0, color="#404040", linespacing=1.2)

    # ---- link partner -----------------------------------------------------------------------
    titled_box(ax, 172.5, 26.0, 21.0, 77.0, C_CAGE_FILL, C_LINKARR_EDGE,
               "Link partner",
               "PC, switch or\nrouter on each\nport you test\n\n"
               "1000BASE-T\nCat5e / Cat6\n\n"
               "Linux tests:\niperf3 -s, ping,\nDHCP server\n\n"
               "Standalone test:\nping / telnet to\nthe lwIP echo\nserver (TCP 7)",
               title_fs=9.2, body_fs=7.2, title_dy=3.0, lw=1.3)

    out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "axi-eth-block-diagram.png")
    fig.savefig(out, bbox_inches="tight", pad_inches=0.15, facecolor="white")
    print("wrote", out)


if __name__ == "__main__":
    main()
