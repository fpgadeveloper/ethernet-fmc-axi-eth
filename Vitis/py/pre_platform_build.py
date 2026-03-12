"""Pre-platform-build fixups required for lwip_echo_server template apps.

Fix: xiltimer tick timer not assigned (Vitis 2025.2 SDT)
  The BSP's xtimer_config.h is generated with XTIMER_NO_TICK_TIMER=1 and all
  XTICKTIMER_IS_* macros undefined, even when XILTIMER_en_interval_timer is
  set to true in the BSP config. Without a tick timer, the lwip timer callback
  (registered via XTimer_SetHandler in platform.c) never fires, so DHCP
  timeouts, TCP timers, and link detection all stop working. The echo server
  hangs after PHY autonegotiation completes.
  This script assigns XILTIMER_tick_timer to the appropriate hardware timer
  for each architecture so that xtimer_config.h is generated correctly.

Called by build-vitis.py with platform, domain_name, and arch as kwargs.
"""

TICK_TIMER_MAP = {
    "zynq":       "ps7_scutimer_0",
    "zynqmp":     "psu_ttc_0",
    "versal":     "psv_ttc_0",
    "microblaze": "axi_timer_0",
}

def pre_platform_build(platform, domain_name, arch):
    tick_timer = TICK_TIMER_MAP.get(arch)
    if tick_timer:
        print(f"Setting tick timer: {tick_timer} (for {arch})")
        domain = platform.get_domain(domain_name)
        domain.set_config(option="lib", param="XILTIMER_tick_timer",
                          value=tick_timer, lib_name="xiltimer")
