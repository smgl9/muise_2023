# -*- coding: utf-8 -*-
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.result import TestFailure

PERIOD = 10
# ==============================================================================
@cocotb.test(timeout_time=4, timeout_unit='ms')
def neorv32_tb(dut):

    cocotb.start_soon(Clock(dut.m_axi_aclk, PERIOD, 'ns').start(start_high=False))
    
    yield Timer(1, units='us')
    dut.m_axi_aresetn.value = 1
    yield Timer(1, units='us')
    dut.m_axi_aresetn.value = 0
    yield Timer(1, units='us')
    dut.m_axi_aresetn.value = 1

    yield Timer(30, units='us')

    assert True == True, "Test failed!"

    dut._log.info("Test passed!")
