library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity top is
    generic (
        CLKFREQ             : integer := 100E6; -- 100 Mhz clock
        BAUDRATE            : integer := 115200;
        UART_DATA_WIDTH     : integer := 8;
        AXI_FIFO_DATA_WIDTH : integer := 32;
        PARITY              : string  := "NONE"; -- NONE, EVEN, ODD
        STOP_WIDTH          : integer := 1
    );
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        -- external interface signals
        rxd : in  std_logic;
        txd : out std_logic;
        
        debug_led0 : out std_logic;
        debug_led1 : out std_logic;
        debug_led2 : out std_logic;
        debug_led3 : out std_logic;
        debug_led4 : out std_logic;
        debug_led5 : out std_logic;
        debug_led6 : out std_logic;
        debug_led7 : out std_logic;
        debug_led8 : out std_logic;
        debug_led9 : out std_logic;
        debug_led10 : out std_logic;
        debug_led11 : out std_logic;
        debug_led12 : out std_logic;
        debug_led13 : out std_logic;
        debug_led14 : out std_logic;
        debug_led15 : out std_logic
    );
end entity;

architecture behavioral of top is

component uart is
    generic (
        CLKFREQ         : integer := CLKFREQ;
        BAUDRATE        : integer := BAUDRATE;
        DATA_WIDTH      : integer := UART_DATA_WIDTH;
        PARITY          : string  := PARITY;
        STOP_WIDTH      : integer := STOP_WIDTH
    );
    port (
        clk             : in    std_logic;
        -- external interface signals
        rxd             : in    std_logic;
        txd             : out   std_logic;
        -- internal interface signals
        -- master axi stream interface
        m_axis_tready   : in    std_logic;
        m_axis_tdata    : out   std_logic_vector(DATA_WIDTH-1 downto 0);
        m_axis_tvalid   : out   std_logic;
        -- slave axi stream interface
        s_axis_tvalid   : in    std_logic;
        s_axis_tdata    : in    std_logic_vector(DATA_WIDTH-1 downto 0);
        s_axis_tready   : out   std_logic
    );
end component;

component axi_adapter1 is
    generic (
        input_width     : natural := UART_DATA_WIDTH;
        output_width    : natural := AXI_FIFO_DATA_WIDTH
    );
    port (
        clk         : in    std_logic;
        rst         : in    std_logic;
     
        -- axi input interface
        in_ready    : out   std_logic;
        in_valid    : in    std_logic;
        in_data     : in    std_logic_vector(input_width - 1 downto 0);
 
        -- axi output interface
        out_ready   : in    std_logic;
        out_valid   : out   std_logic;
        out_data    : out   std_logic_vector(output_width - 1 downto 0)
    );
end component; 

component axi_adapter2 is
    generic (
        input_width     : natural := AXI_FIFO_DATA_WIDTH;
        output_width    : natural := UART_DATA_WIDTH
    );
    port (
        clk         : in    std_logic;
        rst         : in    std_logic;
     
        -- axi input interface
        in_ready    : out   std_logic;
        in_valid    : in    std_logic;
        in_data     : in    std_logic_vector(input_width - 1 downto 0);
 
        -- axi output interface
        out_ready   : in    std_logic;
        out_valid   : out   std_logic;
        out_data    : out   std_logic_vector(output_width - 1 downto 0)
    );
end component; 


component axi_fifo is
    generic (
        ram_width   : natural := AXI_FIFO_DATA_WIDTH;
        ram_depth   : natural := 16
    );
    port (
        clk         : in    std_logic;
        rst         : in    std_logic;
     
        -- axi input interface
        in_ready    : out   std_logic;
        in_valid    : in    std_logic;
        in_data     : in    std_logic_vector(ram_width - 1 downto 0);
 
        -- axi output interface
        out_ready   : in    std_logic;
        out_valid   : out   std_logic;
        out_data    : out   std_logic_vector(ram_width - 1 downto 0)
    );
end component; 

component sha3 is
    generic (
        data_width   : natural := AXI_FIFO_DATA_WIDTH
    );
    port (
        clk         : in    std_logic;
        rst         : in    std_logic;
     
        -- axi input interface
        in_ready    : out   std_logic;
        in_valid    : in    std_logic;
        in_data     : in    std_logic_vector(data_width - 1 downto 0);
 
        -- axi output interface
        out_ready   : in    std_logic;
        out_valid   : out   std_logic;
        out_data    : out   std_logic_vector(data_width - 1 downto 0)
    );
end component; 


-- internal interface signals
-- master axi stream interface
signal m_axis_tready : std_logic;
signal m_axis_tdata  : std_logic_vector(UART_DATA_WIDTH-1 downto 0);
signal m_axis_tvalid : std_logic;
-- slave axi stream interface
signal s_axis_tvalid : std_logic;
signal s_axis_tdata  : std_logic_vector(UART_DATA_WIDTH-1 downto 0);
signal s_axis_tready : std_logic;


