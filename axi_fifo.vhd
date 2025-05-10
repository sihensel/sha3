library ieee;
use ieee.std_logic_1164.all;

entity axi_fifo is
  generic (
    ram_width : natural;
    ram_depth : natural
  );
  port (
    clk         : in    std_logic;
    rst         : in    std_logic;
 
    -- axi input interface
    in_ready    : out   std_logic;
    in_valid    : in    std_logic;
    in_data     : in    std_logic_vector(ram_width - 1 downto 0);
 
    -- axi output interface
    out_ready   : in    std_logic;
    out_valid   : out   std_logic;
    out_data    : out   std_logic_vector(ram_width - 1 downto 0)
  );
end entity; 

architecture behavioral of axi_fifo is

-- The FIFO is full when the RAM contains ram_depth - 1 elements
type ram_type is array (0 to ram_depth - 1) of std_logic_vector(in_data'range);
signal ram : ram_type;

-- Newest element at head, oldest element at tail
subtype index_type is natural range 0 to ram_depth;
signal head     : index_type;
signal tail     : index_type;
signal count    : index_type;

-- Internal versions of entity signals with mode "out"
signal in_ready_i   : std_logic;
signal out_valid_i  : std_logic;

begin


in_ready    <= in_ready_i;
out_valid   <= out_valid_i;

-- read after write style for RAM
out_data <= ram(tail);

rw_ram : process(clk)
begin
    if rising_edge(clk) then
        if(in_valid = '1' and in_ready_i = '1') then
            ram(head) <= in_data;
        end if;
    end if;
end process;

update_head : process(rst, clk) is
begin
    if(rst = '1') then
        head <= 0;
    elsif(rising_edge(clk)) then
        if((in_valid = '1') and (in_ready_i = '1')) then
            head <= (head + 1) mod ram_depth;
        end if;
    end if;
end process;


update_tail : process(rst, clk) is
begin
    if(rst = '1') then
        tail <= 0;
    elsif(rising_edge(clk)) then
        if((out_valid_i = '1') and (out_ready = '1')) then
            tail <= (tail + 1) mod ram_depth;
        end if;
    end if;
end process;

update_count_and_flags : process(rst, clk) is
    variable next_count : natural;
begin
    if(rst = '1') then
        in_ready_i <= '0';
        out_valid_i <= '0';
        count <= 0;
    elsif(rising_edge(clk)) then
        if((in_valid = '1') and (in_ready_i = '1') and (out_valid_i = '0' or out_ready = '0')) then
            next_count := count + 1;
        elsif((out_valid_i = '1') and (out_ready = '1') and (in_valid = '0' or in_ready_i = '0')) then
            next_count := count - 1;
        else
            next_count := count;
        end if;
        
        count <= next_count;
        
        if(next_count < ram_depth) then
            in_ready_i <= '1';
        else
            in_ready_i <= '0';
        end if;

        if(next_count > 0 ) then
            out_valid_i <= '1';
        else
            out_valid_i <= '0';
        end if;        
    end if;
end process;

end architecture;