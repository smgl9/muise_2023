library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package neorv32_wrapper_pkg is

  -- Neorv32 Risc-V Configuration Constants
  -- ------------------------------------------------------------
  -- Configuration Generics --
  -- ------------------------------------------------------------
  -- General --
  constant  c_RISCV_CLOCK_FREQUENCY              : natural := 100000000;      -- clock frequency of clk_i in Hz
  constant  c_RISCV_HART_ID                      : std_ulogic_vector(31 downto 0) := x"00000000"; -- hardware thread ID
  constant  c_RISCV_VENDOR_ID                    : std_ulogic_vector(31 downto 0) := x"00000000"; -- vendor's JEDEC ID
  constant  c_RISCV_CUSTOM_ID                    : std_ulogic_vector(31 downto 0) := x"00000000"; -- custom user-defined ID
  constant  c_RISCV_INT_BOOTLOADER_EN            : boolean := false;   -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
  -- On-Chip Debugger (OCD) --
  constant  c_RISCV_ON_CHIP_DEBUGGER_EN          : boolean := false;  -- implement on-chip debugger
  -- RISC-V CPU Extensions --
  constant  c_RISCV_CPU_EXTENSION_RISCV_B        : boolean := false;  -- implement bit-manipulation extension?
  constant  c_RISCV_CPU_EXTENSION_RISCV_C        : boolean := false;  -- implement compressed extension?
  constant  c_RISCV_CPU_EXTENSION_RISCV_E        : boolean := false;  -- implement embedded RF extension?
  constant  c_RISCV_CPU_EXTENSION_RISCV_M        : boolean := false;  -- implement muld/div extension?
  constant  c_RISCV_CPU_EXTENSION_RISCV_U        : boolean := false;  -- implement user mode extension?
  constant  c_RISCV_CPU_EXTENSION_RISCV_Zfinx    : boolean := false;  -- implement 32-bit floating-point extension (using INT reg!)
  constant  c_RISCV_CPU_EXTENSION_RISCV_Zicntr   : boolean := true;   -- implement base counters?
  constant  c_RISCV_CPU_EXTENSION_RISCV_Zihpm    : boolean := false;  -- implement hardware performance monitors?
  constant  c_RISCV_CPU_EXTENSION_RISCV_Zifencei : boolean := false;  -- implement instruction stream sync.?
  constant  c_RISCV_CPU_EXTENSION_RISCV_Zmmul    : boolean := false;  -- implement multiply-only M sub-extension?
  constant  c_RISCV_CPU_EXTENSION_RISCV_Zxcfu    : boolean := false;  -- implement custom (instr.) functions unit?
  -- Extension Options --
  constant  c_RISCV_FAST_MUL_EN                  : boolean := false;  -- use DSPs for M extension's multiplier
  constant  c_RISCV_FAST_SHIFT_EN                : boolean := false;  -- use barrel shifter for shift operations
  -- Physical Memory Protection (PMP) --
  constant  c_RISCV_PMP_NUM_REGIONS              : natural := 0;      -- number of regions (0..16)
  constant  c_RISCV_PMP_MIN_GRANULARITY          : natural := 4;      -- minimal region granularity in bytes, has to be a power of 2, min 4 bytes
  -- Hardware Performance Monitors (HPM) --
  constant  c_RISCV_HPM_NUM_CNTS                 : natural := 0;      -- number of implemented HPM counters (0..29)
  constant  c_RISCV_HPM_CNT_WIDTH                : natural := 40;     -- total size of HPM counters (0..64)
  -- Internal Instruction memory --
  constant  c_RISCV_MEM_INT_IMEM_EN              : boolean := true;   -- implement processor-internal instruction memory
  constant  c_RISCV_MEM_INT_IMEM_SIZE            : natural := 16*1024; -- size of processor-internal instruction memory in bytes
  -- Internal Data memory --
  constant  c_RISCV_MEM_INT_DMEM_EN              : boolean := true;   -- implement processor-internal data memory
  constant  c_RISCV_MEM_INT_DMEM_SIZE            : natural := 8*1024; -- size of processor-internal data memory in bytes
  -- Internal Cache memory --
  constant  c_RISCV_ICACHE_EN                    : boolean := false;  -- implement instruction cache
  constant  c_RISCV_ICACHE_NUM_BLOCKS            : natural := 4;      -- i-cache: number of blocks (min 1), has to be a power of 2
  constant  c_RISCV_ICACHE_BLOCK_SIZE            : natural := 64;     -- i-cache: block size in bytes (min 4), has to be a power of 2
  constant  c_RISCV_ICACHE_ASSOCIATIVITY         : natural := 1;      -- i-cache: associativity / number of sets (1=direct_mapped), has to be a power of 2
  -- Internal Data Cache (dCACHE) --
  constant  c_RISCV_DCACHE_EN                    : boolean := false;  -- implement data cache
  constant  c_RISCV_DCACHE_NUM_BLOCKS            : natural := 4;      -- d-cache: number of blocks (min 1), has to be a power of 2
  constant  c_RISCV_DCACHE_BLOCK_SIZE            : natural := 64;     -- d-cache: block size in bytes (min 4), has to be a power of 2
  -- External Interrupts Controller (XIRQ) --
  constant  c_RISCV_XIRQ_NUM_CH                  : natural := 0;      -- number of external IRQ channels (0..32)
  constant  c_RISCV_XIRQ_TRIGGER_TYPE            : std_logic_vector(31 downto 0) := x"FFFFFFFF"; -- trigger type: 0=level, 1=edge
  constant  c_RISCV_XIRQ_TRIGGER_POLARITY        : std_logic_vector(31 downto 0) := x"FFFFFFFF"; -- trigger polarity: 0=low-level/falling-edge, 1=high-level/rising-edge
  -- Processor peripherals --
  constant  c_RISCV_IO_GPIO_NUM                  : natural := 8;      -- number of GPIO input/output pairs (0..64)
  constant  c_RISCV_IO_MTIME_EN                  : boolean := true;   -- implement machine system timer (MTIME)?
  constant  c_RISCV_IO_UART0_EN                  : boolean := false;   -- implement primary universal asynchronous receiver/transmitter (UART0)?
  constant  c_RISCV_IO_UART0_RX_FIFO             : natural := 1;      -- RX fifo depth, has to be a power of two, min 1
  constant  c_RISCV_IO_UART0_TX_FIFO             : natural := 1;      -- TX fifo depth, has to be a power of two, min 1
  constant  c_RISCV_IO_UART1_EN                  : boolean := false;   -- implement secondary universal asynchronous receiver/transmitter (UART1)?
  constant  c_RISCV_IO_UART1_RX_FIFO             : natural := 1;      -- RX fifo depth, has to be a power of two, min 1
  constant  c_RISCV_IO_UART1_TX_FIFO             : natural := 1;      -- TX fifo depth, has to be a power of two, min 1
  constant  c_RISCV_IO_SPI_EN                    : boolean := false;   -- implement serial peripheral interface (SPI)?
  constant  c_RISCV_IO_SPI_FIFO                  : natural := 1;      -- SPI RTX fifo depth, has to be a power of two, min 1
  constant  c_RISCV_IO_TWI_EN                    : boolean := false;   -- implement two-wire interface (TWI)?
  constant  c_RISCV_IO_PWM_NUM_CH                : natural := 0;      -- number of PWM channels to implement (0..12); 0 = disabled
  constant  c_RISCV_IO_WDT_EN                    : boolean := true;   -- implement watch dog timer (WDT)?
  constant  c_RISCV_IO_TRNG_EN                   : boolean := false;   -- implement true random number generator (TRNG)?
  constant  c_RISCV_IO_TRNG_FIFO                 : natural := 1;      -- TRNG fifo depth, has to be a power of two, min 1
  constant  c_RISCV_IO_CFS_EN                    : boolean := false;  -- implement custom functions subsystem (CFS)?
  constant  c_RISCV_IO_CFS_CONFIG                : std_logic_vector(31 downto 0) := x"00000000"; -- custom CFS configuration generic
  constant  c_RISCV_IO_CFS_IN_SIZE               : positive := 32;    -- size of CFS input conduit in bits
  constant  c_RISCV_IO_CFS_OUT_SIZE              : positive := 32;    -- size of CFS output conduit in bits
  constant  c_RISCV_IO_NEOLED_EN                 : boolean := false;   -- implement NeoPixel-compatible smart LED interface (NEOLED)?
  constant  c_RISCV_IO_NEOLED_TX_FIFO            : natural := 1;      -- NEOLED TX FIFO depth, 1..32k, has to be a power of two
  constant  c_RISCV_IO_GPTMR_EN                  : boolean := false;  -- implement general purpose timer (GPTMR)?
  constant  c_RISCV_IO_XIP_EN                    : boolean := false;  -- implement execute in place module (XIP)?
  constant  c_RISCV_IO_ONEWIRE_EN                : boolean := false;  -- implement 1-wire interface (ONEWIRE)?

end package;