-- slave axi stream interface
signal s_axis_adapter1_tvalid : std_logic;
signal s_axis_adapter1_tdata  : std_logic_vector(AXI_FIFO_DATA_WIDTH-1 downto 0);
signal s_axis_adapter1_tready : std_logic;

-- master axi stream interface
signal m_axis_adapter2_tready : std_logic;
signal m_axis_adapter2_tdata  : std_logic_vector(AXI_FIFO_DATA_WIDTH-1 downto 0);
signal m_axis_adapter2_tvalid : std_logic;

-- input to sha3
signal i_sha3_tready : std_logic;
signal i_sha3_tdata  : std_logic_vector(AXI_FIFO_DATA_WIDTH-1 downto 0);
signal i_sha3_tvalid : std_logic;

-- output from sha3
signal o_sha3_tready : std_logic;
signal o_sha3_tdata  : std_logic_vector(AXI_FIFO_DATA_WIDTH-1 downto 0);
signal o_sha3_tvalid : std_logic;

signal debug_counter : unsigned(15 downto 0);

begin

    debug_led0 <= debug_counter(0);
    debug_led1 <= debug_counter(1);
    debug_led2 <= debug_counter(2);
    debug_led3 <= debug_counter(3);
    debug_led4 <= debug_counter(4);
    debug_led5 <= debug_counter(5);
    debug_led6 <= debug_counter(6);
    debug_led7 <= debug_counter(7);
    debug_led8 <= debug_counter(8);
    debug_led9 <= debug_counter(9);        
    debug_led10 <= debug_counter(10);        
    debug_led11 <= debug_counter(11);        
    debug_led12 <= debug_counter(12);        
    debug_led13 <= debug_counter(13);        
    debug_led14 <= debug_counter(14);        
    debug_led15 <= debug_counter(15);        

    process(clk) is
    begin
        if(rising_edge(clk)) then
            if(rst='1') then
                debug_counter <= (others => '0');
            elsif(m_axis_tvalid='1') then
                debug_counter <= debug_counter + 1;
            end if;
        end if;
    end process;

    uart_inst : uart
        port map ( clk => clk,
                   rxd => rxd,
                   txd => txd,
                   m_axis_tready => m_axis_tready,
                   m_axis_tdata  => m_axis_tdata,
                   m_axis_tvalid => m_axis_tvalid,
                   s_axis_tvalid => s_axis_tvalid,
                   s_axis_tdata  => s_axis_tdata,
                   s_axis_tready => s_axis_tready );

    adapter1_inst : axi_adapter1
        port map ( clk          => clk,
                   rst          => rst,
                   in_ready     => m_axis_tready,
                   in_valid     => m_axis_tvalid,
                   in_data      => m_axis_tdata,
                   out_ready    => s_axis_adapter1_tready,
                   out_valid    => s_axis_adapter1_tvalid,
                   out_data     => s_axis_adapter1_tdata );
                   
    adapter2_inst : axi_adapter2
        port map ( clk          => clk,
                   rst          => rst,
                   in_ready     => m_axis_adapter2_tready,
                   in_valid     => m_axis_adapter2_tvalid,
                   in_data      => m_axis_adapter2_tdata,
                   out_ready    => s_axis_tready,
                   out_valid    => s_axis_tvalid,
                   out_data     => s_axis_tdata );                   

    fifo_inst_in : axi_fifo
        port map ( clk          => clk,
                   rst          => rst,
                   in_ready     => s_axis_adapter1_tready,
                   in_valid     => s_axis_adapter1_tvalid,
                   in_data      => s_axis_adapter1_tdata,
                   out_ready    => i_sha3_tready,
                   out_valid    => i_sha3_tvalid,
                   out_data     => i_sha3_tdata );
                   
    fifo_inst_out : axi_fifo
        port map ( clk          => clk,
                   rst          => rst,
                   in_ready     => o_sha3_tready,
                   in_valid     => o_sha3_tvalid,
                   in_data      => o_sha3_tdata,
                   out_ready    => m_axis_adapter2_tready,
                   out_valid    => m_axis_adapter2_tvalid,
                   out_data     => m_axis_adapter2_tdata );                   

    sha3_inst : sha3
        port map ( clk          => clk,
                   rst          => rst,
                   in_ready     => i_sha3_tready,
                   in_valid     => i_sha3_tvalid,
                   in_data      => i_sha3_tdata,
                   out_ready    => o_sha3_tready,
                   out_valid    => o_sha3_tvalid,
                   out_data     => o_sha3_tdata );  
                   
end Behavioral;
