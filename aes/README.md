# AXI-streaming AES

The module receives a key and encrypt or decrypt the input data.
The mode select if the module works as an encryptor or decryptor

## Run tests:

```bash
cd tb
SIM=ghdl pytest -o log_cli=True aes128_test.py
```

### Test dependencies

cocotb-test
cocotb
cocotbext-axi4stream
cocotb-bus

`pip install git+https://github.com/cocotb/cocotb-bus`
`pip install cocotbext-axi`
`https://github.com/corna/cocotbext-axi4stream.git && python3 -m pip install -e cocotbext-axi4stream`
`pip install pycryptodome`


