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

    type t_mode is (read_in, permutate, read_out);
    signal mode : t_mode;

begin

    round_map : round
    port map(
        round_in => round_in,
        round_number => round_number,
        round_out => round_out
    );

    -- set state to zero
    -- TODO check how to set indivdual state bits here
    zero_lane <= (others => '0');
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

    -- take DUT out of reset
    nrst <= '0', '1' after 5 ns;
    
    -- main testbench process
    tb_main : process (clk) is
    begin
        if (nrst = '0') then
            round_number <= (others => '0');
            mode <= read_in;

        elsif (rising_edge(clk)) then

            case mode is
                when read_in =>
                    -- first round
                    round_in <= zero_state;
                    mode <= read_out;
                when permutate =>
                    -- rounds 2 to 23
                    if (round_number < 23) then
                        round_in <= round_out;
                        round_number <= round_number + 1;
                    else
                        mode <= read_out;
                    end if;
                when read_out =>
                    -- do nothing for now
                when others =>
                    mode <= read_out;
            end case;
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
