library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.sha3_constants.all;

entity round is
    port (
        round_in     : in   t_state;
        round_number : in   unsigned(5 downto 0);
        round_out    : out  t_state
    );
end entity;

architecture rtl of round is

    signal theta_in       : t_state;
    signal theta_out      : t_state;
    signal rho_in         : t_state;
    signal rho_out        : t_state;
    signal pi_in          : t_state;
    signal pi_out         : t_state;
    signal chi_in         : t_state;
    signal chi_out        : t_state;
    signal iota_in        : t_state;
    signal iota_out       : t_state;

    signal theta_in_1       : t_state;
    signal theta_out_1      : t_state;
    signal rho_in_1         : t_state;
    signal rho_out_1        : t_state;
    signal pi_in_1          : t_state;
    signal pi_out_1         : t_state;
    signal chi_in_1         : t_state;
    signal chi_out_1        : t_state;
    signal iota_in_1        : t_state;
    signal iota_out_1       : t_state;

    signal theta_in_2       : t_state;
    signal theta_out_2      : t_state;
    signal rho_in_2         : t_state;
    signal rho_out_2        : t_state;
    signal pi_in_2          : t_state;
    signal pi_out_2         : t_state;
    signal chi_in_2         : t_state;
    signal chi_out_2        : t_state;
    signal iota_in_2        : t_state;
    signal iota_out_2       : t_state;

    signal theta_in_3       : t_state;
    signal theta_out_3      : t_state;
    signal rho_in_3         : t_state;
    signal rho_out_3        : t_state;
    signal pi_in_3          : t_state;
    signal pi_out_3         : t_state;
    signal chi_in_3         : t_state;
    signal chi_out_3        : t_state;
    signal iota_in_3        : t_state;
    signal iota_out_3       : t_state;

    signal theta_in_4       : t_state;
    signal theta_out_4      : t_state;
    signal rho_in_4         : t_state;
    signal rho_out_4        : t_state;
    signal pi_in_4          : t_state;
    signal pi_out_4         : t_state;
    signal chi_in_4         : t_state;
    signal chi_out_4        : t_state;
    signal iota_in_4        : t_state;
    signal iota_out_4       : t_state;

    signal theta_in_5       : t_state;
    signal theta_out_5      : t_state;
    signal rho_in_5         : t_state;
    signal rho_out_5        : t_state;
    signal pi_in_5          : t_state;
    signal pi_out_5         : t_state;
    signal chi_in_5         : t_state;
    signal chi_out_5        : t_state;
    signal iota_in_5        : t_state;
    signal iota_out_5       : t_state;

    -- used for Theta
    signal sum_sheet : t_plane;
    signal sum_sheet_1 : t_plane;
    signal sum_sheet_2 : t_plane;
    signal sum_sheet_3 : t_plane;
    signal sum_sheet_4 : t_plane;
    signal sum_sheet_5 : t_plane;

    -- lookup table for Rho constants, see Table 2 of FIPS-202
    -- these values are already precalculated with mod 64
    type t_rho_const is array (0 to 4, 0 to 4) of integer range 0 to 63;
    constant rho_const : t_rho_const := (
    -- x 0   1   2   3   4       y
        (0,  1,  62, 28, 27), -- 0
        (36, 44, 6,  55, 20), -- 1
        (3,  10, 43, 25, 39), -- 2
        (41, 45, 15, 21, 8),  -- 3
        (18, 2,  61, 56, 14)  -- 4
    );

    -- lookup table for the Iota round constants
    type t_round_const is array(0 to 23) of std_logic_vector(63 downto 0);
    constant round_const : t_round_const := (
        X"0000000000000001",
        X"0000000000008082",
        X"800000000000808A",
        X"8000000080008000",
        X"000000000000808B",
        X"0000000080000001",
        X"8000000080008081",
        X"8000000000008009",
        X"000000000000008A",
        X"0000000000000088",
        X"0000000080008009",
        X"000000008000000A",
        X"000000008000808B",
        X"800000000000008B",
        X"8000000000008089",
        X"8000000000008003",
        X"8000000000008002",
        X"8000000000000080",
        X"000000000000800A",
        X"800000008000000A",
        X"8000000080008081",
        X"8000000000008080",
        X"0000000080000001",
        X"8000000080008008"
    );

