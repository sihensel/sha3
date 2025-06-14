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

    -- used for Theta
    signal sum_sheet : t_plane;
    signal sum_sheet_1 : t_plane;
    signal sum_sheet_2 : t_plane;
    signal sum_sheet_3 : t_plane;

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

    function f_get_round_constant(i : unsigned) return std_logic_vector is
        variable round_constant : std_logic_vector(63 downto 0);
    begin
        case i is
            when "000000" => round_constant := X"0000000000000001";
            when "000001" => round_constant := X"0000000000008082";
            when "000010" => round_constant := X"800000000000808A";
            when "000011" => round_constant := X"8000000080008000";
            when "000100" => round_constant := X"000000000000808B";
            when "000101" => round_constant := X"0000000080000001";
            when "000110" => round_constant := X"8000000080008081";
            when "000111" => round_constant := X"8000000000008009";
            when "001000" => round_constant := X"000000000000008A";
            when "001001" => round_constant := X"0000000000000088";
            when "001010" => round_constant := X"0000000080008009";
            when "001011" => round_constant := X"000000008000000A";
            when "001100" => round_constant := X"000000008000808B";
            when "001101" => round_constant := X"800000000000008B";
            when "001110" => round_constant := X"8000000000008089";
            when "001111" => round_constant := X"8000000000008003";
            when "010000" => round_constant := X"8000000000008002";
            when "010001" => round_constant := X"8000000000000080";
            when "010010" => round_constant := X"000000000000800A";
            when "010011" => round_constant := X"800000008000000A";
            when "010100" => round_constant := X"8000000080008081";
            when "010101" => round_constant := X"8000000000008080";
            when "010110" => round_constant := X"0000000080000001";
            when "010111" => round_constant := X"8000000080008008";
            when others  => round_constant := (others => '0');
        end case;
        return round_constant;
    end function;

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
    round_out   <= iota_out_3;


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
    for z in 0 to 63 loop
        iota_out(0)(0)(z) <= iota_in(0)(0)(z) xor f_get_round_constant(round_number + round_number + round_number + round_number)(z);
    end loop;
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
    for z in 0 to 63 loop
        iota_out_1(0)(0)(z) <= iota_in_1(0)(0)(z) xor f_get_round_constant(round_number + round_number + round_number + round_number + 1)(z);
    end loop;
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
    for z in 0 to 63 loop
        iota_out_2(0)(0)(z) <= iota_in_2(0)(0)(z) xor f_get_round_constant(round_number + round_number + round_number + round_number + 2)(z);
    end loop;
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
    for z in 0 to 63 loop
        iota_out_3(0)(0)(z) <= iota_in_3(0)(0)(z) xor f_get_round_constant(round_number + round_number + round_number + round_number + 3)(z);
    end loop;
end process;

end architecture;
