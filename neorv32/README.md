# Compile examples

```bash
make image 
make install-neorv32_application_image.vhd
```

## Test core

```bash
cd tb
SIM=ghdl pytest -o log_cli=True neorv32_cocotb.py
```
