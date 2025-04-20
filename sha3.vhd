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

    signal state : t_state;

begin

    p_main : process (clk, nrst) is
    begin
        if rising_edge(clk) then
            if nrst = '0' then
                hash <= (others => '0');
                -- not sure if this works
                --state <= (others => '0');
            else
                -- do sth.
                report "Hello";
            end if;
        end if;
    end process;
end architecture;
