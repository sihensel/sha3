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
        clk : in std_logic;
        nrst : in std_logic;     -- negative reset

        -- m_in : in std_logic_vector(31 downto 0);
        -- m_valid : in std_logic;
        -- m_out : out std_logic_vector(31 downto 0);

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

    -- type t_mode is (read_in, permutate, read_out);
    -- signal mode : t_mode;

begin

    round_map : round
    port map(
        round_in     => round_in,
        round_number => round_number,
        round_out    => round_out
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

    out_data_proc : process(d_counter, write_data, state) is
    begin
        -- FIXME use the counter to calculate the offset
        if(write_data = '1') then
            state <= round_out;
            -- read output from the rate
            for z in 0 to 31 loop
                out_data(z) <= state(0)(0)(z);
            end loop;
        else 
            state <= zero_state;
        end if;
    end process;

    data_proc : process (clk, nrst) is
    begin
        if (nrst = '0') then
            round_number <= (others => '0');
            state <= zero_state;
            out_data <= (others => '0');

        elsif rising_edge(clk) then

            if (read_data = '1') then
                -- FIXME use the counter to calculate the offset
                -- add data to the rate, 17 lanes in total
                -- write the first 15 lanes
                state <= zero_state;
                for x in 0 to 2 loop
                    for y in 0 to 4 loop
                        for z in 0 to 31 loop
                            state(x)(y)(z)    <= zero_state(x)(y)(z) xor in_data(z);
                            state(x)(y)(z+32) <= zero_state(x)(y)(z+32) xor in_data(z);
                        end loop;
                    end loop;
                end loop;

                -- add the remaining 2 lanes
                for y in 0 to 1 loop
                    for z in 0 to 31 loop
                        state(3)(y)(z)    <= zero_state(x)(y)(z) xor in_data(z);
                        state(3)(y)(z+32) <= zero_state(x)(y)(z+32) xor in_data(z);
                    end loop;
                end loop;

            elsif (proc_data = '1') then
                -- FIXME this prob won't work
                if (round_number = 0) then
                    round_in <= state;
                --elsif (round_number < 23) then
                --    round_in <= round_out;
                --    round_number <= round_number + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