begin

    -- "plug" the step signals into each other
    theta_in  <= round_in;
    rho_in    <= theta_out;
    pi_in     <= rho_out;
    chi_in    <= pi_out;
    iota_in   <= chi_out;

    theta_in_1  <= iota_out;
    rho_in_1    <= theta_out_1;
    pi_in_1     <= rho_out_1;
    chi_in_1    <= pi_out_1;
    iota_in_1   <= chi_out_1;

    theta_in_2  <= iota_out_1;
    rho_in_2    <= theta_out_2;
    pi_in_2     <= rho_out_2;
    chi_in_2    <= pi_out_2;
    iota_in_2   <= chi_out_2;

    theta_in_3  <= iota_out_2;
    rho_in_3    <= theta_out_3;
    pi_in_3     <= rho_out_3;
    chi_in_3    <= pi_out_3;
    iota_in_3   <= chi_out_3;

    theta_in_4  <= iota_out_3;
    rho_in_4    <= theta_out_4;
    pi_in_4     <= rho_out_4;
    chi_in_4    <= pi_out_4;
    iota_in_4   <= chi_out_4;

    theta_in_5  <= iota_out_4;
    rho_in_5    <= theta_out_5;
    pi_in_5     <= rho_out_5;
    chi_in_5    <= pi_out_5;
    iota_in_5   <= chi_out_5;
    round_out   <= iota_out_5;


-- Theta
process (theta_in) is
begin
    for y in 0 to 4 loop
        for z in 0 to 63 loop
            sum_sheet(y)(z) <= theta_in(0)(y)(z) xor theta_in(1)(y)(z) xor theta_in(2)(y)(z) xor theta_in(3)(y)(z) xor theta_in(4)(y)(z);
        end loop;
    end loop;
end process;

