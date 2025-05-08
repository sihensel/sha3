library ieee;
use ieee.std_logic_1164.all;

package sha3_constants is

    constant x : integer := 5;
    constant y : integer := 5;
    constant w : integer := 64;     -- z axis

    -- lane = 64 bits
    -- type t_lane is array ((w - 1) downto 0)  of std_logic;
    -- plane = 5 horizontal lanes
    -- type t_plane is array ((x - 1) downto 0)  of t_lane;
    type t_plane is array ((x - 1) downto 0)  of std_logic_vector(63 downto 0);
    -- state = 5 vertical planes
    type t_state is array ((y - 1) downto 0)  of t_plane;

end package;
