library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;

library work;
use work.sha3_constants.all;

entity sha3 is
    port (
        clk : in std_logic;
        nrst : in std_logic;     -- negative reset
        plain : in std_logic_vector;
        hash : out std_logic_vector
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

    signal state : t_state;
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

    p_main : process (clk) is
    begin
        if rising_edge(clk) then
            if (nrst = '0') then
                round_number <= (others => '0');
            else
                case mode is
                end case;
            end if;
        end if;
    end process;
end architecture;
