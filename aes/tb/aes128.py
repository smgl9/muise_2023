# Libraries
# =============================================================================
from cocotb_test.simulator import run
import pytest
import os
import glob
import  cocotb
from cocotb.triggers         import  Timer, RisingEdge, ClockCycles
from cocotb.result           import  TestFailure, TestSuccess
from cocotb.clock            import  Clock
from cocotb_bus.drivers.amba import  AXI4LiteMaster, AXIProtocolError
from cocotb_bus.scoreboard import Scoreboard
from cocotbext.axi4stream.drivers import Axi4StreamMaster, Axi4StreamSlave
from cocotbext.axi4stream.monitors import Axi4Stream
import  numpy as np
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

# Constants
#==============================================================================
CLK_PERIOD = 10     # ns

BASEADDRESS = 0x40000000

capture_size = 50

# Functions
#==============================================================================
def check(dut, actual_value, expected_value):
    if int(actual_value) != int(expected_value):
        return 0
    else:
        return 1

#==============================================================================
class TB(object):
    def __init__(self, dut, NumbersVector_in, output_mon_in):
        self.dut = dut
        # Output monitor
        self.output_mon = output_mon_in
        self.expected_output = []
        self.index = 0

        self.expected_output = NumbersVector_in
        self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.output_mon, self.expected_output, compare_fn=self.compare)

    def compare(self,data):        

        if self.expected_output[self.index] != data:
            print ("Data_expected: ", hex(self.expected_output[self.index]), "    Data_generated: ",hex(data))
            raise TestFailure("Error...")
            pass
        else:           
            print ("Data_expected: ", hex(self.expected_output[self.index]), "   Data_generated: ", hex(data))

        self.index = self.index + 1

#==============================================================================
@cocotb.test(skip = False, stage = 1)
def aes_top(dut):

    # Set clock
    axis_clk_100MHz = Clock(dut.axis_aclk, CLK_PERIOD, units='ns')
    axil_clk_100MHz = Clock(dut.axi_aclk, CLK_PERIOD, units='ns')
    cocotb.start_soon(axis_clk_100MHz.start(start_high=False))
    cocotb.start_soon(axil_clk_100MHz.start(start_high=False))
    
    # Setting init values
    dut.s_axis_tdata.value = 0
    dut.s_axis_tvalid.value = 0
    dut.axis_aresetn.value = 0
    dut.axi_aresetn.value = 0

    # Constructor of a AXI Lite Master driver
    axil_m = AXI4LiteMaster(dut, "s_axi", dut.axi_aclk)
    axis_m = Axi4StreamMaster(dut, "s_axis", dut.axis_aclk)
    axis_s = Axi4StreamSlave(dut, "m_axis", dut.axis_aclk)
    output_mon = Axi4Stream(dut, "m_axis", dut.axis_aclk, data_type="integer", packets=False)

    # Write mode and key to AES core
    mode = 0
    key_int = 0xbebecafe
    key = key_int.to_bytes(4,'big') # 32bits key will be replicated to form a 128 key. s = key.decode('utf-8')
    key4 = key+key+key+key
    dut._log.info("key value: 0x%02X" % (int.from_bytes(key4, 'big') ))

    NumbersVector = np.arange(0,int(capture_size),1)
    expected_output = []
    
    # Expected output
    for i in range (capture_size):
        cipher = AES.new(key4, AES.MODE_ECB)
        ciphertext = cipher.encrypt(i.to_bytes(16,'big'))
        dut._log.info("Encrypted value: 0x%02X" % (int.from_bytes(ciphertext, 'big') ))
        expected_output=np.append(expected_output,int.from_bytes(ciphertext, 'big'))
        cipher = AES.new(key4, AES.MODE_ECB)
        plaintext = cipher.decrypt(ciphertext)
        dut._log.info("Decrypted value: 0x%02X" % (int.from_bytes(plaintext, 'big') ))
    
    tb = TB(dut, expected_output, output_mon)

    # Deassert reset
    yield Timer(10*CLK_PERIOD, units='ns')
    dut.axis_aresetn = 1
    dut.axi_aresetn.value = 1
    yield Timer(10*CLK_PERIOD, units='ns')


    yield axil_m.write(BASEADDRESS + 0x0, mode)
    for i in range(4):
        yield axil_m.write(BASEADDRESS +0x4 + i*4, key_int)
    yield Timer(10*CLK_PERIOD, units='ns')

    # Send streaming data
    cocotb.start_soon(axis_m.write(NumbersVector.tolist()))
    yield Timer(1000*CLK_PERIOD, units='ns')
