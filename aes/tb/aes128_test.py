from cocotb_test.simulator import run
import pytest
import os
import glob

dir = os.path.dirname(os.path.abspath(__file__))
sources_list = glob.glob(dir+"/../src/*.vhd")

def test_axis2axi_ghdl():
    run(
        vhdl_sources=[os.path.join(dir,file)
            for file in sources_list],       # sources
        toplevel="aes_top",            # top level HDL
        module="aes128",                  # name of cocotb test module
        toplevel_lang="vhdl",
        compile_args=["--ieee=synopsys","--std=08"],
        sim_args=["--wave=wave.ghw"]
    )
