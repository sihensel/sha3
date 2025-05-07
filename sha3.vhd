library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.sha3_constants.all;

entity sha3 is
    generic (
        data_width   : natural
    );
    port (
        clk         : in    std_logic;
        nrst        : in    std_logic;

        -- axi input interface
        in_ready    : out   std_logic;
        in_valid    : in    std_logic;
        in_data     : in    std_logic_vector(data_width - 1 downto 0);

        -- axi output interface
        out_ready   : in    std_logic;
        out_valid   : out   std_logic;
        out_data    : out   std_logic_vector(data_width - 1 downto 0)
    );
end entity;

architecture rtl of sha3 is

component control_path is
    generic (
        data_width   : natural
    );
    port (
        clk         : in    std_logic;
        nrst        : in    std_logic;

        -- axi input interface
        in_ready    : out   std_logic;
        in_valid    : in    std_logic;
        in_data     : in    std_logic_vector(data_width - 1 downto 0);

        -- axi output interface
        out_ready   : in    std_logic;
        out_valid   : out   std_logic;

        -- control signals
        d_counter   : out   unsigned(5 downto 0);   -- 34 messages to fill the rate
        read_data   : out   std_logic;
        proc_data   : out   std_logic;
        write_data  : out   std_logic
    );
end component;

component data_path is
    generic (
        data_width   : natural
    );
    port (
        clk         : in    std_logic;
        nrst        : in    std_logic;

        -- axi input interface
        in_data     : in    std_logic_vector(data_width - 1 downto 0);

        -- axi output interface
        out_data    : out   std_logic_vector(data_width - 1 downto 0);

        -- control signals
        d_counter   : in    unsigned(5 downto 0);
        read_data   : in    std_logic;
        proc_data   : in    std_logic;
        write_data  : in    std_logic
    );
end component;

    signal d_counter    : unsigned(5 downto 0);
    signal read_data    : std_logic;
    signal proc_data    : std_logic;
    signal write_data   : std_logic;

begin

    control_path_inst : control_path
        generic map ( data_width => data_width )
        port map ( clk          => clk,
                   nrst         => nrst,
                   in_ready     => in_ready,
                   in_valid     => in_valid,
                   in_data      => in_data,

                   -- axi output interface
                   out_ready    => out_ready,
                   out_valid    => out_valid,

                   -- control signals
                   d_counter    => d_counter,
                   read_data    => read_data,
                   proc_data    => proc_data,
                   write_data   => write_data );

    data_path_inst : data_path
        generic map ( data_width => data_width )
        port map ( clk          => clk,
                   nrst         => nrst,

                   -- axi input interface
                   in_data      => in_data,

                   -- axi output interface
                   out_data     => out_data,

                   -- control signals
                   d_counter    => d_counter,
                   read_data    => read_data,
                   proc_data    => proc_data,
                   write_data   => write_data );

end architecture;
