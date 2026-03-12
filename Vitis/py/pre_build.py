"""Pre-build fixup required for lwip_echo_server template apps with AXI Ethernet.

Fix: wrong MAC selected when both GEM and AXI Ethernet are present (Vitis 2025.2)
  The template's lwip_echo_server.cmake builds TOTAL_MAC_INSTANCES by appending
  EMACPS instances before AXIETHERNET instances. When multiple MACs exist, it
  picks index 0 — which is always the PS GEM. This causes platform_config.h to
  be generated with PLATFORM_EMAC_BASEADDR pointing to the GEM (e.g. 0xe000b000)
  instead of the AXI Ethernet. The echo server then calls the GEM PHY speed
  functions (xemacpsif_physpeed.c) instead of the AXI Ethernet ones
  (xaxiemacif_physpeed.c), and DHCP/TCP never works on the intended port.
  This script patches platform_config.h.in to replace the cmake-generated
  PLATFORM_EMAC_BASEADDR with the contents of port_config.h, which selects
  the correct AXI Ethernet port via XPAR_AXI_ETHERNET_N_BASEADDR defines.
  The content is inlined because platform_config.h is generated into
  build/include/ where it cannot resolve #include paths to files in src/.

Usage: called by build-vitis.py with app_src as the first argument.
"""

import os, sys

def main():
    if len(sys.argv) < 2:
        print("Usage: pre_build.py <app_src_dir>")
        sys.exit(1)

    app_src = sys.argv[1]
    config_in = os.path.join(app_src, "platform_config.h.in")

    if not os.path.isfile(config_in):
        print(f"WARNING: {config_in} not found; skipping patch")
        return

    with open(config_in, "r") as f:
        content = f.read()

    old = "#cmakedefine PLATFORM_EMAC_BASEADDR @PLATFORM_EMAC_BASEADDR@"

    if old not in content:
        print(f"NOTE: cmake PLATFORM_EMAC_BASEADDR line not found in {config_in}; skipping")
        return

    # Read port_config.h and inline its content
    port_config = os.path.join(app_src, "port_config.h")
    if not os.path.isfile(port_config):
        print(f"WARNING: {port_config} not found; skipping patch")
        return

    with open(port_config, "r") as f:
        port_config_content = f.read()

    content = content.replace(old, port_config_content)
    with open(config_in, "w") as f:
        f.write(content)
    print(f"Patched {config_in}: inlined port_config.h content")

if __name__ == "__main__":
    main()
