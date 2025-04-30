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

    -- simulate inputs in 32-bit chunks
    signal i1 : std_logic_vector(31 downto 0) := X"00000001";
    signal i2 : std_logic_vector(31 downto 0) := X"00000002";

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

                    -- set the state to all zeroes first
                    round_in <= zero_state;

                    -- add the input to the rate
                    -- 1088 bits = 17 lanes, add first 15 lanes
                    for x in 0 to 2 loop
                        for y in 0 to 4 loop
                            for z in 0 to 31 loop
                                round_in(x)(y)(z)    <= zero_state(x)(y)(z) xor i1(z);
                                round_in(x)(y)(z+32) <= zero_state(x)(y)(z+32) xor i2(z);
                            end loop;
                        end loop;
                    end loop;

                    -- add the remaining 2 lanes
                    for y in 0 to 1 loop
                        for z in 0 to 31 loop
                            round_in(3)(y)(z)    <= zero_state(x)(y)(z) xor i1(z);
                            round_in(3)(y)(z+32) <= zero_state(x)(y)(z+32) xor i2(z);
                        end loop;
                    end loop;

                    mode <= permutate;
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
