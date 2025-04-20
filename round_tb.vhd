library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.sha3_constants.all;

entity round_tb is
end entity;

architecture tb of round_tb is

component round is
    port (
        round_in : in  t_state;
        -- round_constant : in std_logic_vector(63 downto 0);
        round_number : in unsigned(4 downto 0);
        round_out : out t_state
    );
end component;

    signal clk : std_logic;
    signal nrst : std_logic;

    signal round_in, round_out, zero_state : t_state;
    signal round_number : unsigned(4 downto 0);
    signal zero_lane : t_lane;
    signal zero_plane : t_plane;

begin

    round_map : round
    port map(
        round_in => round_in,
        round_number => round_number,
        round_out => round_out);

    -- set state to zero
    zero_lane <= (others => '0');
    -- i000: for x in 0 to 4 generate
    --     zero_plane(x)<= zero_lane;
    -- end generate;
    --
    -- i001: for y in 0 to 4 generate
    --     zero_state(y)<= zero_plane;
    -- end generate;
    set_plane_zero : process (zero_lane) is
    begin
        for x in 0 to 4 loop
            zero_plane(x) <= zero_lane;
        end loop;
    end process;

    set_state_zero : process (zero_plane) is
    begin
        for y in 0 to 4 loop
            zero_state(y) <= zero_plane;
        end loop;
    end process;

    nrst <= '0', '1' after 10 ns;
    
    tb_gen : process (clk) is
    begin
        if (nrst = '0') then
            round_number <= (others => '0');

        elsif (rising_edge(clk)) then
            round_in <= zero_state;
            --for x in 0 to 4 loop
            --    for y in 0 to 4 loop
            --        for z in 0 to 63 loop
            --            round_in(x)(y)(z) <= '0';
            --        end loop;
            --    end loop;
            --end loop;

            --for x in 0 to 4 loop
            --    for y in 0 to 4 loop
            --        for z in 0 to 63 loop
            --            report "Hello";
            --        end loop;
            --    end loop;
            --end loop;
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
