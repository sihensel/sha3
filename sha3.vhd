library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.sha3_constants.all;

entity sha3 is
    port (
        clk : in std_logic;
        nrst : in std_logic;     -- negative reset
        m_in : in std_logic_vector(31 downto 0);
        m_valid : in std_logic;
        m_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of sha3 is

    component round is
        port (
            round_in : in  t_state;
            round_number : in unsigned(4 downto 0);
            round_out : out t_state
        );
    end component;

    signal state, zero_state : t_state;
    signal round_in, round_out : t_state;
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

    p_main : process (clk) is
    begin
        if rising_edge(clk) then
            if (nrst = '0') then
                round_number <= (others => '0');
                mode <= read_in;
            else
            case mode is
                when read_in =>
                    -- first round

                    -- set the state to all zeroes first
                    state <= zero_state;
                    if (m_valid = '1') then

                        -- add the input to the rate
                        -- 1088 bits = 17 lanes, add first 15 lanes
                        for x in 0 to 2 loop
                            for y in 0 to 4 loop
                                for z in 0 to 31 loop
                                    state(x)(y)(z)    <= zero_state(x)(y)(z) xor m_in(z);
                                    state(x)(y)(z+32) <= zero_state(x)(y)(z+32) xor m_in(z);
                                end loop;
                            end loop;
                        end loop;

                        -- add the remaining 2 lanes
                        for y in 0 to 1 loop
                            for z in 0 to 31 loop
                                state(3)(y)(z)    <= zero_state(x)(y)(z) xor m_in(z);
                                state(3)(y)(z+32) <= zero_state(x)(y)(z+32) xor m_in(z);
                            end loop;
                        end loop;

                        round_in <= state;
                        mode <= permutate;
                    end if;
                when permutate =>
                    -- rounds 2 to 23
                    if (round_number < 23) then
                        round_in <= round_out;
                        round_number <= round_number + 1;
                    else
                        mode <= read_out;
                    end if;
                when read_out =>
                    -- update state
                    state <= round_out;
                    -- read output from the rate
                    for z in 0 to 31 loop
                        m_out(z) <= state(0)(0)(z);
                    end loop;
                when others =>
                    mode <= read_out;
            end case;
            end if;
        end if;
    end process;
end architecture;