process (theta_in, sum_sheet) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                theta_out(x)(y)(z) <= theta_in(x)(y)(z) xor sum_sheet((y - 1) mod 5)(z) xor sum_sheet((y + 1) mod 5)((z - 1) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Rho
process (rho_in) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                rho_out(x)(y)(z) <= rho_in(x)(y)((z - rho_const(x, y)) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Pi
process (pi_in) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                pi_out((2*y + 3*x) mod 5)(0*y + 1*x)(z) <= pi_in(x)(y)(z);
            end loop;
        end loop;
    end loop;
end process;

-- Chi
process (chi_in) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                chi_out(x)(y)(z) <= chi_in(x)(y)(z) xor (not(chi_in(x)((y+1) mod 5)(z)) and chi_in(x)((y+2) mod 5)(z));
            end loop;
        end loop;
    end loop;
end process;

-- Iota
process (iota_in, round_number) is
begin
    -- copy state as is
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                iota_out(x)(y)(z) <= iota_in(x)(y)(z);
            end loop;
        end loop;
    end loop;

    -- add round constant to the lane at (0, 0)
    if (round_number <= 3) then
        for z in 0 to 63 loop
            iota_out(0)(0)(z) <= iota_in(0)(0)(z) xor round_const(to_integer(round_number) * 6)(z);
        end loop;
    end if;
end process;


-- Second round

-- Theta
process (theta_in_1) is
begin
    for y in 0 to 4 loop
        for z in 0 to 63 loop
            sum_sheet_1(y)(z) <= theta_in_1(0)(y)(z) xor theta_in_1(1)(y)(z) xor theta_in_1(2)(y)(z) xor theta_in_1(3)(y)(z) xor theta_in_1(4)(y)(z);
        end loop;
    end loop;
end process;

process (theta_in_1, sum_sheet_1) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                theta_out_1(x)(y)(z) <= theta_in_1(x)(y)(z) xor sum_sheet_1((y - 1) mod 5)(z) xor sum_sheet_1((y + 1) mod 5)((z - 1) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Rho
process (rho_in_1) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                rho_out_1(x)(y)(z) <= rho_in_1(x)(y)((z - rho_const(x, y)) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Pi
process (pi_in_1) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                pi_out_1((2*y + 3*x) mod 5)(0*y + 1*x)(z) <= pi_in_1(x)(y)(z);
            end loop;
        end loop;
    end loop;
end process;

-- Chi
process (chi_in_1) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                chi_out_1(x)(y)(z) <= chi_in_1(x)(y)(z) xor (not(chi_in_1(x)((y+1) mod 5)(z)) and chi_in_1(x)((y+2) mod 5)(z));
            end loop;
        end loop;
    end loop;
end process;

-- Iota
process (iota_in_1, round_number) is
begin
    -- copy state as is
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                iota_out_1(x)(y)(z) <= iota_in_1(x)(y)(z);
            end loop;
        end loop;
    end loop;

    -- add round constant to the lane at (0, 0)
    if (round_number <= 3) then
        for z in 0 to 63 loop
            iota_out_1(0)(0)(z) <= iota_in_1(0)(0)(z) xor round_const(to_integer(round_number) * 6 + 1)(z);
        end loop;
    end if;
end process;


-- Third round

-- Theta
process (theta_in_2) is
begin
    for y in 0 to 4 loop
        for z in 0 to 63 loop
            sum_sheet_2(y)(z) <= theta_in_2(0)(y)(z) xor theta_in_2(1)(y)(z) xor theta_in_2(2)(y)(z) xor theta_in_2(3)(y)(z) xor theta_in_2(4)(y)(z);
        end loop;
    end loop;
end process;

process (theta_in_2, sum_sheet_2) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                theta_out_2(x)(y)(z) <= theta_in_2(x)(y)(z) xor sum_sheet_2((y - 1) mod 5)(z) xor sum_sheet_2((y + 1) mod 5)((z - 1) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Rho
process (rho_in_2) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                rho_out_2(x)(y)(z) <= rho_in_2(x)(y)((z - rho_const(x, y)) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Pi
process (pi_in_2) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                pi_out_2((2*y + 3*x) mod 5)(0*y + 1*x)(z) <= pi_in_2(x)(y)(z);
            end loop;
        end loop;
    end loop;
end process;

-- Chi
process (chi_in_2) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                chi_out_2(x)(y)(z) <= chi_in_2(x)(y)(z) xor (not(chi_in_2(x)((y+1) mod 5)(z)) and chi_in_2(x)((y+2) mod 5)(z));
            end loop;
        end loop;
    end loop;
end process;

-- Iota
process (iota_in_2, round_number) is
begin
    -- copy state as is
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                iota_out_2(x)(y)(z) <= iota_in_2(x)(y)(z);
            end loop;
        end loop;
    end loop;

    -- add round constant to the lane at (0, 0)
    if (round_number <= 3) then
        for z in 0 to 63 loop
            iota_out_2(0)(0)(z) <= iota_in_2(0)(0)(z) xor round_const(to_integer(round_number) * 6 + 2)(z);
        end loop;
    end if;
end process;


-- Fourth round

-- Theta
process (theta_in_3) is
begin
    for y in 0 to 4 loop
        for z in 0 to 63 loop
            sum_sheet_3(y)(z) <= theta_in_3(0)(y)(z) xor theta_in_3(1)(y)(z) xor theta_in_3(2)(y)(z) xor theta_in_3(3)(y)(z) xor theta_in_3(4)(y)(z);
        end loop;
    end loop;
end process;

process (theta_in_3, sum_sheet_3) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                theta_out_3(x)(y)(z) <= theta_in_3(x)(y)(z) xor sum_sheet_3((y - 1) mod 5)(z) xor sum_sheet_3((y + 1) mod 5)((z - 1) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Rho
process (rho_in_3) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                rho_out_3(x)(y)(z) <= rho_in_3(x)(y)((z - rho_const(x, y)) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Pi
process (pi_in_3) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                pi_out_3((2*y + 3*x) mod 5)(0*y + 1*x)(z) <= pi_in_3(x)(y)(z);
            end loop;
        end loop;
    end loop;
end process;

-- Chi
process (chi_in_3) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                chi_out_3(x)(y)(z) <= chi_in_3(x)(y)(z) xor (not(chi_in_3(x)((y+1) mod 5)(z)) and chi_in_3(x)((y+2) mod 5)(z));
            end loop;
        end loop;
    end loop;
end process;

-- Iota
process (iota_in_3, round_number) is
begin
    -- copy state as is
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                iota_out_3(x)(y)(z) <= iota_in_3(x)(y)(z);
            end loop;
        end loop;
    end loop;

    -- add round constant to the lane at (0, 0)
    if (round_number <= 3) then
        for z in 0 to 63 loop
            iota_out_3(0)(0)(z) <= iota_in_3(0)(0)(z) xor round_const(to_integer(round_number) * 6 + 3)(z);
        end loop;
    end if;
end process;


-- Fifth round

-- Theta
process (theta_in_4) is
begin
    for y in 0 to 4 loop
        for z in 0 to 63 loop
            sum_sheet_4(y)(z) <= theta_in_4(0)(y)(z) xor theta_in_4(1)(y)(z) xor theta_in_4(2)(y)(z) xor theta_in_4(3)(y)(z) xor theta_in_4(4)(y)(z);
        end loop;
    end loop;
end process;

process (theta_in_4, sum_sheet_4) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                theta_out_4(x)(y)(z) <= theta_in_4(x)(y)(z) xor sum_sheet_4((y - 1) mod 5)(z) xor sum_sheet_4((y + 1) mod 5)((z - 1) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Rho
process (rho_in_4) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                rho_out_4(x)(y)(z) <= rho_in_4(x)(y)((z - rho_const(x, y)) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Pi
process (pi_in_4) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                pi_out_4((2*y + 3*x) mod 5)(0*y + 1*x)(z) <= pi_in_4(x)(y)(z);
            end loop;
        end loop;
    end loop;
end process;

-- Chi
process (chi_in_4) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                chi_out_4(x)(y)(z) <= chi_in_4(x)(y)(z) xor (not(chi_in_4(x)((y+1) mod 5)(z)) and chi_in_4(x)((y+2) mod 5)(z));
            end loop;
        end loop;
    end loop;
end process;

-- Iota
process (iota_in_4, round_number) is
begin
    -- copy state as is
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                iota_out_4(x)(y)(z) <= iota_in_4(x)(y)(z);
            end loop;
        end loop;
    end loop;

    -- add round constant to the lane at (0, 0)
    if (round_number <= 3) then
        for z in 0 to 63 loop
            iota_out_4(0)(0)(z) <= iota_in_4(0)(0)(z) xor round_const(to_integer(round_number) * 6 + 4)(z);
        end loop;
    end if;
end process;


-- Sixth round

-- Theta
process (theta_in_5) is
begin
    for y in 0 to 4 loop
        for z in 0 to 63 loop
            sum_sheet_5(y)(z) <= theta_in_5(0)(y)(z) xor theta_in_5(1)(y)(z) xor theta_in_5(2)(y)(z) xor theta_in_5(3)(y)(z) xor theta_in_5(4)(y)(z);
        end loop;
    end loop;
end process;

process (theta_in_5, sum_sheet_5) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                theta_out_5(x)(y)(z) <= theta_in_5(x)(y)(z) xor sum_sheet_5((y - 1) mod 5)(z) xor sum_sheet_5((y + 1) mod 5)((z - 1) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Rho
process (rho_in_5) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                rho_out_5(x)(y)(z) <= rho_in_5(x)(y)((z - rho_const(x, y)) mod 64);
            end loop;
        end loop;
    end loop;
end process;

-- Pi
process (pi_in_5) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                pi_out_5((2*y + 3*x) mod 5)(0*y + 1*x)(z) <= pi_in_5(x)(y)(z);
            end loop;
        end loop;
    end loop;
end process;

-- Chi
process (chi_in_5) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                chi_out_5(x)(y)(z) <= chi_in_5(x)(y)(z) xor (not(chi_in_5(x)((y+1) mod 5)(z)) and chi_in_5(x)((y+2) mod 5)(z));
            end loop;
        end loop;
    end loop;
end process;

-- Iota
process (iota_in_5, round_number) is
begin
    -- copy state as is
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                iota_out_5(x)(y)(z) <= iota_in_5(x)(y)(z);
            end loop;
        end loop;
    end loop;

    -- add round constant to the lane at (0, 0)
    if (round_number <= 3) then
        for z in 0 to 63 loop
            iota_out_5(0)(0)(z) <= iota_in_5(0)(0)(z) xor round_const(to_integer(round_number) * 6 + 5)(z);
        end loop;
    end if;
end process;

end architecture;
