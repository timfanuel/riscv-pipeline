# cocotb Makefile for the flow-test multiplier.
# Usage:  make            (Icarus Verilog, default)
#         make SIM=verilator   (needs Verilator >= 5.036, e.g. from OSS CAD Suite)

SIM ?= icarus
TOPLEVEL_LANG = verilog
WAVES ?= 1

PROJ_ROOT := $(abspath ../..)
VERILOG_SOURCES = $(PROJ_ROOT)/rtl/flow_test/mul_shift_add.sv

COCOTB_TOPLEVEL = mul_shift_add
COCOTB_TEST_MODULES = test_mul_shift_add

ifeq ($(SIM),icarus)
  COMPILE_ARGS += -g2012
endif
ifeq ($(SIM),verilator)
  EXTRA_ARGS += --trace --trace-structs
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
