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

    constant message_count : integer := 35;
    type t_testdata is array(0 to message_count - 1) of std_logic_vector(31 downto 0);
    signal testdata : t_testdata := (
        X"00000001",    -- cmd message

        -- plane 1
        X"00000001",
        X"00000002",
        X"00000003",
        X"00000004",
        X"00000005",
        X"00000006",
        X"00000007",
        X"00000008",
        X"00000009",
        X"0000000A",
        -- plane 2
        X"0000000B",
        X"0000000C",
        X"0000000D",
        X"0000000E",
        X"0000000F",
        X"00000010",
        X"00000011",
        X"00000012",
        X"00000013",
        X"00000014",
        -- plane 3
        X"00000015",
        X"00000016",
        X"00000017",
        X"00000018",
        X"00000019",
        X"0000001a",
        X"0000001b",
        X"0000001c",
        X"0000001d",
        X"0000001e",
        -- plane 4
        X"0000001f",
        X"00000020",
        X"00000021",
        X"00000022"
    );
    signal i : integer := 0;

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

        elsif (rising_edge(clk)) then

            -- control message
            if (i < message_count) then

                in_data <= testdata(i);
                i <= i + 1;
            else
                in_valid <= '0';
                out_valid <= '1';
                out_ready <= '1';
            end if;

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
