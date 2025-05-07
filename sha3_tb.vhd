library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.sha3_constants.all;

entity sha3_tb is
end entity;

architecture tb of sha3_tb is

    component sha3 is
        generic (
            data_width : natural
        );
        port (
            clk : in std_logic;
            nrst : in std_logic;     -- negative reset

            in_ready    : out   std_logic;
            in_valid    : in    std_logic;
            in_data     : in    std_logic_vector(data_width - 1 downto 0);

            -- axi output interface
            out_ready   : in    std_logic;
            out_valid   : out   std_logic;
            out_data    : out   std_logic_vector(data_width - 1 downto 0)
        );
    end component;

    constant data_width : natural := 32;

    signal clk : std_logic;
    signal nrst : std_logic;

    signal in_ready    : std_logic;
    signal in_valid    : std_logic;
    signal in_data     : std_logic_vector(data_width - 1 downto 0);

    -- axi output interface
    signal out_ready   : std_logic;
    signal out_valid   : std_logic;
    signal out_data    : std_logic_vector(data_width - 1 downto 0);

begin

    sha3_map : sha3
    generic map (
        data_width => data_width
    )
    port map(
        clk => clk,
        nrst => nrst,
        in_ready => in_ready,
        in_valid => in_valid,
        in_data => in_data,
        out_ready => out_ready,
        out_valid => out_valid,
        out_data => out_data
    );

    -- take DUT out of reset
    nrst <= '0', '1' after 5 ns;

    tb_main : process (clk) is
    begin
        if (nrst = '0') then
            in_ready <= '1';
            in_valid <= '1';
            in_data <= (others => '0');

            out_ready <= '0';
            out_valid <= '0';
            out_data <= (others => '0');

        elsif (rising_edge(clk)) then

            -- control message
            in_data <= X"00000000";

            -- FIXME send data message here

        end if;
    end process;

    -- clk signal generation
    clk_generator : process is
    begin
        clk <= '0';
        wait for 0.5 ns;
        clk <= '1';
        wait for 0.5 ns;
    end process;

end architecture;
