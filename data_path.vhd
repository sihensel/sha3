LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library work;
use work.sha3_constants.all;

entity data_path is
    generic (
        data_width   : natural
    );
    port (
        clk         : in std_logic;
        rst         : in std_logic;

        -- axi input interface
        in_data     : in    std_logic_vector(data_width - 1 downto 0);
        
        -- axi output interface
        out_data    : out   std_logic_vector(data_width - 1 downto 0);

        -- control signals
        d_counter   : in    unsigned(5 downto 0);   -- need 34 messages to transfer the entire rate
        read_data   : in    std_logic;
        proc_data   : in    std_logic;
        write_data  : in    std_logic
    );
end entity;

architecture rtl of data_path is

    component round is
        port (
            round_in     : in   t_state;
            round_number : in   unsigned(5 downto 0);
            round_out    : out  t_state
        );
    end component;

    signal state        : t_state;
    signal round_out    : t_state;

begin

    round_map : round
    port map(
        round_in     => state,
        round_number => d_counter,
        round_out    => round_out
    );

    out_data_proc : process(d_counter, write_data, state) is
        variable y : integer := 0;
    begin
        if(write_data = '1') then

            -- 8 messages to transfer 256 bits
            case d_counter is
                when "000000" | "000001" => y := 0;
                when "000010" | "000011" => y := 1;
                when "000100" | "000101" => y := 2;
                when "000110" | "000111" => y := 3;
                when others => y := 0;
            end case;

            out_data <= state(0)(y)(32 * to_integer(d_counter(0 downto 0)) + 31 downto 32 * to_integer(d_counter(0 downto 0)));

        else
            out_data <= (others => '0');
        end if;
    end process;

    data_proc : process (clk, rst) is
        variable x : integer := 0;
        variable y : integer := 0;
    begin
        if (rst = '1') then
            -- initialize the state with zeroes
            for x in 0 to 4 loop
                for y in 0 to 4 loop
                    state(x)(y) <= (others => '0');
                end loop;
            end loop;

        elsif rising_edge(clk) then

            if (read_data = '1') then

                -- 34 messages to transfer one message block (= 17 lanes)
                case d_counter is
                    -- plane 1
                    when "000000" | "000001" => x := 0; y := 0;
                    when "000010" | "000011" => x := 0; y := 1;
                    when "000100" | "000101" => x := 0; y := 2;
                    when "000110" | "000111" => x := 0; y := 3;
                    when "001000" | "001001" => x := 0; y := 4;
                    -- plane 2
                    when "001010" | "001011" => x := 1; y := 0;
                    when "001100" | "001101" => x := 1; y := 1;
                    when "001110" | "001111" => x := 1; y := 2;
                    when "010000" | "010001" => x := 1; y := 3;
                    when "010010" | "010011" => x := 1; y := 4;
                    -- plane 3
                    when "010100" | "010101" => x := 2; y := 0;
                    when "010110" | "010111" => x := 2; y := 1;
                    when "011000" | "011001" => x := 2; y := 2;
                    when "011010" | "011011" => x := 2; y := 3;
                    when "011100" | "011101" => x := 2; y := 4;
                    -- plane 4, first 2 lanes
                    when "011110" | "011111" => x := 3; y := 0;
                    when "100000" | "100001" => x := 3; y := 1;
                    when others => x := 0; y := 0;
                end case;

                state(x)(y)(32 * to_integer(d_counter(0 downto 0)) + 31 downto 32 * to_integer(d_counter(0 downto 0)) +  0) <= state(x)(y)(32 * to_integer(d_counter(0 downto 0)) + 31 downto 32 * to_integer(d_counter(0 downto 0))) xor in_data;

            elsif (proc_data = '1') then
                state <= round_out;

            elsif (write_data = '1') then

                -- reset the state after writing the last block
                if (d_counter = 7) then
                    for x in 0 to 4 loop
                        for y in 0 to 4 loop
                            state(x)(y) <= (others => '0');
                        end loop;
                    end loop;
                end if;

            end if;
        end if;
    end process;
end architecture;
