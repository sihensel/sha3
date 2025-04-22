library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.sha3_constants.all;


entity round is
    port (
        round_in : in  t_state;
        round_number : in unsigned(4 downto 0);
        round_out : out t_state
    );
end entity;

architecture rtl of round is

    signal theta_in : t_state;
    signal theta_out : t_state;
    -- signal rho_in : t_state;
    -- signal rho_out : t_state;
    -- signal pi_in : t_state;
    -- signal pi_out : t_state;
    signal chi_in : t_state;
    signal chi_out : t_state;
    signal iota_in : t_state;
    signal iota_out : t_state;
    signal round_constant : std_logic_vector(63 downto 0);

    -- used for Theta
    signal C : t_plane;
    signal D : t_plane;

    -- FIXME used for Rho, but likely won't work
    signal xx : integer := 1;
    signal yy : integer := 0;
    signal t : integer := 0;

begin

    theta_in <= round_in;

    -- rho_in <= theta_out;
    -- pi_in <= rho_out;
    -- chi_in <= pi_out;

    -- FIXME remove once Rho and Pi are working
    chi_in <= theta_out;

    iota_in <= chi_out;
    round_out <= iota_out;


-- get the round constant for each round
round_constants : process (round_number) is
begin
	case round_number is
        when "00000" => round_constant <= X"0000000000000001";
	    when "00001" => round_constant <= X"0000000000008082";
	    when "00010" => round_constant <= X"800000000000808A";
	    when "00011" => round_constant <= X"8000000080008000";
	    when "00100" => round_constant <= X"000000000000808B";
	    when "00101" => round_constant <= X"0000000080000001";
	    when "00110" => round_constant <= X"8000000080008081";
	    when "00111" => round_constant <= X"8000000000008009";
	    when "01000" => round_constant <= X"000000000000008A";
	    when "01001" => round_constant <= X"0000000000000088";
	    when "01010" => round_constant <= X"0000000080008009";
	    when "01011" => round_constant <= X"000000008000000A";
	    when "01100" => round_constant <= X"000000008000808B";
	    when "01101" => round_constant <= X"800000000000008B";
	    when "01110" => round_constant <= X"8000000000008089";
	    when "01111" => round_constant <= X"8000000000008003";
	    when "10000" => round_constant <= X"8000000000008002";
	    when "10001" => round_constant <= X"8000000000000080";
	    when "10010" => round_constant <= X"000000000000800A";
	    when "10011" => round_constant <= X"800000008000000A";
	    when "10100" => round_constant <= X"8000000080008081";
	    when "10101" => round_constant <= X"8000000000008080";
	    when "10110" => round_constant <= X"0000000080000001";
	    when "10111" => round_constant <= X"8000000080008008";	    	    
	    when others  => round_constant <=(others => '0');
    end case;
end process round_constants;

-- Theta
process (theta_in) is
begin
    -- Theta first step
    for x in 0 to 4 loop
        for z in 0 to 63 loop
            C(x)(z) <= theta_in(x)(0)(z) xor theta_in(x)(1)(z) xor theta_in(x)(2)(z) xor theta_in(x)(3)(z) xor theta_in(x)(4)(z);
        end loop;
    end loop;
end process;

process (C) is
begin
    -- Theta second step
    for x in 0 to 4 loop
        for z in 0 to 63 loop
            D(x)(z) <= C((x - 1) mod 5)(z) xor C((x + 1) mod 5)((z - 1) mod w);
        end loop;
    end loop;
end process;

process (D) is
begin
    -- Theta third step
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                theta_out(x)(y)(z) <= theta_in(x)(y)(z) xor D(x)(z);
            end loop;
        end loop;
    end loop;
end process;

-- FIXME implement Rho and Pi
-- Rho
-- process (rho_in, t) is
-- begin
--     if (t < 24) then
--         for z in 0 to 63 loop
--             rho_out(xx)(yy)(z) <= rho_in(xx)(yy)((z - (t+1)*(t+2)/2) mod 64);
--         end loop;
--         t <= t + 1;
--         xx <= (0*xx + 1*yy) mod 5;
--         yy <= (2*xx + 3*yy) mod 5;
--         -- report "xx=" & integer'image(xx);
--         -- report "yy=" & integer'image(yy);
--     end if;
-- end process;

-- Pi
-- process (pi_in) is
-- begin
--     for x in 0 to 4 loop
--         for y in 0 to 4 loop
--             for z in 0 to 63 loop
--                 pi_out((x + 3 * y) mod 5)(x)(z) <= pi_in(x)(y)(z);
--             end loop;
--         end loop;
--     end loop;
-- end process;

-- Chi
process (chi_in) is
begin
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                chi_out(x)(y)(z) <= chi_in(x)(y)(z) xor (not(chi_in((x+1) mod 5)(y)(z)) and chi_in((x+2) mod 5)(y)(z));
            end loop;
        end loop;
    end loop;
end process;

-- Iota
process (iota_in) is
begin
    -- for x in 1 to 4 loop
    for x in 0 to 4 loop
        for y in 0 to 4 loop
            for z in 0 to 63 loop
                iota_out(x)(y)(z) <= iota_in(x)(y)(z);
            end loop;
        end loop;
    end loop;

    -- add this block if theta doesnt produce the right results
    -- for y in 1 to 4 loop
    --     for z in 0 to 63 loop
    --         iota_out(0)(y)(z) <= iota_in(0)(y)(z);
    --     end loop;
    -- end loop;

    for z in 0 to 63 loop
        iota_out(0)(0)(z) <= iota_in(0)(0)(z) xor round_constant(z);
    end loop;
end process;

end architecture;
