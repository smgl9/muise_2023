TOPLEVEL_LANG=vhdl
VHDL_SOURCES = $(PWD)/*.vhd
VHDL_SOURCES += $(PWD)/../rtl/core/*.vhd
VHDL_SOURCES += $(PWD)/../rtl/core/mem/*.vhd
VHDL_SOURCES += $(PWD)/../rtl/system_integration/*.vhd

TOPLEVEL=neorv32_wrapper
MODULE=neorv32_tb
COMPILE_ARGS=--std=08 -frelaxed-rules --ieee=synopsys --no-vital-checks 
SIM=ghdl
SIM_ARGS=--wave=wave.ghw --ieee-asserts=disable
include $(shell cocotb-config --makefiles)/Makefile.sim
