library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Packages
use work.neorv32_wrapper_pkg.all; -- Risc V Neorv-32 Package with constants for generic conf

entity neorv32_wrapper is
  port (
    xirq_i : in std_logic_vector(2 - 1 downto 0); -- IRQ channels
    -- ------------------------------------------------------------
    -- AXI4-Lite-Compatible Master Interface --
    -- ------------------------------------------------------------
    -- Clock and Reset --
    m_axi_aclk    : in std_logic;
    m_axi_aresetn : in std_logic;
    -- Write Address Channel --
    m_axi_awaddr  : out std_logic_vector(31 downto 0);
    m_axi_awprot  : out std_logic_vector(2 downto 0);
    m_axi_awvalid : out std_logic;
    m_axi_awready : in std_logic;
    -- Write Data Channel --
    m_axi_wdata  : out std_logic_vector(31 downto 0);
    m_axi_wstrb  : out std_logic_vector(3 downto 0);
    m_axi_wvalid : out std_logic;
    m_axi_wready : in std_logic;
    -- Read Address Channel --
    m_axi_araddr  : out std_logic_vector(31 downto 0);
    m_axi_arprot  : out std_logic_vector(2 downto 0);
    m_axi_arvalid : out std_logic;
    m_axi_arready : in std_logic;
    -- Read Data Channel --
    m_axi_rdata  : in std_logic_vector(31 downto 0);
    m_axi_rresp  : in std_logic_vector(1 downto 0);
    m_axi_rvalid : in std_logic;
    m_axi_rready : out std_logic;
    -- Write Response Channel --
    m_axi_bresp  : in std_logic_vector(1 downto 0);
    m_axi_bvalid : in std_logic;
    m_axi_bready : out std_logic;
    -- GPIO
    gpio_o :out std_logic_vector(63 downto 0);
    gpio_i :in std_logic_vector(63 downto 0)
  );
end entity neorv32_wrapper;

architecture rtl of neorv32_wrapper is

  -- Signals
  signal s_gpio : std_logic_vector(64 - 1 downto 0);

