
--! # AES 128
--! AES top module wrapps encryption and decryption cores. The module is configured by AXI-lite registers.


--! ## Overview

--! | Offset | Name    | Description        | Type   |
--! | ------ | ------- | ------------------ | ------ |
--! | `0x0`  | control | modes of operation | REG    |
--! | `0x4`  | key     |                    | ARR[4] |

--! ## Registers

--! | Offset | Name         | Description        | Type   | Access | Attributes | Reset |
--! | ------ | ------------ | ------------------ | ------ | ------ | ---------- | ----- |
--! | `0x0`  | control      | modes of operation | REG    | R/W    |            | `0x0` |
--! |        | [0] mode     |                    |        |        |            | `0x0` |
--! | `0x4`  | key          |                    | ARR[4] | W      |            | `0x0` |
--! |        | [31:0] value |                    |        |        |            | `0x0` |

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_regs_pkg.all;

entity aes_top is
  generic (
    g_axi_addr_width   : integer := 32; --! AXI-Lite address width
    g_axis_tdata_width : integer := 128 --! AXI-Stream tdata width
  );
  port (
    axis_aclk    : in std_logic; --! AXI4-Stream clock
    axis_aresetn : in std_logic; --! AXI4-Stream resetn
    axi_aclk     : in std_logic; --! AXI4-Lite clock
    axi_aresetn  : in std_logic; --! AXI4-Lite resetn
        --! @virtualbus S_AXIS AXI-Stream Slave Bus
    s_axis_tdata  : in std_logic_vector(g_axis_tdata_width - 1 downto 0);
    s_axis_tvalid : in std_logic;
    s_axis_tready : out std_logic; --! @end
        --! @virtualbus M_AXIS AXI-Stream Master Bus
    m_axis_tdata  : out std_logic_vector(g_axis_tdata_width - 1 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tready : in std_logic;
    m_axis_tlast  : out std_logic;
    m_axis_tkeep  : out std_logic_vector(g_axis_tdata_width / 8 - 1 downto 0); --! @end
        --! @virtualbus AXI_lite AXI-Lite Slave Bus
    s_axi_awaddr  : in std_logic_vector(g_axi_addr_width - 1 downto 0);
    s_axi_awprot  : in std_logic_vector(2 downto 0);
    s_axi_awvalid : in std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in std_logic_vector(31 downto 0);
    s_axi_wstrb   : in std_logic_vector(3 downto 0);
    s_axi_wvalid  : in std_logic;
    s_axi_wready  : out std_logic;
    s_axi_araddr  : in std_logic_vector(g_axi_addr_width - 1 downto 0);
    s_axi_arprot  : in std_logic_vector(2 downto 0);
    s_axi_arvalid : in std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in std_logic --! @end
  );
end entity aes_top;

architecture rtl of aes_top is

  constant c_key_size : integer := 128;

  signal s_user2regs : user2regs_t;
  signal s_regs2user : regs2user_t;
  signal s_key       : std_logic_vector(c_key_size - 1 downto 0);

begin

  aes_inst : entity work.aes
    generic map (
      design_type => "ITER"
    )
    port map (
      reset_i  => axis_aresetn,
      clk_i    => axis_aclk,
      mode_i   => s_regs2user.control_mode(0),
      key_i    => s_key,
      data_i   => s_axis_tdata,
      valid_i  => s_axis_tvalid,
      accept_o => s_axis_tready,
      data_o   => m_axis_tdata,
      valid_o  => m_axis_tvalid,
      accept_i => m_axis_tready
    );

  aes_regs_inst : entity work.aes_regs
    generic map (
      axi_addr_width => g_axi_addr_width
    )
    port map (
      axi_aclk      => axi_aclk,
      axi_aresetn   => axi_aresetn,
      s_axi_awaddr  => s_axi_awaddr,
      s_axi_awprot  => s_axi_awprot,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_wdata   => s_axi_wdata,
      s_axi_wstrb   => s_axi_wstrb,
      s_axi_wvalid  => s_axi_wvalid,
      s_axi_wready  => s_axi_wready,
      s_axi_araddr  => s_axi_araddr,
      s_axi_arprot  => s_axi_arprot,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,
      s_axi_rdata   => s_axi_rdata,
      s_axi_rresp   => s_axi_rresp,
      s_axi_rvalid  => s_axi_rvalid,
      s_axi_rready  => s_axi_rready,
      s_axi_bresp   => s_axi_bresp,
      s_axi_bvalid  => s_axi_bvalid,
      s_axi_bready  => s_axi_bready,
      user2regs     => s_user2regs,
      regs2user     => s_regs2user
    );

  s_key <= s_regs2user.key_value(0) & s_regs2user.key_value(1) & s_regs2user.key_value(2) & s_regs2user.key_value(3);

end architecture rtl;
