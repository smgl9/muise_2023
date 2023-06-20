from cocotb_test.simulator import run
import pytest
import os
import glob

dir = os.path.dirname(os.path.abspath(__file__))
core = glob.glob(dir+"/../rtl/core/*.vhd")
mem = glob.glob(dir+"/../rtl/core/mem/*.vhd")
system = glob.glob(dir+"/../rtl/system_integration/*.vhd")

def neorv32_test():
    run(
        vhdl_sources=[os.path.join(dir,"neorv32_wrapper_pkg.vhd"),
        os.path.join(dir,"neorv32_wrapper.vhd")]
        +[os.path.join(dir,file) for file in core]
        +[os.path.join(dir,file) for file in mem]
        +[os.path.join(dir,file) for file in system],
        toplevel="neorv32_wrapper",           
        module="neorv32_tb",
        toplevel_lang="vhdl",
        compile_args=["--ieee=synopsys","--std=08", "-frelaxed-rules", "--no-vital-checks"],
        sim_args=["--wave=wave.ghw"]
    )
