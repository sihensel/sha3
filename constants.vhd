library ieee;
use ieee.std_logic_1164.all;

package sha3_constants is

    constant x : integer := 5;
    constant y : integer := 5;
    constant w : integer := 64;     -- z axis

    -- lane = 64 bits
    type t_lane is array ((w - 1) downto 0)  of std_logic;    
    -- plane = 5 horizontal lanes
    type t_plane is array ((x - 1) downto 0)  of t_lane;    
    -- state = 5 vertical planes
    type t_state is array ((y - 1) downto 0)  of t_plane;  

    -- prob. wont need these
    constant b : integer := 1600;
    constant l : integer := 6;
    --signal r : unsigned (1152 downto 0);
    --signal c : unsigned (224 downto 0);


    -- measurements of the state block
    -- constant w : integer := 64
    -- constant log_d : integer := 4;
	
end package;