begin

  -- Risc-V
  neorv32_systemtop_axi4lite_inst : entity work.neorv32_systemtop_axi4lite
    generic map (
      clock_frequency              => c_RISCV_CLOCK_FREQUENCY,
      hart_id                      => c_RISCV_HART_ID,
      vendor_id                    => c_RISCV_VENDOR_ID,
      custom_id                    => c_RISCV_CUSTOM_ID,
      int_bootloader_en            => c_RISCV_INT_BOOTLOADER_EN,
      on_chip_debugger_en          => c_RISCV_ON_CHIP_DEBUGGER_EN,
      cpu_extension_riscv_b        => c_RISCV_CPU_EXTENSION_RISCV_B,
      cpu_extension_riscv_c        => c_RISCV_CPU_EXTENSION_RISCV_C,
      cpu_extension_riscv_e        => c_RISCV_CPU_EXTENSION_RISCV_E,
      cpu_extension_riscv_m        => c_RISCV_CPU_EXTENSION_RISCV_M,
      cpu_extension_riscv_u        => c_RISCV_CPU_EXTENSION_RISCV_U,
      cpu_extension_riscv_zfinx    => c_RISCV_CPU_EXTENSION_RISCV_Zfinx,
      cpu_extension_riscv_zicntr   => c_RISCV_CPU_EXTENSION_RISCV_Zicntr,
      cpu_extension_riscv_zihpm    => c_RISCV_CPU_EXTENSION_RISCV_Zihpm,
      cpu_extension_riscv_zifencei => c_RISCV_CPU_EXTENSION_RISCV_Zifencei,
      cpu_extension_riscv_zmmul    => c_RISCV_CPU_EXTENSION_RISCV_Zmmul,
      cpu_extension_riscv_zxcfu    => c_RISCV_CPU_EXTENSION_RISCV_Zxcfu,
      fast_mul_en                  => c_RISCV_FAST_MUL_EN,
      fast_shift_en                => c_RISCV_FAST_SHIFT_EN,
      pmp_num_regions              => c_RISCV_PMP_NUM_REGIONS,
      pmp_min_granularity          => c_RISCV_PMP_MIN_GRANULARITY,
      hpm_num_cnts                 => c_RISCV_HPM_NUM_CNTS,
      hpm_cnt_width                => c_RISCV_HPM_CNT_WIDTH,
      mem_int_imem_en              => c_RISCV_MEM_INT_IMEM_EN,
      mem_int_imem_size            => c_RISCV_MEM_INT_IMEM_SIZE,
      mem_int_dmem_en              => c_RISCV_MEM_INT_DMEM_EN,
      mem_int_dmem_size            => c_RISCV_MEM_INT_DMEM_SIZE,
      icache_en                    => c_RISCV_ICACHE_EN,
      icache_num_blocks            => c_RISCV_ICACHE_NUM_BLOCKS,
      icache_block_size            => c_RISCV_ICACHE_BLOCK_SIZE,
      icache_associativity         => c_RISCV_ICACHE_ASSOCIATIVITY,
      dcache_en                    => c_RISCV_DCACHE_EN,
      dcache_num_blocks            => c_RISCV_DCACHE_NUM_BLOCKS,
      dcache_block_size            => c_RISCV_DCACHE_BLOCK_SIZE,
      xirq_num_ch                  => c_RISCV_XIRQ_NUM_CH,
      xirq_trigger_type            => c_RISCV_XIRQ_TRIGGER_TYPE,
      xirq_trigger_polarity        => c_RISCV_XIRQ_TRIGGER_POLARITY,
      io_gpio_num                  => c_RISCV_IO_GPIO_NUM,
      io_mtime_en                  => c_RISCV_IO_MTIME_EN,
      io_uart0_en                  => c_RISCV_IO_UART0_EN,
      io_uart0_rx_fifo             => c_RISCV_IO_UART0_RX_FIFO,
      io_uart0_tx_fifo             => c_RISCV_IO_UART0_TX_FIFO,
      io_uart1_en                  => c_RISCV_IO_UART1_EN,
      io_uart1_rx_fifo             => c_RISCV_IO_UART1_RX_FIFO,
      io_uart1_tx_fifo             => c_RISCV_IO_UART1_TX_FIFO,
      io_spi_en                    => c_RISCV_IO_SPI_EN,
      io_spi_fifo                  => c_RISCV_IO_SPI_FIFO,
      io_twi_en                    => c_RISCV_IO_TWI_EN,
      io_pwm_num_ch                => c_RISCV_IO_PWM_NUM_CH,
      io_wdt_en                    => c_RISCV_IO_WDT_EN,
      io_trng_en                   => c_RISCV_IO_TRNG_EN,
      io_trng_fifo                 => c_RISCV_IO_TRNG_FIFO,
      io_cfs_en                    => c_RISCV_IO_CFS_EN,
      io_cfs_config                => c_RISCV_IO_CFS_CONFIG,
      io_cfs_in_size               => c_RISCV_IO_CFS_IN_SIZE,
      io_cfs_out_size              => c_RISCV_IO_CFS_OUT_SIZE,
      io_neoled_en                 => c_RISCV_IO_NEOLED_EN,
      io_neoled_tx_fifo            => c_RISCV_IO_NEOLED_TX_FIFO,
      io_gptmr_en                  => c_RISCV_IO_GPTMR_EN,
      io_xip_en                    => c_RISCV_IO_XIP_EN,
      io_onewire_en                => c_RISCV_IO_ONEWIRE_EN
    )
    port map (
      m_axi_aclk    => m_axi_aclk,
      m_axi_aresetn => m_axi_aresetn,
      m_axi_awaddr  => m_axi_awaddr,
      m_axi_awprot  => m_axi_awprot,
      m_axi_awvalid => m_axi_awvalid,
      m_axi_awready => m_axi_awready,
      m_axi_wdata   => m_axi_wdata,
      m_axi_wstrb   => m_axi_wstrb,
      m_axi_wvalid  => m_axi_wvalid,
      m_axi_wready  => m_axi_wready,
      m_axi_araddr  => m_axi_araddr,
      m_axi_arprot  => m_axi_arprot,
      m_axi_arvalid => m_axi_arvalid,
      m_axi_arready => m_axi_arready,
      m_axi_rdata   => m_axi_rdata,
      m_axi_rresp   => m_axi_rresp,
      m_axi_rvalid  => m_axi_rvalid,
      m_axi_rready  => m_axi_rready,
      m_axi_bresp   => m_axi_bresp,
      m_axi_bvalid  => m_axi_bvalid,
      m_axi_bready  => m_axi_bready,
      jtag_trst_i   => open,
      jtag_tck_i    => open,
      jtag_tdi_i    => open,
      jtag_tdo_o    => open,
      jtag_tms_i    => open,
      xip_csn_o     => open,
      xip_clk_o     => open,
      xip_dat_i     => open,
      xip_dat_o     => open,
      gpio_o        => gpio_o,
      gpio_i        => gpio_i,
      uart0_txd_o   => open,
      uart0_rxd_i   => open,
      uart0_rts_o   => open,
      uart0_cts_i   => open,
      uart1_txd_o   => open,
      uart1_rxd_i   => open,
      uart1_rts_o   => open,
      uart1_cts_i   => open,
      spi_clk_o     => open,
      spi_dat_o     => open,
      spi_dat_i     => open,
      spi_csn_o     => open,
      twi_sda_i     => open,
      twi_sda_o     => open,
      twi_scl_i     => open,
      twi_scl_o     => open,
      onewire_i     => open,
      onewire_o     => open,
      pwm_o         => open,
      cfs_in_i      => open,
      cfs_out_o     => open,
      neoled_o      => open,
      xirq_i        => open,
      msw_irq_i     => open,
      mext_irq_i    => open
    );

end architecture rtl;
