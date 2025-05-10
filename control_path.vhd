LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library work;
use work.sha3_constants.all;

entity control_path is
    generic (
        data_width   : natural
    );
    port (
        clk         : in    std_logic;
        nrst        : in    std_logic;

        -- axi input interface
        in_ready    : out   std_logic;
        in_valid    : in    std_logic;
        in_data     : in    std_logic_vector(data_width - 1 downto 0);

        -- axi output interface
        out_ready   : in    std_logic;
        out_valid   : out   std_logic;

        -- control signals
        d_counter   : out   unsigned(5 downto 0);
        read_data   : out   std_logic;
        proc_data   : out   std_logic;
        write_data  : out   std_logic
    );
end entity;

architecture rtl of control_path is

    type state_type is (st_rst, st_read_cmd, st_read_data, st_process, st_write_data);
    signal current_state : state_type;
    signal next_state : state_type;

    signal counter : unsigned(5 downto 0);
    signal counter_en : std_logic_vector(1 downto 0);

    signal in_ready_i : std_logic;
    signal out_valid_i : std_logic;

    signal write_hash_after_f : std_logic;
begin

    in_ready <= in_ready_i;
    out_valid <= out_valid_i;

    d_counter <= counter;

    counter_proc : process(nrst, clk) is
    begin
        if(nrst = '0') then
            counter <= (others => '0');
        else
            if(rising_edge(clk)) then
                if(counter_en = "00") then
                    counter <= (others => '0');
                elsif(counter_en = "11") then
                    counter <= counter + 1;
                else
                    counter <= counter;
                end if;
            end if;
        end if;
    end process;

    switch_state_proc : process(nrst, clk) is
    begin
        -- asynchronous reset
        if(nrst = '0') then
            current_state <= st_rst;
        else
            if(rising_edge(clk)) then
                current_state <= next_state;
            end if;
        end if;
    end process;

    next_state_proc : process(current_state, in_ready_i, in_valid, in_data, out_ready, out_valid_i, counter) is
    begin
        case current_state is
            when st_rst =>
                next_state <= st_read_cmd;
            when st_read_cmd =>
                -- read more data blocks after f()
                if(in_ready_i = '1' and in_valid = '1' and in_data(0) = '0') then
                    next_state <= st_read_data;
                    write_hash_after_f <= '0';
                -- write out hash after f()
                elsif(in_ready_i = '1' and in_valid = '1' and in_data(0) = '1') then
                    next_state <= st_read_data;
                    write_hash_after_f <= '1';
                else
                    next_state <= current_state;
                end if;
            when st_read_data =>
                if(in_ready_i = '1' and in_valid = '1' and counter = 33) then
                    next_state <= st_process;
                else
                    next_state <= current_state;
                end if;
            when st_process =>
                -- NOTE we only do 24 rounds, but need 1 more clk cycle to write
                -- the output of f() back to the state
                if(counter = 24) then
                    if (write_hash_after_f = '1') then
                        next_state <= st_write_data;
                    else
                        -- waiting for the next block, go back to reading commands
                        next_state <= st_read_cmd;
                    end if;
                else
                    next_state <= current_state;
                end if;
            when st_write_data =>
                if(out_ready = '1' and out_valid_i = '1' and counter = 7) then
                    next_state <= st_read_cmd;
                else
                    next_state <= current_state;
                end if;
        end case;
    end process;

    mealy_outputs : process(current_state, in_ready_i, in_valid, in_data, out_ready, out_valid_i, counter) is
    begin
        case current_state is
            when st_rst =>
                counter_en  <= "00";
                in_ready_i  <= '0';
                out_valid_i <= '0';
                read_data   <= '0';
                proc_data   <= '0';
                write_data  <= '0';
            when st_read_cmd =>
                -- keep counter at 0
                counter_en  <= "00";
                -- this state will always be ready to read
                in_ready_i  <= '1';
                -- no writes in this state
                out_valid_i <= '0';
                -- deactivate read data
                read_data   <= '0';
                -- deactivate processing
                proc_data   <= '0';
                -- deactivate write data
                write_data  <= '0';

            when st_read_data => 
                if(in_ready_i = '1' and in_valid = '1' and counter < 33) then
                    -- advance counter
                    counter_en <= "11";
                elsif(in_ready_i = '1' and in_valid = '1' and counter = 33) then
                    -- reset counter
                    counter_en <= "00";
                else
                    -- keep counter
                    counter_en <= "10";
                end if;

                -- this state will always be ready to read
                in_ready_i  <= '1';
                -- no writes in this state
                out_valid_i <= '0';
                -- activate read data as soon as in_valid is asserted
                read_data   <= in_valid;
                -- deactivate processing
                proc_data   <= '0';
                -- deactivate write data
                write_data  <= '0';

            when st_process =>
                if(counter < 24) then
                    -- advance counter
                    counter_en <= "11";
                else
                    -- reset counter
                    counter_en <= "00";
                end if;

                -- this state will never be able to read
                in_ready_i  <= '0';
                -- no writes in this state
                out_valid_i <= '0';
                -- deactivate read data
                read_data   <= '0';
                -- activate processing
                proc_data   <= '1';
                -- deactivate write data
                write_data  <= '0';

            when st_write_data =>
                if(out_ready = '1' and out_valid_i = '1' and counter < 7) then
                    -- advance counter
                    counter_en <= "11";
                elsif(out_ready = '1' and out_valid_i = '1' and counter = 7) then
                    -- reset counter
                    counter_en <= "00";
                else
                    -- keep counter
                    counter_en <= "10";
                end if;

                -- during writing, do not read
                in_ready_i  <= '0';
                -- write only in this state
                out_valid_i <= '1';
                -- deactivate read data
                read_data   <= '0';
                -- deactivate processing
                proc_data   <= '0';
                -- activate write data
                write_data  <= '1';
        end case;
    end process;

end architecture;
