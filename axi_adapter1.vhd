library ieee;
use ieee.std_logic_1164.all;

entity axi_adapter1 is
  generic (
    input_width     : natural;
    output_width    : natural
  );
  port (
    clk         : in    std_logic;
    rst         : in    std_logic;
 
    -- axi input interface
    in_ready    : out   std_logic;
    in_valid    : in    std_logic;
    in_data     : in    std_logic_vector(input_width - 1 downto 0);
 
    -- axi output interface
    out_ready   : in    std_logic;
    out_valid   : out   std_logic;
    out_data    : out   std_logic_vector(output_width - 1 downto 0)
  );
end entity; 

architecture behavioral of axi_adapter1 is

constant multiplier : natural := output_width/input_width;
signal internal_storage : std_logic_vector(output_width-1 downto 0);


-- Newest element at head, oldest element at tail
subtype index_type is natural range 0 to multiplier-1;
signal count : index_type;

-- Internal versions of entity signals with mode "out"
signal in_ready_i   : std_logic;
signal out_valid_i  : std_logic;

begin

in_ready    <= in_ready_i;
out_valid   <= out_valid_i;

-- read after write
out_data <= internal_storage;

input_output : process(clk)
begin
    if rising_edge(clk) then
        if(in_valid = '1' and in_ready_i = '1') then
            internal_storage(input_width*(count+1)-1 downto input_width*count) <= in_data;
        end if;
    end if;
end process;

update_count_and_flags : process(rst, clk) is
begin
    if(rst = '1') then
        in_ready_i <= '1';
        out_valid_i <= '0';
        count <= multiplier-1;
    elsif(rising_edge(clk)) then
        if(count = 0 and out_valid_i = '1' and out_ready = '1') then
            -- reset counter after sending out the data
            count <= multiplier-1;
            out_valid_i <= '0';
            in_ready_i <= '1';
        elsif(count > 0 and (in_valid = '1') and (in_ready_i = '1')) then
            -- next data received
            count <= count - 1;
            out_valid_i <= '0';
            in_ready_i <= '1';
        elsif(count = 0 and (in_valid = '1') and (in_ready_i = '1')) then
            count <= 0;
            out_valid_i <= '1';
            in_ready_i <= '0';
        end if;
    end if;
end process;

end architecture;