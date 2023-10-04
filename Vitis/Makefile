# Opsero Electronic Design Inc. 2023
#
# This Makefile can be used to build the Vitis workspace.

CP = cp -rf
MKDIR = mkdir -p
RM = rm -rf
ROOT_DIR = $(shell pwd)
XSCT = $(XILINX_VITIS)/bin/xsct
BD_NAME = axieth
APP_POSTFIX = _echo_server
SYS_POSTFIX = $(APP_POSTFIX)_system

# defaults
.DEFAULT_GOAL := workspace
TARGET ?= none
JOBS ?= 8

# valid targets
ac701_target := 0
kc705_hpc_target := 0
kc705_lpc_target := 0
kc705_lpc_hpc_target := 0
kcu105_dual_target := 0
kcu105_hpc_target := 0
kcu105_lpc_target := 0
mz_7020_target := 0
pz_7015_target := 0
pz_7020_target := 0
pz_7030_target := 0
uzev_target := 0
vc707_hpc1_target := 0
vc707_hpc2_target := 0
vc707_hpc2_hpc1_target := 0
vc709_target := 0
vcu108_hpc0_target := 0
vcu108_hpc1_target := 0
vcu118_target := 0
zc702_lpc1_target := 0
zc702_lpc2_target := 0
zc702_lpc2_lpc1_target := 0
zc706_lpc_target := 0
zcu102_hpc0_target := 0
zcu102_hpc1_target := 0
zedboard_target := 0

TARGET_LIST := $(patsubst %_target,%,$(filter %_target,$(.VARIABLES)))

# Vitis paths
VIT_SCRIPT_WS = tcl/build-vitis.tcl

# Vivado paths
VIV_DIR = $(ROOT_DIR)/../Vivado
VIV_PRJ_DIR = $(VIV_DIR)/$(TARGET)
VIV_XSA = $(VIV_PRJ_DIR)/$(BD_NAME)_wrapper.xsa

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make workspace TARGET=<target> JOBS=<val>'
	@echo '    Create the Vitis workspace and add applications for specified target.'
	@echo ''
	@echo '  make all JOBS=<val>'
	@echo '    Create the Vitis workspace and add applications for all targets.'
	@echo ''
	@echo '  make clean'
	@echo '    Delete the Vitis workspace and all applications.'
	@echo ''
	@echo 'Parameters:'
	@echo ''
	@echo '  TARGET: Name of the target design, must be one of the following:'
	@$(foreach targ,$(sort $(TARGET_LIST)),echo "    - $(targ)";)
	@echo ''
	@echo '  JOBS: Optional param to set number of synthesis jobs (default 8)'
	@echo ''
	@echo 'Example usage:'
	@echo '  make workspace TARGET=$(word 1,$(TARGET_LIST))'
	@echo ''

.PHONY: all
all:
	for targ in $(TARGET_LIST); do \
		$(MAKE) workspace TARGET=$$targ; \
	done

.PHONY: workspace
workspace: check_target $(VIV_XSA)
	$(XSCT) $(VIT_SCRIPT_WS) $(TARGET)

$(VIV_XSA):
	$(MAKE) -C $(VIV_DIR) xsa TARGET=$(TARGET) JOBS=$(JOBS)

.PHONY: clean
clean:
	for targ in $(TARGET_LIST); do \
		$(RM) $${targ} $${targ}$(APP_POSTFIX) $${targ}$(SYS_POSTFIX); \
	done
	$(RM) boot .metadata .Xil IDE.log .analytics updatemem*.jou updatemem*.log RemoteSystemsTempFiles embeddedsw

check_target:
ifndef $(TARGET)_target
	$(error "Please specify a TARGET. Use 'make help' to see valid targets.")
endif


