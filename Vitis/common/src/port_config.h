/*
 * port_config.h — Ethernet FMC port selection
 *
 * Change ETHERNET_PORT to select which Ethernet FMC port to use.
 * Valid values: 0, 1, 2, 3
 */

#ifndef PORT_CONFIG_H
#define PORT_CONFIG_H

#define ETHERNET_PORT 0

#include "xparameters.h"

#if ETHERNET_PORT == 0
#define PLATFORM_EMAC_BASEADDR XPAR_AXI_ETHERNET_0_BASEADDR
#elif ETHERNET_PORT == 1
#define PLATFORM_EMAC_BASEADDR XPAR_AXI_ETHERNET_1_BASEADDR
#elif ETHERNET_PORT == 2
#define PLATFORM_EMAC_BASEADDR XPAR_AXI_ETHERNET_2_BASEADDR
#elif ETHERNET_PORT == 3
#define PLATFORM_EMAC_BASEADDR XPAR_AXI_ETHERNET_3_BASEADDR
#else
#error "Invalid ETHERNET_PORT value. Must be 0, 1, 2, or 3."
#endif

#endif
