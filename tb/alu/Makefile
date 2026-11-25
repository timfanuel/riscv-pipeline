SIM ?= icarus
TOPLEVEL_LANG = verilog
WAVES ?= 1
PROJ_ROOT := $(abspath ../..)
VERILOG_SOURCES = $(PROJ_ROOT)/rtl/core/alu.sv
COCOTB_TOPLEVEL = alu
COCOTB_TEST_MODULES = test_alu
COMPILE_ARGS += -g2012
include $(shell cocotb-config --makefiles)/Makefile.sim