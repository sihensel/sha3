library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.sha3_constants.all;

entity sha3_tb is
end entity;

architecture tb of sha3_tb is

    component sha3 is
        port (
            clk : in std_logic;
            nrst : in std_logic;     -- negative reset
            m_in : in std_logic_vector(31 downto 0);
            m_valid : in std_logic;
            m_out : out std_logic_vector(31 downto 0)
        );
    end component;

    signal clk : std_logic;
    signal nrst : std_logic;

    signal m_in : std_logic_vector(31 downto 0) := X"00000001";
    signal m_valid : std_logic := '0';
    signal m_out : std_logic_vector(31 downto 0);

    type t_mode is (read_in, read_out);
    signal mode : t_mode;

begin

    sha3_map : sha3
    port map(
        clk => clk,
        nrst => nrst,
        m_in => m_in,
        m_valid => m_valid,
        m_out => m_out
    );

    -- take DUT out of reset
    nrst <= '0', '1' after 5 ns;

    tb_main : process (clk) is
    begin
        if (nrst = '0') then
            mode <= read_in;
            m_in <= X"00000000";
            m_valid <= '0';

        elsif (rising_edge(clk)) then

            case mode is
                when read_in =>
                    m_in <= X"00000001";
                    m_valid <= '1';
                    mode <= read_out;
                when read_out =>
                    m_valid <= '0';
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
